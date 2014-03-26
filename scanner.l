%{

#include "npData.h"
#include "parser.h" 

/* Some flags used to deal with 
italic, bold, title and ordered or unordered lists*/

int italicFlag = 0;
int boldFlag = 0;
int boldAndItalicFlag = 0;
int titleFlag = 0;

int bulletCount = 0;
int HScount = 0;
int LIopen = 0;

char *string_buf;


%}

 /* REGEX */ 

/*For the name of each one of the news */
NAME [a-zA-Z][_a-zA-Z0-9]*	

/*For all the characters accepted inside a quoted text	*/			
CHARCT [[:alnum:]âôêéáíóúãõàçÂÜÔÊÉÁÍÓÚÃÕÀÇÜ[:punct:]]{-}[":#*"]

/* Digits */
DIGIT  [0-9]+

/* Whitespaces, newlines and tabs */
WHITESPACE [ \n\r\t\f]

/*Deal with errors when a unexpected character shows up */
ANY_CHAR .

/*Blocks */
%x IN_COMMENT
%x QUOTED_TEXT
%x ITALIC

/*Options */
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
"," 			{	return ',';		}	
"{" 			{	return '{';		}
"}" 			{	return '}';		}
"[" 			{	return '[';		}
"]" 			{	return ']';		}
"=" 			{	return '=';		}
"/" 			{	return '/';		}
":" 			{	return ':';		}
"'" 			{	return '\'';	}

"//"            {	BEGIN(IN_COMMENT);	}

 <IN_COMMENT>{
				 \n      {BEGIN(INITIAL);}	// finish the comment
				 [^\n]+    					// eat comment
				 \/       					// eat the lone /
 			 }


"\""		{   // Starting a quoted text
				string_buf = "";
				BEGIN(QUOTED_TEXT);
			}

