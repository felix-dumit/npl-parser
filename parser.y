%{
#include "npData.h"
#include <stdio.h>
#include "helpers.h"

int yywrap(void);

int createNewNewsItem = 1;

%}

%union{
	char *str;
	int intval;
	structure *structure;
	newsItem *nItem;
	newspaper *newspaper;
	newsItemList *newsItemList;
}

%token <str> T_DIGIT
%token <str> T_NAME T_WORD T_TEXT_TITLE T_QTEXT

%token <str> T_NEWSPAPER T_TITLE T_DATE T_ABSTRACT T_TEXT T_SOURCE T_IMAGE T_AUTHOR T_STRUCTURE T_ITEM 
%token <str> T_COL T_SHOW

%type <str> titleField abstractField 
%type <str> authorField optionalDateField optionalImageField optionalSourceField optionalTextField
%type <str> showField showList field NPtitleField NPdateField NPshowField nameList

%type <structure> structureField NPstructureField
%type <str> colField

%type <nItem> fieldList newsParams newsItem
%type <newspaper> newspaperStructure requiredNewspaperFields

%type <newsItemList> newsDeclaration

%%

initial:
	newspaper {printf("NEWSPAPER DONE!\n");}


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
	NPtitleField NPdateField NPstructureField     {
													newspaper *temp = (newspaper*) malloc(sizeof(newspaper));
													temp->title = strdup($1);
													temp->date = strdup($2);
													temp->structure = $3;
													$$ = temp;	
												}


NPtitleField:
	T_TITLE '=' T_QTEXT 	 	 				{//printf("Title > %s\n",$3); 
													$$ = strdup($3);}

NPdateField:
	T_DATE '=' T_QTEXT 	 						{//printf("Date > %s\n",$3); 
													$$ = strdup($3);}

NPstructureField:
	T_STRUCTURE '{' colField NPshowField '}'	{
													structure *temp = (structure*) malloc(sizeof(structure));
													temp->col = strdup($3);
													temp->show = strdup($4);
													$$ = temp;
												}

NPshowField:
	T_SHOW '=' nameList							{$$ = strdup($3);}

nameList:
	nameList ',' T_NAME							{$$ = concat(3,$1,";",$3);}
	|T_NAME										{$$ = $1;}

colField:
	T_COL '=' T_DIGIT  							{
													//printf("ColField-> %s",$3);
													$$ = strdup($3);
												}

structureField:
	T_STRUCTURE '{' colField showField '}'		{
													//printf("STRUCTUREFIELD\n");
													structure *temp = (structure*) malloc(sizeof(structure));
													temp->col = $3;
													temp->show = strdup($4);
													$$ = temp;
												}

showField:
	T_SHOW '=' showList							{
													$$ = strdup($3);
													//printf("ShowField-> %s",$3);
												}

showList:
	 showList ',' field							{//printf("showList-> %s\nNAME->%s",$1,$3);
													$$ = concat(3,$1,";",$3);}
	| field											{$$ = strdup($1);}

field:
	T_TITLE 									{$$ = strdup($1);}
	| T_ABSTRACT							 	{$$ = strdup($1);}			
	| T_AUTHOR									{$$ = strdup($1);}
	| T_DATE									{$$ = strdup($1);}
	| T_IMAGE									{$$ = strdup($1);}
	| T_SOURCE									{$$ = strdup($1);}
	| T_TEXT									{$$ = strdup($1);}


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
													
													char* html = "<html>\n<meta charset=\"utf-8\">\n<body>\n";
													char* newsHTML = convertNewsItemToHTML($3);

													html = concat(3,html, newsHTML, "</body></html>");

													FILE* f = fopen(concat(3,"newspaper/", $1,".html"),"w");
													fprintf(f,"%s",html);
													fclose(f);
													
													createNewNewsItem = 1;
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

abstractField:
	T_ABSTRACT '=' T_QTEXT 	 					{//printf("Abstract > %s\n",$3); 
													$$ = concat(3,"<div class=\"newsAbstract\">",$3,"</div>\n");}

authorField:
	T_AUTHOR '=' T_QTEXT  						{//printf("Author > %s\n",$3); 
													$$ = concat(3,"<div class=\"newsAuthor\">",$3,"</div>\n");}

optionalDateField:
	T_DATE '=' T_QTEXT  						{//printf("OptDate > %s\n",$1); 
													$$ = concat(3,"<div class=\"newsDate\">",$3,"</div>\n");}

optionalImageField:
	T_IMAGE '=' T_QTEXT 	 					{//printf("OptImage > %s\n",$3); 
													$$ = concat(3,"<img class=\"newsImage\" src=\"",$3,"\"\\>\n");}

optionalSourceField:
	T_SOURCE '=' T_QTEXT  						{//printf("OptSource > %s\n",$3); 
													$$ = concat(3,"<div class=\"newsSource\">",$3,"</div>\n");}


optionalTextField:
	T_TEXT '=' T_QTEXT 	 						{//printf("OptText > %s\n",$3); 
													$$ = concat(3,"<div class=\"newsText\">",$3,"</div>\n");}



%%


int yywrap(void) { return 1; }
 
int main(int argc, char** argv)
{
     yyparse();
     return 0;
}



