typedef struct structure
{
	int col;
	char *show;
} newsStructure;


typedef struct nItem 
{
	char *name;
	char *title;
	char *abstract;
	char *author;
	newsStructure *structure;
	char *date;
	char *image;
	char *source;
	char *text;
}newsItem;


newsItem* newsItemSetGet(char* string, char* fieldName);
char* convertNewsItemToHTML(newsItem* ni);



newsItem* newsItemSetGet(char* string, char* fieldName){
	static newsItem* staticItem = NULL;

	if(staticItem == NULL) staticItem = (newsItem*) malloc(sizeof(newsItem));
	
	if(strcmp(fieldName,"title") == 0) staticItem->title = strdup(string);
	else if(strcmp(fieldName,"abstract") == 0) staticItem->abstract = strdup(string);
	else if(strcmp(fieldName,"author") == 0) staticItem->author = strdup(string);
	else if(strcmp(fieldName,"date") == 0) staticItem->date = strdup(string);
	else if(strcmp(fieldName,"text") == 0) staticItem->text = strdup(string);
	else if(strcmp(fieldName,"source") == 0)staticItem->source = strdup(string);
	else if(strcmp(fieldName,"image") == 0)staticItem->image = strdup(string);
	
	return staticItem;												
}

char* convertNewsItemToHTML(newsItem* ni){
	return "noticiaAAaaaaAAAAa";
}

/*
typedef struct np{
	char *title;
	char *date;
	newsStructure *structure;


	
} t_list;  

struct list_name {
	char* name;
	struct list_name *next;
};


t_list *head_list;
t_list *tail_list;

*/