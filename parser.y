%{
#include "npData.h"
#include <stdio.h>
#include "helpers.h"

void yyerror(const char* errmsg);
int yywrap(void);

newsItem* newsItemSetGet(char* string, char* fieldName);
void convertNewsItemToHTML(newsItem* ni);

%}

%union{
	char *str;
	int intval;
	structure *structure;
	newsItem *nItem;
}

%token <intval> T_DIGIT
%token <str> T_NAME T_WORD T_TEXT_TITLE
%token T_ENTER

%token T_NEWSPAPER T_TITLE T_DATE T_ABSTRACT T_TEXT T_SOURCE T_IMAGE T_AUTHOR T_STRUCTURE T_ITEM 
%token T_COL T_SHOW

%type <str> comment listOfWords quotedText titleField dateField abstractField 
%type <str> authorField optionalDateField optionalImageField optionalSourceField optionalTextField
%type <str> showField otherNews

%type <structure> structureField
%type <intval> colField

%type <nItem> fieldList newsParams newsItem

%%

initial:
	newsItem {printf("NEWSITEM -> %s\n", $1->name);}

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
													structure *temp = (structure*) malloc(sizeof(structure));
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
	T_NAME '{' T_ENTER newsParams T_ENTER '}' T_ENTER   		{ 
													printf("NAME> %s\n",$1);
													$4->name = strdup($1);
													convertNewsItemToHTML($4);
													$$ = $4;
												}

newsParams:
	fieldList structureField					{
													newsItem *it = $1;
													it->structure = $2;
													$$ = it;	
												}

fieldList:
	titleField fieldList						{printf("TitleField> %s\n",$1);$$ = newsItemSetGet($1,"title");}
	| abstractField fieldList					{printf("abstractField> %s\n",$1);$$ = newsItemSetGet($1,"abstract");}	
	| authorField fieldList						{printf("authorField> %s\n",$1);$$ = newsItemSetGet($1,"author");}
	| optionalDateField fieldList				{printf("optionalDateField> %s\n",$1);$$ = newsItemSetGet($1,"date");}
	| optionalImageField fieldList				{printf("optionalImageField> %s\n",$1);$$ = newsItemSetGet($1,"image");}
	| optionalSourceField fieldList				{printf("optionalSourceField> %s\n",$1);$$ = newsItemSetGet($1,"source");}
	| optionalTextField	fieldList				{printf("optionalTextField> %s\n",$1);$$ = newsItemSetGet($1,"text");}
	| 											{printf("blank");$$ = newsItemSetGet(NULL,"");}

titleField:
	T_TITLE '=' quotedText T_ENTER 				{printf("Title > %s\n",$3); $$ = concat(3,"<h2 class=\"newsTitle\">",$3,"</h2>");}

dateField:
	T_DATE '=' quotedText T_ENTER				{printf("Date > %s\n",$3); $$ = concat(3,"<div class=\"newsDate\">",$3,"</div>");}

abstractField:
	T_ABSTRACT '=' quotedText T_ENTER			{printf("Abstract > %s\n",$3); $$ = concat(3,"<div class=\"newsAbstract\">",$3,"</div>");}

authorField:
	T_AUTHOR '=' quotedText T_ENTER				{printf("Author > %s\n",$3); $$ = concat(3,"<div class=\"newsAuthor\">",$3,"</div>");}

optionalDateField:
	dateField 									{printf("OptDate > %s\n",$1); $$ = $1;}

optionalImageField:
	T_IMAGE '=' quotedText T_ENTER				{printf("OptImage > %s\n",$3); $$ = concat(3,"<img class=\"newsImage\" src=\"",$3,"\">");}

optionalSourceField:
	T_SOURCE '=' quotedText T_ENTER				{printf("OptSource > %s\n",$3); $$ = concat(3,"<div class=\"newsSource\">",$3,"</div>");}


optionalTextField:
	T_TEXT '=' quotedText T_ENTER				{printf("OptText > %s\n",$3); $$ = concat(3,"<div class=\"newsText\">",$3,"</div>");}

quotedText:
	'"' listOfWords '"' 						{printf("QuotedText>>> %s\n",$2); $$ = $2;}

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



