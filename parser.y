%{
#include "npData.h"
#include <stdio.h>
#include "helpers.h"

int yywrap(void);

int createNewNewsItem = 1;

%}

%union{
	char *str;
	structure *structure;
	newsItem *nItem;
	newspaper *newspaper;
	newsItemList *newsItemList;
}

/* Terminal Tokens */ 
%token <str> T_DIGIT
%token <str> T_NAME T_WORD T_TEXT_TITLE T_QTEXT
%token <str> T_NEWSPAPER T_TITLE T_DATE T_ABSTRACT T_TEXT T_SOURCE T_IMAGE T_AUTHOR T_STRUCTURE T_ITEM 
%token <str> T_COL T_SHOW

/* Non Terminal Tokens */
%type <str> titleField abstractField 
%type <str> authorField optionalDateField optionalImageField optionalSourceField optionalTextField
%type <str> showField showList field NPtitleField NPdateField NPshowField nameList
%type <str> colField

%type <structure> structureField NPstructureField

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
	NPtitleField NPdateField NPstructureField   {
													newspaper *temp = (newspaper*) malloc(sizeof(newspaper));
													temp->title = strdup($1);
													temp->date = strdup($2);
													temp->structure = $3;
													$$ = temp;	
												}


NPtitleField:
	T_TITLE '=' T_QTEXT 	 	 				{	$$ = strdup($3);	}

NPdateField:
	T_DATE '=' T_QTEXT 	 						{	$$ = strdup($3);	}

NPstructureField:
	T_STRUCTURE '{' colField NPshowField '}'	{
													structure *temp = (structure*) malloc(sizeof(structure));
													temp->col = strdup($3);
													temp->show = strdup($4);
													$$ = temp;
												}

NPshowField:
	T_SHOW '=' nameList							{	$$ = strdup($3);	}

nameList:
	nameList ',' T_NAME							{	$$ = concat(3,$1,";",$3);	}
	|T_NAME										{	$$ = $1;	}

colField:
	T_COL '=' T_DIGIT  							{	$$ = strdup($3);	}

structureField:
	T_STRUCTURE '{' colField showField '}'		{
													structure *temp = (structure*) malloc(sizeof(structure));
													temp->col = $3;
													temp->show = strdup($4);
													$$ = temp;
												}

showField:
	T_SHOW '=' showList							{	$$ = strdup($3);	}

showList:
	 showList ',' field							{	$$ = concat(3,$1,";",$3);	}
	| field										{	$$ = strdup($1);	}

field:
	T_TITLE 									{	$$ = strdup($1);	}
	| T_ABSTRACT							 	{	$$ = strdup($1);	}			
	| T_AUTHOR									{	$$ = strdup($1);	}
	| T_DATE									{	$$ = strdup($1);	}
	| T_IMAGE									{	$$ = strdup($1);	}
	| T_SOURCE									{	$$ = strdup($1);	}
	| T_TEXT									{	$$ = strdup($1);	}


newsDeclaration:
	newsItem newsDeclaration					{
													newsItemList *new = (newsItemList*)malloc(sizeof(newsItemList));
													new->nItem = $1;
													new->next = $2;
													$$ = new;
												}
	| 											{	$$ = NULL;	}

newsItem:
	T_NAME '{' newsParams '}' 			   		{ 
													$3->name = strdup($1);
													
													createNewNewsItem = 1;

													$$ = $3;

													if($3->text){
														char* html = concat(3,"<!DOCTYPE html>\n<html>\n<meta charset=\"utf-8\">\n<head><title>", 
															$3->title,"</title>\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"mystyle.css\">\n\t"
														        "\n</head>\n");

														char* newsHTML = convertNewsItemToHTML($3, 1);
														html = concat(3,html, newsHTML, "</body></html>");

														FILE* f = fopen(concat(3,"newspaper/", $1,".html"),"w");
														fprintf(f,"%s",html);
														fclose(f);
													}

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
	titleField fieldList						{	$$ = newsItemSetGet($1,"title");	}
	| abstractField fieldList					{	$$ = newsItemSetGet($1,"abstract");	}	
	| authorField fieldList						{	$$ = newsItemSetGet($1,"author");	}
	| optionalDateField fieldList				{	$$ = newsItemSetGet($1,"date");		}
	| optionalImageField fieldList				{	$$ = newsItemSetGet($1,"image");	}
	| optionalSourceField fieldList				{	$$ = newsItemSetGet($1,"source");	}
	| optionalTextField	fieldList				{	$$ = newsItemSetGet($1,"text");		}
	| 											{	$$ = newsItemSetGet(NULL,"");		}

titleField:
	T_TITLE '=' T_QTEXT 	 	 				{	
													$$ = concat(3,"<h2 class=\"newsTitle\">\n\t\t\t\t\t",$3,
																"\n\t\t\t\t</h2>");
												}

abstractField:
	T_ABSTRACT '=' T_QTEXT 	 					{	
													$$ = concat(3,"\t\t\t\t<div class=\"newsAbstract\">\n\t\t\t\t\t",$3,
																"\n\t\t\t\t</div>\n");
												}

authorField:
	T_AUTHOR '=' T_QTEXT  						{	
													$$ = concat(3,
													"\t\t\t\t<div class=\"newsAuthor\">\n\t\t\t\t\t<b>Author: </b>",
													$3,"\n\t\t\t\t</div>\n");
												}

optionalDateField:
	T_DATE '=' T_QTEXT  						{	
													$$ = concat(3,"\t\t\t\t<div class=\"newsDate\">\n\t\t\t\t\t",$3,
																"\n\t\t\t\t</div>\n");
												}

optionalImageField:
	T_IMAGE '=' T_QTEXT 	 					{	
													$$ = concat(3,"\t\t\t\t<div class=\"figure\"><img class=\"newsImage\" src=\"",
																$3,"\"\\></div>\n");
												}

optionalSourceField:
	T_SOURCE '=' T_QTEXT  						{
													$$ = concat(3,
														"\t\t\t\t<div class=\"newsSource\">\n\t\t\t\t\t<b>Source: </b>",
														$3,"\n\t\t\t\t</div>\n");
												}


optionalTextField:
	T_TEXT '=' T_QTEXT 	 						{
													$$ = concat(3,"\t\t\t\t<div class=\"newsText\">\n\t\t\t\t\t",$3,
														"\n\t\t\t\t</div>\n");
												}



%%


int yywrap(void) { return 1; }
 
int main(int argc, char** argv)
{
     yyparse();
     return 0;
}



