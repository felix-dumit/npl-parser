%{

#include "npData.h"
#include "parser.h" 

//QUOTEDTEXT \"(?:\\.|[^"\\])*\"
int italicFlag = 0;
int boldFlag = 0;
int boldAndItalicFlag = 0;
int titleFlag = 0;

int bulletCount = 0;
int HScount = 0;
int LIopen = 0;

char *string_buf;


%}


NAME [a-zA-Z][_a-zA-Z0-9]*
CHARCT [[:alnum:]âôêéáíóúãõàçÂÜÔÊÉÁÍÓÚÃÕÀÇÜ[:punct:]]{-}[":#*"]
DIGIT  [0-9]+
WHITESPACE [ \n\r\t\f]
ANY_CHAR .

%x IN_COMMENT
%x QUOTED_TEXT
%x ITALIC


%option case-insensitive
%option   warn nodefault
%option   yylineno

%%


"NEWSPAPER" 	{	yylval.str = "newspaper";
					return T_NEWSPAPER;}
"TITLE" 		{	yylval.str = "title";
					return T_TITLE;}
"DATE"			{	yylval.str = "date";
					return T_DATE;}
"ABSTRACT"		{	yylval.str = "abstract";
					return T_ABSTRACT;}
"TEXT"			{	yylval.str = "text";
					return T_TEXT;}
"SOURCE"		{	yylval.str = "source";
					return T_SOURCE;}
"IMAGE"			{	yylval.str = "image";
					return T_IMAGE;}		 
"AUTHOR"		{	yylval.str = "author";
					return T_AUTHOR;}		
"STRUCTURE"		{	yylval.str = "structure";
					return T_STRUCTURE;}		
"ITEM"			{	yylval.str = "item";
					return T_ITEM;}
"COL"			{	
					yylval.str = "col";
					return T_COL;}
"SHOW"			{	yylval.str = "show";
					return T_SHOW;}
"," 			{return ',';}	
"{" 			{return '{';}
"}" 			{return '}';}
"[" 			{return '[';}
"]" 			{return ']';}
"=" 			{return '=';}
"/" 			{return '/';}
":" 			{return ':';}
"'" 			{return '\'';}

"//"             {BEGIN(IN_COMMENT);}

 <IN_COMMENT>{
			 \n      {BEGIN(INITIAL);}
			 [^\n]+    // eat comment
			 \/       // eat the lone /
 }


"\""		{
				//printf("comecou string\n"); 
				string_buf = "";
				BEGIN(QUOTED_TEXT);
			}
