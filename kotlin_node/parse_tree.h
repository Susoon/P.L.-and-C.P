#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char * class_type_name[1000];
int class_type_num = 0;

/*Type value
 * Not_defined : 0,INT : 1, LONG : 2, FLOAT : 3
 * DOUBLE : 4, STRING : 5, CHAR : 6, BOOL : 7
 * UNIT : 8, ANY : 9
 * const : +10, question : +20, list : + 30, class_fun : +100*/

typedef struct parse_node
{
	char * name;
	int type;
	int token_type;
	char * classtype;
	double data;
	char * token_name;
	struct parse_node *child;
	struct parse_node *next;
	struct parse_node *prev;
	struct parse_node *parent;
}NODE;

NODE * root;
NODE * curr;

static int Find_Class_Type_Name(char * class_type);

NODE * make_id_node(char * id_name, int id_type, double id_data, char * id_token_name);
NODE * make_fun_node(char * fun_name, int fun_type, char * fun_token_name);
NODE * make_class_node(char * class_name, char * classtype, char* class_token_name);
NODE * make_nt_node(char* nt_token_name);
NODE * make_token_node(char * token_token_name);

void Add_Last(NODE * tmp);
void Add_Child(NODE * parent, NODE * child);
void Print_Tree();

NODE * make_id_node(char * id_name, int id_type, double id_data, char * id_token_name)
{
	NODE * tmp = (NODE*)malloc(sizeof(NODE));
	tmp -> name = (char*)calloc(strlen(id_name), sizeof(char));
	strcpy(tmp -> name, id_name);
	tmp -> type = id_type;
	tmp -> token_type = 1;
	tmp -> data = id_data;
	tmp -> token_name = (char*)calloc(strlen(id_token_name), sizeof(char));
	strcpy(tmp -> token_name, id_token_name);
	tmp -> parent = NULL;
	tmp -> child = NULL;
	tmp -> next = NULL;
	tmp -> prev = NULL;

	return tmp;
}

NODE * make_fun_node(char * fun_name, int fun_type, char * fun_token_name)
{
	NODE * tmp = (NODE*)malloc(sizeof(NODE));
	tmp -> name = (char*)calloc(strlen(fun_name),sizeof(char));
	strcpy(tmp -> name, fun_name);
	tmp -> type = fun_type;
	tmp -> token_type = 2;
	tmp -> token_name = (char*)calloc(strlen(fun_token_name),sizeof(char));
	strcpy(tmp -> token_name, fun_token_name);
	tmp -> parent = NULL;
	tmp -> child = NULL;
	tmp -> next = NULL;
	tmp -> prev = NULL;

	return tmp;
}

NODE * make_class_node(char * class_name, char * class_type, char* class_token_name)
{
	NODE * tmp = (NODE*)malloc(sizeof(NODE));
	tmp -> name = (char*)calloc(strlen(class_name),sizeof(char));
	strcpy(tmp -> name, class_name);
	tmp -> classtype = (char*)calloc(strlen(class_type), sizeof(char));
	strcpy(tmp -> classtype, class_type);
	tmp -> token_name = (char*)calloc(strlen(class_token_name),sizeof(char));
	strcpy(tmp -> token_name, class_token_name);
	tmp -> token_type = 3;
	tmp -> parent = NULL;
	tmp -> child = NULL;
	tmp -> next = NULL;
	tmp -> prev = NULL;

	int idx = Find_Class_Type_Name(class_token_name);

	if(idx == -1)
	{
		class_type_name[class_type_num] = (char*)calloc(strlen(class_token_name), sizeof(char));
		strcpy(class_type_name[class_type_num], class_token_name);
		class_type_num++;
	}

	return tmp;
}

NODE * make_nt_node(char* nt_token_name)
{
	NODE * tmp = (NODE*)malloc(sizeof(NODE));
	tmp -> token_name = (char*)calloc(strlen(nt_token_name),sizeof(char));
	strcpy(tmp -> token_name, nt_token_name);
	tmp -> token_type = 0;
	tmp -> parent = NULL;
	tmp -> child = NULL;
	tmp -> next = NULL;
	tmp -> prev = NULL;

	return tmp;
}

NODE * make_token_node(char * token_token_name)
{
	NODE * tmp = (NODE*)malloc(sizeof(NODE));
	tmp -> token_name = (char*)calloc(strlen(token_token_name),sizeof(char));
	strcpy(tmp -> token_name, token_token_name);
	tmp -> token_type = -1;
	tmp -> parent = NULL;
	tmp -> child = NULL;
	tmp -> next = NULL;
	tmp -> prev = NULL;

	return tmp;
}

int Find_Class_Type_Name(char * class_type)
{
	for(int i = 0; i < class_type_num; i++)
	{
		if(strcmp(class_type_name[i], class_type) == 0)
			return i;
	}
	
	return -1;
}

void Add_Last(NODE * tmp)
{
	curr -> next = tmp;
	tmp -> prev = curr;
	tmp -> parent = curr -> parent;
	curr = tmp;
}

void Add_Child(NODE * parent, NODE * child)
{
	parent -> child = child;
	child -> parent = parent;
	curr = child;
}

void Print_Tree(NODE * parent, int blank)
{
	for(int i = 0; i < blank; i++)
		printf("  ");
	printf("%s <- [ ", parent -> token_name);
	
	NODE * tmp = parent -> child;
	
	while(tmp != NULL)
	{
		printf("%s ", tmp -> token_name);
		tmp = tmp -> next;
	}
	printf("]\n");

	tmp = parent -> child;

	while(tmp != NULL)
	{
		Print_Tree(tmp, blank + 1);
		tmp = tmp -> next;
	}
}

