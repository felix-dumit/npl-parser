%{
#include <stdio.h>

void yyerror(const char* errmsg);
int yywrap(void);

%}

%union{
	char *str;
	int intval;
}

%token <intval> T_DIGIT
%token <str> T_NAME T_WORD T_TEXT_TITLE
%token T_ENTER

%token T_NEWSPAPER T_TITLE T_DATE T_ABSTRACT T_TEXT T_SOURCE T_IMAGE T_AUTHOR T_STRUCTURE T_ITEM 
%token T_COL T_SHOW

%type <str> regra comment listOfWords 



%%

initial:
	comment {printf("%s", $1);}

regra: T_NAME T_NAME {sprintf($$, "regra marota: %s", $1);}

comment: 
		'/' '/' listOfWords T_ENTER {sprintf($$, "comment: %s", $3);}

newspaper:
	T_NEWSPAPER '{' newspaperStructure '}'

newspaperStructure:
	requiredNewspaperFields newsDeclaration

requiredNewspaperFields:
	titleField dateField structureField

structureField:
	T_STRUCTURE '{' colField showField '}'

colField:
	T_COL '=' T_DIGIT

showField:
	T_SHOW '=' T_NAME otherNews

otherNews:
		',' T_NAME otherNews
	|

newsDeclaration:
	T_NAME '{' newsParams '}' newsDeclaration
	| 

newsParams:
	titleField abstractField authorField optionalDateField optionalImageField optionalSourceField optionalTextField structureField //ordered

titleField:
	T_TITLE '=' quotedText

dateField:
	T_DATE '=' quotedText

optionalDateField:
	dateField
	|

abstractField:
	T_ABSTRACT '=' quotedText

authorField:
	T_AUTHOR '=' quotedText

optionalImageField:
	T_IMAGE '=' quotedText
	|

optionalSourceField:
	T_SOURCE '=' quotedText
	|


optionalTextField:
	T_TEXT '=' quotedText
	|

quotedText:
	'"' listOfWords '"'

listOfWords:
	  T_WORD listOfWords 
	| T_NAME listOfWords									//Concatena a porra toda!}
	|  													
%%

void yyerror(const char* errmsg)
{
	printf("***Error: %s\n", errmsg);
}


int yywrap(void) { return 1; }
 
int main(int argc, char** argv)
{
     yyparse();
     return 0;
}



