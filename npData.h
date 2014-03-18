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