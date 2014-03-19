%{

#include "npData.h"
#include "parser.h" 
%}


NAME [a-z][_a-zA-Z0-9]*
DIGIT  [0-9]+
WHITESPACE [ \n\r\t]+
QUOTEDTEXT \"(?:\\.|[^"\\])*\"
ANY_CHAR .


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
"#" 			{return '#';}
"*" 			{return '*';}
"=" 			{return '=';}
"/" 			{return '/';}
":" 			{return ':';}
"'" 			{return '\'';}

{WHITESPACE} /* ignore */ ;
{DIGIT}	{	
			yylval.intval = atoi(yytext);
			return T_DIGIT;
			}
{NAME}	{
			yylval.str = (char*) strdup(yytext);
			printf("nameou:%s\n", yylval.str);	
			return T_NAME;
			}
{QUOTEDTEXT} {	yylval.str = (char*) stripQuotes(strdup(yytext));	
			//printf("qtext: %s\n", yylval.str);
			return T_QTEXT;
		}



{ANY_CHAR} {
	printf("Caracter %c (ASCII %d) inesperado.\n", yytext[0], yytext[0]);
}
	
%%

// Codigo C


