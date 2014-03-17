%{
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

FILE *F;

typedef struct list_cols {
	char *col_name;
	int pos;
	struct list_cols *next;
} t_list;  
t_list *head_list;
t_list *tail_list;

char *concat(int count, ...);
char *select_col(char *table, char* cols);
void save_col_name(char *col_name);
void print_list(t_list *L);
void free_list(t_list *L);

%}
 
%union{
	char *str;
	int  *intval;
}

%token <str> T_STRING
%token T_SELECT
%token T_FROM
%token T_CREATE
%token T_TABLE
%token T_INSERT
%token T_INTO
%token T_VALUES


%type <str> create_stmt insert_stmt col_list  values_list  select_stmt col_list_insert

%start stmt_list

%error-verbose
 
%%

stmt_list: 	stmt_list stmt 
	 |	stmt 
;

stmt:
		create_stmt ';'	{printf("%s",$1);}
	|	insert_stmt ';'	{printf("%s",$1);}
	|	select_stmt ';' {printf("%s",$1);}
;

create_stmt:
	   T_CREATE T_TABLE T_STRING '(' col_list ')' 	{	F = fopen($3, "w"); 
								fprintf(F, "%s\n", $5);
								fclose(F);
								$$ = concat(5, "\nCREATE TABLE: ", $3, "\nCOL_NAME: ", $5, "\n\n");
							}
;

col_list:
		T_STRING 		{ $$ = $1; }
	| 	col_list ',' T_STRING 	{ $$ = concat(3, $1, ";", $3); }
;


insert_stmt:
	   T_INSERT T_INTO T_STRING T_VALUES '(' values_list ')' { F = fopen($3, "a"); 
								  fprintf(F, "%s\n", $6);
								  fclose(F);
								  $$ = concat(5, "\nINSERT INTO TABLE: ", $3, "\nVALUES: ", $6, "\n\n");
							 	}
;

values_list:
		T_STRING 		{ $$ = $1; }
	| 	col_list ',' T_STRING 	{ $$ = concat(3, $1, ";", $3); }
;


col_list_insert: 
		T_STRING  			{ save_col_name($1); $$ = $1; }
	| 	col_list_insert ',' T_STRING	{ save_col_name($3); $$ = concat(3, $1, ",", $3); }
;


select_stmt:
	   	T_SELECT col_list_insert T_FROM T_STRING 	{ $$ = concat(5, "\nSELECT ", $2, " FROM ", $4, ":\n"); 
								  $$ = concat(2, $$, select_col($4, "")); 
								  $$ = concat(2, $$, "\n\n");
								  free_list(head_list);
								}
																
	|	T_SELECT '*' T_FROM T_STRING 			{ $$ = concat(3, "\nSELECT '*' FROM ", $4, ":\n");
								  $$ = concat(2, $$, select_col ($4, "*"));
								  $$ = concat(2, $$, "\n\n");
								}
 
%%

void print_list(t_list *L)
{
	for (; L != NULL; L = L->next)
		printf("%s: %d\n", L->col_name, L->pos);

}

void free_list(t_list *L)
{
	t_list *tmp;
	while (L != NULL)
	{
		tmp = L->next;
		free(L);
		L = tmp;	
	}
	head_list=NULL;
	tail_list=NULL;
}

void save_col_name(char *col_name)
{	
	if (head_list == NULL)
	{
		head_list = malloc (sizeof (t_list));
		head_list->next = NULL;
		head_list->pos = 0;
		head_list->col_name = strdup( col_name);
		tail_list = head_list;
		
	} else 
	{
		tail_list->next = malloc (sizeof (t_list));
		tail_list = tail_list->next;
		tail_list->col_name = strdup(col_name);
		tail_list->next = NULL;
		tail_list->pos = 0;
	}
}

char* getfield(char *line, int num)
{
    char* tok;
    for (tok = strtok(line, ";");
            tok && *tok;
            tok = strtok(NULL, ";\n"))
    {
        if (!--num)
            return tok;
    }
   return NULL;
}

char* select_col(char *table, char* cols)
{
	F = fopen(table, "r");
	
	char *line = NULL, *s;
	size_t len = 0;
	int read, i = 0;
	t_list *L = NULL;

	char *result = "";

	if (strcmp(cols, "*") == 0)
	{
		getline(&line,&len,F); // escape first line
		while ( read = getline(&line, &len, F) != -1 )
			result = concat(2, result, line);
	} else {
		// Resolve a ordem das colunas	
		getline(&line,&len,F);
 		s = getfield(strdup(line), ++i); 
		do{
			L = head_list;
			while ( L != NULL )
			{
				if (strcmp(L->col_name,s) == 0)
				{
					L->pos = i;
					L = NULL;
				} else 
					L = L->next;
			}
			s = getfield(strdup(line), ++i);
		} while (s != NULL);

		// Imprime as colunas
		while ( read = getline(&line, &len, F) != -1 )
		{
			L = head_list;
			result = concat (2, result, getfield(strdup(line), L->pos));
			while ( (L = L->next) != NULL ) 
				result = concat( 3, result, ";", getfield(strdup(line), L->pos));
			result = concat (2, result, "\n");
		}
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


int yyerror(const char* errmsg)
{
	printf("\n*** Erro: %s\n", errmsg);
}
 
int yywrap(void) { return 1; }
 
int main(int argc, char** argv)
{
	head_list = NULL;   
	tail_list = NULL;
	yyparse();
     	return 0;
}


