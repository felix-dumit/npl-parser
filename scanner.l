%{
#include "parser.h" 
%}


NAME [a-z][_a-zA-Z0-9]*
/*TITLE ===.+===*/
DIGIT  [0-9]+
WHITESPACE [ \n\r\t]+
/*  COMMENT //.*\n  */
WORD [a-zA-Z\x00-\x7F]
ANY_CHAR .


%option case-insensitive

%%


{WORD} {	yylval.str = (char*) strdup(yytext);	
			return T_WORD;
		}
{DIGIT}		{return T_DIGIT;}
{NAME}	{
			yylval.str = (char*) strdup(yytext);	
			return T_NAME;
			}

{WHITESPACE} /* ignore */ ;
"NEWSPAPER" 	{return T_NEWSPAPER;}
"TITLE" 		{return T_TITLE;}
"DATE"			{return T_DATE;}
"ABSTRACT"		{return T_ABSTRACT;}
"TEXT"			{return T_TEXT;}
"SOURCE"		{return T_SOURCE;}
"IMAGE"			{return T_IMAGE;}		 
"AUTHOR"		{return T_AUTHOR;}		
"STRUCTURE"		{return T_STRUCTURE;}		
"ITEM"			{return T_ITEM;}
"COL"			{return T_COL;}
"SHOW"			{return T_SHOW;}
"," 			{return ',';}	
"{" 			{return '{';}
"}" 			{return '}';}
"[" 			{return '[';}
"]" 			{return ']';}
"#" 			{return '#';}
"*" 			{return '*';}
"=" 			{return '=';}
"/" 			{return '=';}
":" 			{return ':';}
"'" 			{return '\'';}
"\""			{return '"';}
"\n"			{return T_ENTER;}



{ANY_CHAR} {
	printf("Caracter %c (ASCII %d) inesperado.\n", yytext[0], yytext[0]);
}
	
%%

// Codigo C


