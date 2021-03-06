#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

char* tolowerStr(char* str);
char* concat(int count, ...);
char** str_split(char* a_str, const char a_delim);
char *trimwhitespace(char *str);
char* stripQuotes(char* line);
newsItem* createNewsItem();
newsItem* findNewsItem(newspaper* newspaper, char* newsItemName);
char* convertNewsItemToHTML(newsItem* ni, int newfile);
void createNewsPaperHTML(newspaper* newspaper);
void createCSS(char* col);


char* tolowerStr(char* str)
{
    int i;
    for(i=0; i<strlen(str); i++){
        str[i] = tolower(str[i]);
    }

    return str;
}

char** str_split(char* a_str, const char a_delim)
{
    char** result    = 0;
    size_t count     = 0;
    char* tmp        = a_str;
    char* last_comma = 0;
    char delim[2];
    delim[0] = a_delim;
    delim[1] = 0;

    /* Count how many elements will be extracted. */
    while (*tmp)
    {
        if (a_delim == *tmp)
        {
            count++;
            last_comma = tmp;
        }
        tmp++;
    }

    /* Add space for trailing token. */
    count += last_comma < (a_str + strlen(a_str) - 1);

    /* Add space for terminating null string so caller
       knows where the list of returned strings ends. */
    count++;

    result = malloc(sizeof(char*) * count);

    if (result)
    {
        size_t idx  = 0;
        char* token = strtok(a_str, delim);

        while (token)
        {
            //assert(idx < count);
            *(result + idx++) = strdup(token);
            token = strtok(0, delim);
        }
        //assert(idx == count - 1);
        *(result + idx) = 0;
    }

    return result;
}

char* concat(int count, ...)
{
    va_list ap;
    int len = 1, i;

    va_start(ap, count);
    for(i=0 ; i<count ; i++)
        len += strlen(va_arg(ap, char*));
    va_end(ap);

    char *result = (char*) calloc(sizeof(char),len);
    int pos = 0;

    // Actually concatenate strings
    va_start(ap, count);
    for(i=0 ; i<count ; i++)
    {
        char *s = va_arg(ap, char*);
        strcpy(result+pos, s);
        pos += strlen(s);
    }
    va_end(ap);

    return result;
}

char *trimwhitespace(char *str)
{
  char *end;

  // Trim leading space
  while(isspace(*str)) str++;

  if(*str == 0)  // All spaces?
    return str;

  // Trim trailing space
end = str + strlen(str) - 1;
while(end > str && isspace(*end)) end--;

  // Write new null terminator
*(end+1) = 0;

return str;
}

char* stripQuotes(char* line){
    char* stripped = strdup(line);
    if(stripped[0] == '"') stripped = stripped +  1;
    if(stripped[strlen(stripped) -1] == '"') stripped[strlen(stripped) -1] = '\0';
    return stripped;
}

newsItem* newsItemSetGet(char* string, char* fieldName){
    static newsItem* staticItem = NULL;
    extern int createNewNewsItem;

    if(staticItem == NULL || createNewNewsItem) {
        staticItem = createNewsItem();
        createNewNewsItem = 0;
    }
    
    if(strcmp(fieldName,"title") == 0)
    {
        if(staticItem->title != NULL) yyerror("Duplicate title tag");   
        staticItem->title = strdup(string);
    }
    else if(strcmp(fieldName,"abstract") == 0)
    { 
        if(staticItem->abstract != NULL) yyerror("Duplicate abstract tag");
        staticItem->abstract = strdup(string);
    }
    else if(strcmp(fieldName,"author") == 0)
    {
        if(staticItem->author != NULL) yyerror("Duplicate author tag");     
        staticItem->author = strdup(string);
    }
    else if(strcmp(fieldName,"date") == 0)
    {   
        if(staticItem->date != NULL) yyerror("Duplicate date tag");     
        staticItem->date = strdup(string);
    }
    else if(strcmp(fieldName,"text") == 0)
    { 
        if(staticItem->text != NULL) yyerror("Duplicate text tag");         
        staticItem->text = strdup(string);
    }
    else if(strcmp(fieldName,"source") == 0)
    {
        if(staticItem->source != NULL) yyerror("Duplicate source tag");
        staticItem->source = strdup(string);
    }
    else if(strcmp(fieldName,"image") == 0)
    {
        if(staticItem->image != NULL) yyerror("Duplicate image tag");   
        staticItem->image = strdup(string);
    }
    return staticItem;                                              
}

