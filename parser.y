%{
#include <stdio.h>
#include "helpers.h"
#include "npData.h"

void yyerror(const char* errmsg);
int yywrap(void);

%}

%union{
	char *str;
	int intval;
	newsStructure *structure;
	newsItem *nItem;
}

%token <intval> T_DIGIT
%token <str> T_NAME T_WORD T_TEXT_TITLE
%token T_ENTER

%token T_NEWSPAPER T_TITLE T_DATE T_ABSTRACT T_TEXT T_SOURCE T_IMAGE T_AUTHOR T_STRUCTURE T_ITEM 
%token T_COL T_SHOW

%type <str> comment listOfWords quotedText titleField dateField abstractField 
%type <str> authorField optionalDateField optionalImageField optionalSourceField optionalTextField
%type <str> newsItem showField otherNews

%type <structure> structureField
%type <intval> colField

%type <nItem> fieldList newsParams

%%

initial:
	newsItem {printf("NEWSITEM -> %s\n", $1);}

comment: 
		'/' '/' listOfWords T_ENTER {$$ = "";}
/*
newspaper:
	T_NEWSPAPER '{' newspaperStructure '}'

newspaperStructure:
	requiredNewspaperFields newsDeclaration

requiredNewspaperFields:
	titleField dateField structureField
*/

structureField:
	T_STRUCTURE '{' colField showField '}'		{
													newsStructure *temp = (newsStructure*) malloc(sizeof(newsStructure));
													temp->col = $3;
													temp->show = $4;
													$$ = temp;
												}

colField:
	T_COL '=' T_DIGIT T_ENTER  					{$$ = $3;}

showField:
	T_SHOW '=' T_NAME otherNews T_ENTER			{$$ = concat(3,$3,";",$4);}

otherNews:
		',' T_NAME otherNews					{$$ = concat(3,$2,";",$3);}
	|											{$$ = "";}

newsDeclaration:
	newsItem newsDeclaration
	| 

newsItem:
	T_NAME '{' newsParams '}' T_ENTER   		{ 
													$3->name = strdup($1);

													char* fileName = concat(2,$1,".html");
													FILE *f = fopen(fileName,"w");
													fprintf(f,convertNewsItemToHTML($3));
													fclose(f);

													$$ = $3;
												}

newsParams:
	fieldList structureField					{
													$1->structure = $2;
													$$ = $1;	
												}

fieldList:
	titleField fieldList						{$$ = newsItemSetGet($1,"title");}
	| abstractField fieldList					{$$ = newsItemSetGet($1,"abstract");}	
	| authorField fieldList						{$$ = newsItemSetGet($1,"author");}
	| optionalDateField fieldList				{$$ = newsItemSetGet($1,"date");}
	| optionalImageField fieldList				{$$ = newsItemSetGet($1,"image");}
	| optionalSourceField fieldList				{$$ = newsItemSetGet($1,"source");}
	| optionalTextField	fieldList				{$$ = newsItemSetGet($1,"text");}
	| 											{$$ = newsItemSetGet(NULL,"");}

titleField:
	T_TITLE '=' quotedText T_ENTER 				{ $$ = concat(3,"<h2 class=\"newsTitle\">",$3,"</h2>");}

dateField:
	T_DATE '=' quotedText T_ENTER				{ $$ = concat(3,"<div class=\"newsDate\">",$3,"</div>");}

abstractField:
	T_ABSTRACT '=' quotedText T_ENTER			{ $$ = concat(3,"<div class=\"newsAbstract\">",$3,"</div>");}

authorField:
	T_AUTHOR '=' quotedText T_ENTER				{ $$ = concat(3,"<div class=\"newsAuthor\">",$3,"</div>");}

optionalDateField:
	dateField 									{ $$ = $1;}
	| 											{ $$ = "";}

optionalImageField:
	T_IMAGE '=' quotedText T_ENTER				{ $$ = concat(3,"<img class=\"newsImage\" src=\"",$3,"\">");}
	|

optionalSourceField:
	T_SOURCE '=' quotedText T_ENTER				{ $$ = concat(3,"<div class=\"newsSource\">",$3,"</div>");}
	|


optionalTextField:
	T_TEXT '=' quotedText T_ENTER				{ $$ = concat(3,"<div class=\"newsText\">",$3,"</div>");}
	|

quotedText:
	'"' listOfWords '"' 						{$$ = $2;}

listOfWords:
	  T_WORD listOfWords 						{ $$ = concat(3, $1, " ", $2);}
	| T_NAME listOfWords 						{ $$ = concat(3, $1, " ", $2);}									
	|  											{$$ = "";}												
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