<QUOTED_TEXT>{
				"\""			{	// Ends the quoted text
									yylval.str = strdup(string_buf);              					
									BEGIN(INITIAL);
									return T_QTEXT;
								}
				"http://"		{   string_buf = (char*) concat(2, string_buf, yytext);	}
				{CHARCT} 		{	string_buf = (char*) concat(2, string_buf, yytext);	} 

				[[:space:]]		{ 	string_buf = (char*) concat(2, string_buf, yytext); }

				":"				{	// Transform ':' in 6 '&nbsp;'
								  	string_buf = (char*) concat(2, string_buf, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
								}

				"\\\""			{	// Scape for double quotes inside the quoted text 
									string_buf = (char*) concat(2, string_buf, "\"");
								}

				"''"			{	//Either starts or ends a italic text
									if(italicFlag){
										string_buf = (char*) concat(2, string_buf, "</i>");
										italicFlag = 0;
									}else{
										string_buf = (char*) concat(2, string_buf, "<i>");
										italicFlag = 1;										
									}
								}

				"'''"			{	//Either starts of ends a bold text
									if(boldFlag){
										string_buf = (char*) concat(2, string_buf, "</b>");
										boldFlag = 0;
									}else{
										string_buf = (char*) concat(2, string_buf, "<b>");
										boldFlag = 1;										
									}
								}
				"''''"				// just ignore if it's 4 single quotes

				"'''''"			{	// Starting or ending a italic and bold text
									if(boldAndItalicFlag){
										string_buf = (char*) concat(2, string_buf, "</i></b>");
										boldAndItalicFlag = 0;
									}else{
										string_buf = (char*) concat(2, string_buf, "<b><i>");
										boldAndItalicFlag = 1;										
									}
								}
				"==="			{	// Title tag
									if(titleFlag){
										string_buf = (char*) concat(2, string_buf, "</h3>\n");
										titleFlag = 0;
									}else{
										string_buf = (char*) concat(2, string_buf, "<h3 class=\"intextTitle\">");
										titleFlag = 1;
									}
								}


				/* Rules for ordered or unordered list inside a quoted text */

							/* Any number of '#'s */					
				[#]+	{
							//numHS is the number of # entered
							int numHS = strlen(yytext);

							//if it is higher than the actual # count
							//open a new level
							if(numHS >HScount) {
								for(; HScount < numHS; HScount++){
									string_buf = (char*) concat(2, string_buf, "<ol>");
								}
								string_buf = (char*) concat(2, string_buf, "<li>");
							}
							//if its lower, than closes a number of levels until
							//it reaches numHS level
							else if(numHS < HScount){								

								for(; HScount > numHS; HScount--) {
									string_buf = (char*) concat(2, string_buf, "</ol>\n");
								}
								HScount = numHS;
								string_buf = (char*) concat(2, string_buf, "<li>");
							}
							//If it is equal, we are on the same level
							else if(numHS == HScount){	
								string_buf = (char*) concat(2, string_buf, "<li>");
							}

							//Set a flag to mark there is a <li> tag oppened
							LIopen = 1;
					}
						/* A control character followed by some non-'#' characters and a '\n' */
				[[:cntrl:]]+/[^"#"]+\n 	{
											// Closes a <li> tag and every <ol> tags 
											if(LIopen){
												string_buf = (char*) concat(2, string_buf, "</li>");
												LIopen = 0;
											} 
											for(; HScount>0; HScount--) {
												string_buf = (char*) concat(2, string_buf, "</ol>\n");
											} 
								  		}

						/* A control character followed by some non-'*' characters and a '\n' */	  
				[[:cntrl:]]+/[^"*"]+\n  {
											// Closes a <li> tag and every <ul> tags
											if(LIopen){
												string_buf = (char*) concat(2, string_buf, "</li>");
												LIopen = 0;
											} 

											for(; bulletCount>0; bulletCount--) {
												string_buf = (char*) concat(2, string_buf, "</ul>\n");
											} 
								  		}

						/* A control character followed by any '#' or "*" character */
				[[:cntrl:]]+/["*"#] 	{
											// If there is a opened <li> tag, closes it
											if(LIopen){
												string_buf = (char*) concat(2, string_buf, "</li>");
												LIopen = 0;
											} 
										}

						/* A control character followed by any non-'# *' characther */
				[[:cntrl:]]+/([^"*""#"]) {
											//Closes a li tag and every ol and ul tags
											if(LIopen){
												string_buf = (char*) concat(2, string_buf, "</li>");
												LIopen = 0;
											} 
											for(; bulletCount>0; bulletCount--) {
												string_buf = (char*) concat(2, string_buf, "</ul>\n");
											} 

											for(; HScount>0; HScount--){
												string_buf = (char*) concat(2, string_buf, "</ol>\n");
											} 
										}

						/* Any number of '*'s */
				["*"]+	{
							// numBullet is the number of '*'
							int numBullet = strlen(yytext);

							//If it is higher than the actual bullet count, open a new <ul> and <li> tag
							if(numBullet > bulletCount){
								for(; bulletCount < numBullet; bulletCount++){
									string_buf = (char*) concat(2, string_buf, "<ul>");
								}
								string_buf = (char*) concat(2, string_buf, "<li>");
							}
							//If it is lower, closes a <ul> tag and open a <li>
							else if(numBullet < bulletCount){								
								for(; bulletCount > numBullet; bulletCount--) {
									string_buf = (char*) concat(2, string_buf, "</ul>\n");
								}
								bulletCount = numBullet;
								string_buf = (char*) concat(2, string_buf, "<li>");
							}
							//If it is equal, just open a <li> tag
							else if(numBullet == bulletCount){	
								string_buf = (char*) concat(2, string_buf, "<li>");
							}							

							//Set the flag to mark there is a <li> tag opened
							LIopen = 1;
					}
							/*Rule for a link in the form of [ url | text ] */
					"["[^"["]+"|".+"]" 	{
											char** link_parts = str_split(yytext, '|');
											char* link = link_parts[0] + 1;
											char* text = link_parts[1];
											text[strlen(text)-1] = '\0';
											string_buf = (char*) concat(6, string_buf, "<a href=\"", link,"\">", text, "</a>\n");
										}

							/* Rule for a link in the form of [url] */
					"["[^"|""["]+"]"	{
											char* link = strdup(yytext);
											link = link + 1;
											link[strlen(link)-1] = '\0';
											string_buf = (char*) concat(6, string_buf, "<a href=\"", link,"\">", link, "</a>\n");
										}

							/* Rule for inserting an image in the form of  [[image's url | subtitle]] */
					"[[".+"|".+"]]"  	{
											char** link_parts = str_split(yytext, '|');
											char* link = link_parts[0] + 2;
											char* text = link_parts[1];
											text[strlen(text)-2] = '\0';
											string_buf = (char*) concat(8, string_buf, "<figure><img src=\"", link, "\"alt=\"", text, "\"/><figcaption>", text, "</figcaption></figure>\n");
										}
							/* Rule for inserting an image in the form of [[image's url]] */
					"[[".+"]]"			{
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

/////////////////// C Code ///////////////////  

// Error Function
void yyerror(char *message)
 {
  	fprintf(stderr, "%d: error: '%s' at '%s', yylval=%u\n", yylineno, message, yytext, yylval);
 }