newsItem* createNewsItem(){
    newsItem* temp = (newsItem*) malloc(sizeof(newsItem));
    temp->title = NULL;
    temp->abstract = NULL;
    temp->author = NULL;
    temp->date = NULL;
    temp->text = NULL;
    temp->source = NULL;
    temp->image = NULL;
    temp->structure = NULL;
    return temp;
}

char* convertNewsItemToHTML(newsItem* ni, int newfile){

    char** showList = str_split(strdup(ni->structure->show),';');
    int i;

    char* html = concat(3, "\t\t<div class=\"col", strdup(ni->structure->col),"\">\n\t\t\t<div class=\"newsItem\">\n\t\t\t\t");

    for(i=0; showList[i];i++){
        if(strcmp(showList[i],"title") == 0 && strlen(ni->title) > 0){
            if( ni->text != NULL && !newfile){
                html = concat(4, html, "<a href=\"", strdup(ni->name),".html\">");
            }
            html = concat(2,html,strdup(ni->title));
            if( ni->text != NULL && !newfile){
                html = concat(2, html, "</a>\n");
            }
        }
        else if(strcmp(showList[i],"abstract") == 0 && strlen(ni->abstract) > 0)
            if(newfile)      html = concat(2,html,strdup(ni->text));
            else             html = concat(2,html,strdup(ni->abstract)); 
        else if(strcmp(showList[i],"author") == 0 && strlen(ni->author) > 0)
            html = concat(2,html,strdup(ni->author));
        else if(strcmp(showList[i],"date") == 0 && strlen(ni->date) > 0)
            html = concat(2,html,strdup(ni->date));
        //else if(strcmp(showList[i],"text") == 0 && strlen(ni->text) > 0)
        else if(strcmp(showList[i],"source") == 0 && strlen(ni->source) > 0)
            html = concat(2,html,strdup(ni->source));
        else if(strcmp(showList[i],"image") == 0 && strlen(ni->image) > 0)
            html = concat(2,html,strdup(ni->image));
    }  

    html = concat(2, html, "\t\t\t</div>\n\t\t</div>\n\n\n");

    return html;
}

void createNewsPaperHTML(newspaper* newspaper){

    char* html = concat(3,"<!DOCTYPE html>\n<html>\n<meta charset=\"utf-8\">\n<head><title>", newspaper->title,
        "</title>\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"mystyle.css\">\n\t"
        "<link rel=\"stylesheet\" type=\"text/css\" href=\"colwidth.css\">\n</head>\n");


    html = concat(6, html, "<body>\n\n\n\t<h1 class=\"newspaperTitle\">", newspaper->title, 
        "\n\t\t<span class=\"newspaperDate\">",newspaper->date, "\t</span>\n\t</h1>\n");

    html = concat(4, html, "\n\t<div id=\"container\" class=\"col", newspaper->structure->col,"\">\n");
    char** showList = str_split(newspaper->structure->show,';');

    int i;
    for(i=0; showList[i]; i++){
        newsItem* item = findNewsItem(newspaper, showList[i]);
        char* newsHTML = convertNewsItemToHTML(item, 0);
        html = concat(2, html, newsHTML);
    }

    html = concat(2,html,"</div>\n</body>\n</html>\n");
    FILE* f = fopen("newspaper/newspaper.html","w");
    fprintf(f,"%s",html);
    fclose(f);

    createCSS(newspaper->structure->col);
}

void createCSS(char* col){
    FILE* f = fopen("newspaper/colwidth.css", "w");

    int i;
    for(i=1; i<= atoi(col); i++){
        fprintf(f, "#container > div.col%d{width: calc(%d * 100%% / %d);}\n\n", i, i, atoi(col));
    }

}




newsItem* findNewsItem(newspaper* newspaper, char* newsItemName){
    newsItemList* p = newspaper->newsList;
    do
    {
        printf("NEWSITEM:%s\n", p->nItem->name);
        if(strcmp(p->nItem->name, newsItemName) == 0){
            return p->nItem;
        }
        p = p->next;
    }
    while(p);

    yyerror(concat(2, newsItemName," not found"));
    return NULL;
}
