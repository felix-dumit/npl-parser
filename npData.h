#include <stdio.h>

typedef struct _structure
{
	int col;
	char *show;
} structure;


typedef struct _newsItem 
{
	char *name;
	char *title;
	char *abstract;
	char *author;
	structure *structure;
	char *date;
	char *image;
	char *source;
	char *text;
} newsItem;

/*

newsItem* duplicateNewsItem(newsItem* oldItem){
	newsItem *item = (newsItem*) malloc(sizeof(newsItem));
	item->title = strdup(oldItem->title);
	item->abstract = strdup(oldItem->abstract);
	item->author = strdup(oldItem->author);
	item->date = strdup(oldItem->date);
	item->text = strdup(oldItem->text);
	item->text = strdup(oldItem->text);
	item->source = strdup(oldItem->source);
	item->image = strdup(oldItem->image);

	if(oldItem->structure == NULL) item->structure = NULL;
	
}

typedef struct np{
	char *title;
	char *date;
	structure *structure;


	
} t_list;  

struct list_name {
	char* name;
	struct list_name *next;
};


t_list *head_list;
t_list *tail_list;

*/