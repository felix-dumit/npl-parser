%{
#include <stdio.h>

void yyerror(const char* errmsg);
void yywrap(void);

%}

%union{
	char *str;
	int intval;
}

%token <intval> T_DIGIT
%token <str> T_NAME
%token T_ENTER

%token T_NEWSPAPER
%token T_TITLE
%token T_DATE
%token T_ABSTRACT
%token T_TEXT
%token T_TEXT_TITLE
%token T_SOURCE
%token T_IMAGE
%token T_AUTHOR
%token T_STRUCTURE
%token T_ITEM

%%

comment: '/' '/' T_STRING

newspaper:
	T_NEWSPAPER '{' newscontent '}'

newscontent:
	T_TITLE '=' T_QUOTEDSTRING T_ENTER T_DATE T_QUOTEDSTRING 

%%

void yyerror(const char* errmsg)
{
	printf("***Error: %s\n", errmsg);
}


void yywrap(void){
	return 1;
}


void main()
{
	yyparse();
	return 0;
}



