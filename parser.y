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
%token T_COL
%token T_SHOW



%%

comment: '/' '/' T_STRING

newspaper:
	T_NEWSPAPER '{' newsStructure '}'

newsStructure:
	requiredFields newsDeclaration

requiredFields:
	titleField dateField structrueField

titleField:
	T_TITLE '=' quotedText T_ENTER

dateField:
	T_DATE '=' quotedText T_ENTER

structureField:
	T_STRUCTURE '{' colField showField '}' T_ENTER   #/// Precisa ter T_ENTER depois dos {} ????

colField:
	T_COL '=' T_DIGIT T_ENTER

showField:
	T_SHOW '=' T_NAME otherNews T_ENTER

otherNews:
		',' T_NAME otherNews
	|    												#//VAZIO ??? 

quotedText:
	'"' listOfWords '"'

listOfWords:
	T_WORD listOfWords 									{//Concatena a porra toda!}
	|  													#// VAZIO ??? 
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