<QUOTED_TEXT>{
				"\""			{	
									yylval.str = strdup(string_buf);              					
									//printf("terminou string:%s\n", yylval.str); 
									BEGIN(INITIAL);
									return T_QTEXT;
								}
				"http://"		{   string_buf = (char*) concat(2, string_buf, yytext);}
				{CHARCT} 		{
									string_buf = (char*) concat(2, string_buf, yytext);
								} 
				[[:space:]]	{ string_buf = (char*) concat(2, string_buf, yytext); //appendText(&string_buf, yytext);
}
				":"				{string_buf = (char*) concat(2, string_buf, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
								 //appendText(&string_buf, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
								}
				"\\\""			{string_buf = (char*) concat(2, string_buf, "\"");
								}
				"''"			{
									if(italicFlag){
										string_buf = (char*) concat(2, string_buf, "</i>");
										//appendText(&string_buf, "</i>");
										italicFlag = 0;
									}else{
										string_buf = (char*) concat(2, string_buf, "<i>");
										//appendText(&string_buf, "<i>");
										italicFlag = 1;										
									}
								}
				"'''"			{
					if(boldFlag){
						string_buf = (char*) concat(2, string_buf, "</b>");
						//appendText(&string_buf, "</b>");
						boldFlag = 0;
					}else{
						string_buf = (char*) concat(2, string_buf, "<b>");
						//appendText(&string_buf, "</b>");
						boldFlag = 1;										
					}
				}
				"''''"	// de 4 nao pode
				"'''''"			{
					if(boldAndItalicFlag){
						string_buf = (char*) concat(2, string_buf, "</i></b>");
						//appendText(&string_buf, "</i></b>");
						boldAndItalicFlag = 0;
					}else{
						string_buf = (char*) concat(2, string_buf, "<b><i>");
						//appendText(&string_buf, "<b><i>");						
						boldAndItalicFlag = 1;										
					}
				}
				"==="	{
							if(titleFlag){
								string_buf = (char*) concat(2, string_buf, "</h3>\n");
								//appendText(&string_buf, "</h3>");

								titleFlag = 0;
							}else{
								string_buf = (char*) concat(2, string_buf, "<h3 class=\"intextTitle\">");
								//appendText(&string_buf, "<h3 class=\"intextTitle\">");
								titleFlag = 1;
							}
				}

				[#]+	{
							int numHS = strlen(yytext);

							//printf("#hashtag:%d %d\n", numHS, HScount);


							if(numHS >HScount) {
								for(; HScount < numHS; HScount++){
									string_buf = (char*) concat(2, string_buf, "<ol>");
								}
								string_buf = (char*) concat(2, string_buf, "<li>");
								//appendText(&string_buf, "<ol><li>");
							}
							else if(numHS < HScount){								

								for(; HScount > numHS; HScount--) {
									string_buf = (char*) concat(2, string_buf, "</ol>\n");
									//appendText(&string_buf, "</ol>");
								}
								HScount = numHS;
								string_buf = (char*) concat(2, string_buf, "<li>");
								//appendText(&string_buf, "<li>");

							}
							else if(numHS == HScount){	
								string_buf = (char*) concat(2, string_buf, "<li>");
								//appendText(&string_buf, "<li>");
							}


							LIopen = 1;
					}
				
				[[:cntrl:]]+/[^"#"]+\n {
									if(LIopen){
										string_buf = (char*) concat(2, string_buf, "</li>");
										LIopen = 0;
									} 
									for(; HScount>0; HScount--) {
										string_buf = (char*) concat(2, string_buf, "</ol>\n");
								//appendText(&string_buf, "</ol>");
									} 
								  }
				[[:cntrl:]]+/[^"*"]+\n {
									if(LIopen){
										string_buf = (char*) concat(2, string_buf, "</li>");
										LIopen = 0;
									} 

										for(; bulletCount>0; bulletCount--) {
											string_buf = (char*) concat(2, string_buf, "</ul>\n");
									//appendText(&string_buf, "</ul>");
										} 
								  }
				
				[[:cntrl:]]+/["*""#"] {
						if(LIopen){
							string_buf = (char*) concat(2, string_buf, "</li>");
							LIopen = 0;
						} 
				}
				[[:cntrl:]]+/([^"*"#]) {
							
							if(LIopen){
								string_buf = (char*) concat(2, string_buf, "</li>");
								LIopen = 0;
							} 
							for(; bulletCount>0; bulletCount--) {
								string_buf = (char*) concat(2, string_buf, "</ul>\n");
								//appendText(&string_buf, "</ul>");
							} 

							for(; HScount>0; HScount--){
								string_buf = (char*) concat(2, string_buf, "</ol>\n"); 
								//appendText(&string_buf, "</ol>");
							} 

						}
				["*"]+	{
							int numBullet = strlen(yytext);

							//printf("*bullet:%d %d\n", numBullet, bulletCount);

							if(numBullet > bulletCount){
								for(; bulletCount < numBullet; bulletCount++){
									string_buf = (char*) concat(2, string_buf, "<ul>");

								}

								string_buf = (char*) concat(2, string_buf, "<li>");
								//appendText(&string_buf, "<ul><li>");
							}
							else if(numBullet < bulletCount){								

								for(; bulletCount > numBullet; bulletCount--) {
									string_buf = (char*) concat(2, string_buf, "</ul>\n");
									//appendText(&string_buf, "</ul>");
								}
								bulletCount = numBullet;
								string_buf = (char*) concat(2, string_buf, "<li>");
								//appendText(&string_buf, "<li>");

							}
							else if(numBullet == bulletCount){	
								string_buf = (char*) concat(2, string_buf, "<li>");
								//appendText(&string_buf, "<li>");
							}							

							//printf("---\nYLVL> %s\n---\n", yylval.str);

							LIopen = 1;
					}
					"["[^"["]+"|".+"]"	{
										char** link_parts = str_split(yytext, '|');
										char* link = link_parts[0] + 1;
										char* text = link_parts[1];
										text[strlen(text)-1] = '\0';
										string_buf = (char*) concat(6, string_buf, "<a href=\"", link,"\">", text, "</a>\n");
										//printf("matchedLINK:%s\ntext:%s\n", link, text);
									}
					"["[^"|""["]+"]"		{
										char* link = strdup(yytext);
										link = link + 1;
										link[strlen(link)-1] = '\0';
										string_buf = (char*) concat(6, string_buf, "<a href=\"", link,"\">", link, "</a>\n");


									}
					"[[".+"|".+"]]" {
										char** link_parts = str_split(yytext, '|');
										char* link = link_parts[0] + 2;
										char* text = link_parts[1];
										text[strlen(text)-2] = '\0';
										string_buf = (char*) concat(8, string_buf, "<figure><img src=\"", link, "\"alt=\"", text, "\"/><figcaption>", text, "</figcaption></figure>\n");
									}
					"[[".+"]]"		{
										char* link = strdup(yytext);
										link = link + 2;
										link[strlen(link)-2] = '\0';
										string_buf = (char*) concat(4, string_buf, "<img src=\"", link, "\"alt=\"missing image \"/>");

									}

}

{DIGIT}	{	
			yylval.str = yytext;
			return T_DIGIT;
			}
{NAME}	{
			yylval.str = (char*) tolowerStr(strdup(yytext));
			//printf("nameou:%s\n", yylval.str);	
			return T_NAME;
			}

{WHITESPACE} {;}/* ignore */ 

{ANY_CHAR} {
	printf("Caracter %c (ASCII %d) inesperado.\n", yytext[0], yytext[0]);
}

%%

// Codigo C
void yyerror(char *message)
 {
  	fprintf(stderr, "%d: error: '%s' at '%s', yylval=%u\n", yylineno, message, yytext, yylval);
 }	

// 

/*
{QUOTEDTEXT} {	yylval.str = (char*) stripQuotes(strdup(yytext));	
			//printf("qtext: %s\n", yylval.str);
			return T_QTEXT;
		}
*/