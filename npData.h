#include <stdio.h>

typedef struct _structure
{
	char* col;
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

typedef struct _newsItemNode
{
	newsItem *nItem;
	struct _newsItemNode *next;
} newsItemList;

typedef struct _newspaper
{
	char *title;
	char *date;
	structure *structure;
	newsItemList *newsList;

} newspaper;