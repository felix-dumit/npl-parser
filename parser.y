%{
#include <stdio.h>
#include "helpers.h"

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

%type <str> regra comment listOfWords quotedText



%%

initial:
	newspaper {printf("%s", $1);}

regra: T_NAME T_NAME {$$ = concat(2, "regra marota: ", $1);}

comment: 
		'/' '/' listOfWords T_ENTER {$$ = "";}

newspaper:
	T_NEWSPAPER '{' newspaperStructure '}'

newspaperStructure:
	requiredNewspaperFields newsDeclaration

requiredNewspaperFields:
	titleField dateField structureField

structureField:
	T_STRUCTURE '{' colField showField '}'

colField:
	T_COL '=' T_DIGIT T_ENTER

showField:
	T_SHOW '=' T_NAME otherNews T_ENTER

otherNews:
		',' T_NAME otherNews
	|

newsDeclaration:
	T_NAME '{' newsParams '}' T_ENTER newsDeclaration
	| 

newsParams:
	titleField abstractField authorField optionalDateField optionalImageField optionalSourceField optionalTextField structureField //ordered

titleField:
	T_TITLE '=' quotedText T_ENTER

dateField:
	T_DATE '=' quotedText T_ENTER

optionalDateField:
	dateField
	|

abstractField:
	T_ABSTRACT '=' quotedText T_ENTER

authorField:
	T_AUTHOR '=' quotedText T_ENTER

optionalImageField:
	T_IMAGE '=' quotedText T_ENTER
	|

optionalSourceField:
	T_SOURCE '=' quotedText T_ENTER
	|


optionalTextField:
	T_TEXT '=' quotedText T_ENTER
	|

quotedText:
	'"' listOfWords '"' {$$ = $;}

listOfWords:
	  T_WORD listOfWords { $$ = concat(3, $1, " ", $2);}
	| T_NAME listOfWords { $$ = concat(3, $1, " ", $2);}									//Concatena a porra toda!}
	|  	{$$ = "";}												


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



