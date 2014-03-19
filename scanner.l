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

%}


NAME [a-z][_a-zA-Z0-9]*
DIGIT  [0-9]+
WHITESPACE [ \n\r\t\f]
LINK_TEXT \[ (.+) | (.+) \]
ANY_CHAR .

%x IN_COMMENT
%x QUOTED_TEXT
%x ITALIC


%option case-insensitive

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
"COL"			{	yylval.str = "col";
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

"//"             {printf("begin comment"); BEGIN(IN_COMMENT);}

 <IN_COMMENT>{
			 \n      {printf("ent comment"); BEGIN(INITIAL);}
			 [^\n]+    // eat comment
			 "/"       // eat the lone /
 }


"\""		{
				printf("comecou string\n"); 
				yylval.str = "";
				BEGIN(QUOTED_TEXT);
			}
<QUOTED_TEXT>{
				[a-zA-Z0-9]+ 	{
				     				printf("letras:%s\n", yytext);
									yylval.str = (char*) concat2(2, yylval.str, yytext);
								}
				{WHITESPACE}	{ yylval.str = (char*) concat2(2, yylval.str, yytext);}
				":"				{printf("dois poiontos\n"); yylval.str = (char*) concat2(2, yylval.str, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
								}
				"\\\""			{yylval.str = (char*) concat2(2, yylval.str, yytext);
								}
				"\""			{printf("terminou string:%s\n", yylval.str); BEGIN(INITIAL);} 
				"''"			{
									if(italicFlag){
										yylval.str = (char*) concat2(2, yylval.str, "</i>");
										italicFlag = 0;
									}else{
										yylval.str = (char*) concat2(2, yylval.str, "<i>");
										italicFlag = 1;										
									}
								}
				"'''"			{
					if(boldFlag){
						yylval.str = (char*) concat2(2, yylval.str, "</b>");
						boldFlag = 0;
					}else{
						yylval.str = (char*) concat2(2, yylval.str, "<b>");
						boldFlag = 1;										
					}
				}
				"''''"	// de 4 nao pode
				"'''''"			{
					if(boldAndItalicFlag){
						yylval.str = (char*) concat2(2, yylval.str, "</i></b>");
						boldAndItalicFlag = 0;
					}else{
						yylval.str = (char*) concat2(2, yylval.str, "<b><i>");
						boldAndItalicFlag = 1;										
					}
				}
				"==="	{
							if(titleFlag){
								yylval.str = (char*) concat2(2, yylval.str, "</h3>");
								titleFlag = 0;
							}else{
								yylval.str = (char*) concat2(2, yylval.str, "<h3 class=\"intextTitle\">");
								titleFlag = 1;
							}
				}

				[#]+	{
							int numHS = strlen(yytext);
							if(LIopen) yylval.str = (char*) concat2(2, yylval.str, "</li>");

							if(numHS == HScount + 1){
								yylval.str = (char*) concat2(2, yylval.str, "<ol><li>");
								HScount++;
							}
							else if(numHS < HScount){								

								for(; HScount > numHS; HScount--) yylval.str = (char*) concat2(2, yylval.str, "</ol>");
								HScount = numHS;
								yylval.str = (char*) concat2(2, yylval.str, "<li>");

							}
							else if(numHS == HScount){	
								yylval.str = (char*) concat2(2, yylval.str, "<li>");
							}							

							LIopen = 1;
							printf("#hashtag\n");
					}
				
				"\n"/([^"*"#]{-}[\t\r\f]) {
							if(bulletCount) {LIopen = 0;  yylval.str = (char*) concat2(2, yylval.str, "</li>");}
							for(; bulletCount; bulletCount--) yylval.str = (char*) concat2(2, yylval.str, "</ul>"); 

							if(HScount) {LIopen = 0;  yylval.str = (char*) concat2(2, yylval.str, "</li>");}
							for(; HScount; HScount--) yylval.str = (char*) concat2(2, yylval.str, "</ol>"); 

						}
				["*"]+	{
							int numBullet = strlen(yytext);

							printf("*bullet:%d %d\n", numBullet, bulletCount);


							if(LIopen) yylval.str = (char*) concat2(2, yylval.str, "</li>");

							if(numBullet == bulletCount + 1){
								yylval.str = (char*) concat2(2, yylval.str, "<ul><li>");
								bulletCount++;
							}
							else if(numBullet < bulletCount){								

								for(; bulletCount > numBullet; bulletCount--) yylval.str = (char*) concat2(2, yylval.str, "</ul>");
								bulletCount = numBullet;
								yylval.str = (char*) concat2(2, yylval.str, "<li>");

							}
							else if(numBullet == bulletCount){	
								yylval.str = (char*) concat2(2, yylval.str, "<li>");
							}							

							printf("---\nYLVL> %s\n---\n", yylval.str);

							LIopen = 1;
					}
}





{DIGIT}	{	
			yylval.intval = atoi(yytext);
			return T_DIGIT;
			}
{NAME}	{
			yylval.str = (char*) strdup(yytext);
			printf("nameou:%s\n", yylval.str);	
			return T_NAME;
			}




{ANY_CHAR} {
	printf("Caracter %c (ASCII %d) inesperado.\n", yytext[0], yytext[0]);
}
	
%%

// Codigo C

// {WHITESPACE} /* ignore */ ;

/*
{QUOTEDTEXT} {	yylval.str = (char*) stripQuotes(strdup(yytext));	
			//printf("qtext: %s\n", yylval.str);
			return T_QTEXT;
		}
*/