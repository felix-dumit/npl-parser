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
	newspaper *newspaper;
	newsItemList *newsItemList;
}

%token <intval> T_DIGIT
%token <str> T_NAME T_WORD T_TEXT_TITLE T_QTEXT

%token <str> T_NEWSPAPER T_TITLE T_DATE T_ABSTRACT T_TEXT T_SOURCE T_IMAGE T_AUTHOR T_STRUCTURE T_ITEM 
%token <str> T_COL T_SHOW

%type <str> listOfWords titleField dateField abstractField 
%type <str> authorField optionalDateField optionalImageField optionalSourceField optionalTextField
%type <str> showField showList field NPtitleField NPdateField

%type <structure> structureField
%type <intval> colField

%type <nItem> fieldList newsParams newsItem
%type <newspaper> newspaperStructure requiredNewspaperFields

%type <newsItemList> newsDeclaration

%%

initial:
	newsItem {printf("NEWSITEM -> %s\n", $1->name);}


newspaper:
	T_NEWSPAPER '{' newspaperStructure '}'      { 
													createNewsPaperHTML($3);
												}

newspaperStructure:
	requiredNewspaperFields newsDeclaration		{ 
													newspaper *temp = $1;
													temp->newsList = $2;
													$$ = temp;
												}

requiredNewspaperFields:
	NPtitleField NPdateField structureField     {
													newspaper *temp = (newspaper*) malloc(sizeof(newspaper));
													temp->title = strdup($1);
													temp->date = strdup($2);
													temp->structure = $3;
													$$ = temp;	
												}


NPtitleField:
	T_TITLE '=' T_QTEXT 	 	 				{//printf("Title > %s\n",$3); 
													$$ = $3;}

NPdateField:
	T_DATE '=' T_QTEXT 	 						{//printf("Date > %s\n",$3); 
													$$ = $3;}



structureField:
	T_STRUCTURE '{' colField showField '}'		{
													//printf("STRUCTUREFIELD\n");
													structure *temp = (structure*) malloc(sizeof(structure));
													temp->col = $3;
													temp->show = strdup($4);
													$$ = temp;
												}

colField:
	T_COL '=' T_DIGIT  							{
													//printf("ColField-> %d",$3);
													$$ = $3;
												}

showField:
	T_SHOW '=' showList							{
													$$ = $3;
													//printf("ShowField-> %s",$3);
												}

showList:
	 showList ',' field							{//printf("showList-> %s\nNAME->%s",$1,$3);
													$$ = concat(3,$1,";",$3);}
	| field											{$$ = $1;}

field:
	T_TITLE 									{$$ = $1;}
	| T_ABSTRACT							 	{$$ = $1;}			
	| T_AUTHOR									{$$ = $1;}
	| T_DATE									{$$ = $1;}
	| T_IMAGE									{$$ = $1;}
	| T_SOURCE									{$$ = $1;}
	| T_TEXT									{$$ = $1;}


newsDeclaration:
	newsItem newsDeclaration					{
													newsItemList *new = (newsItemList*)malloc(sizeof(newsItemList));
													new->nItem = $1;
													new->next = $2;
													$$ = new;
												}
	| 											{ $$ = NULL;}

newsItem:
	T_NAME '{' newsParams '}' 			   		{ 
													//printf("NAME> %s\n",$1);
													$3->name = strdup($1);
													convertNewsItemToHTML($3);
													$$ = $3;
												}

newsParams:
	fieldList structureField					{
													newsItem *it = $1;
													it->structure = $2;
													if(it->title == NULL) yyerror("Missing Title");
													if(it->abstract == NULL) yyerror("Missing Abstract");
													if(it->author == NULL) yyerror("Missing Author");
													
													$$ = it;	
												}

fieldList:
	titleField fieldList						{////printf("TitleField> %s\n",$1);
													$$ = newsItemSetGet($1,"title");}
	| abstractField fieldList					{////printf("abstractField> %s\n",$1);
													$$ = newsItemSetGet($1,"abstract");}	
	| authorField fieldList						{////printf("authorField> %s\n",$1);
													$$ = newsItemSetGet($1,"author");}
	| optionalDateField fieldList				{////printf("optionalDateField> %s\n",$1);
													$$ = newsItemSetGet($1,"date");}
	| optionalImageField fieldList				{////printf("optionalImageField> %s\n",$1);
													$$ = newsItemSetGet($1,"image");}
	| optionalSourceField fieldList				{////printf("optionalSourceField> %s\n",$1);
													$$ = newsItemSetGet($1,"source");}
	| optionalTextField	fieldList				{////printf("optionalTextField> %s\n",$1);
													$$ = newsItemSetGet($1,"text");}
	| 											{////printf("blank\n");
													$$ = newsItemSetGet(NULL,"");}

titleField:
	T_TITLE '=' T_QTEXT 	 	 				{//printf("Title > %s\n",$3); 
													$$ = concat(3,"<h2 class=\"newsTitle\">",$3,"</h2>\n");}

dateField:
	T_DATE '=' T_QTEXT 	 						{//printf("Date > %s\n",$3); 
													$$ = concat(3,"<div class=\"newsDate\">",$3,"</div>\n");}

abstractField:
	T_ABSTRACT '=' T_QTEXT 	 					{//printf("Abstract > %s\n",$3); 
													$$ = concat(3,"<div class=\"newsAbstract\">",$3,"</div>\n");}

authorField:
	T_AUTHOR '=' T_QTEXT  						{//printf("Author > %s\n",$3); 
													$$ = concat(3,"<div class=\"newsAuthor\">",$3,"</div>\n");}

optionalDateField:
	dateField 									{//printf("OptDate > %s\n",$1); 
													$$ = $1;}

optionalImageField:
	T_IMAGE '=' T_QTEXT 	 					{//printf("OptImage > %s\n",$3); 
													$$ = concat(3,"<img class=\"newsImage\" src=\"",$3,"\">\n");}

optionalSourceField:
	T_SOURCE '=' T_QTEXT  						{//printf("OptSource > %s\n",$3); 
													$$ = concat(3,"<div class=\"newsSource\">",$3,"</div>\n");}


optionalTextField:
	T_TEXT '=' T_QTEXT 	 						{//printf("OptText > %s\n",$3); 
													$$ = concat(3,"<div class=\"newsText\">",$3,"</div>\n");}

listOfWords:
	  T_NAME listOfWords 						{ $$ = concat(3, $1, " ", $2);}									
	|  											{$$ = "";}												




%%


void yyerror(const char* errmsg)
{
	printf("\n***Error: %s\n", errmsg);
	exit();
}


int yywrap(void) { return 1; }
 
int main(int argc, char** argv)
{
     yyparse();
     return 0;
}



