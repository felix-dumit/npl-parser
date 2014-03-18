#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>



char* concat(int count, ...);
char** str_split(char* a_str, const char a_delim);
char *trimwhitespace(char *str);


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
