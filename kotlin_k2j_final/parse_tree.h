#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "find_data.h"

#define decl_with_no_type -100
#define NOT_SPACE -20
#define NEED_SPACE -10
#define NEED -1
#define NOT_NEED -2
#define NEED_NOW -3
#define Not_defined 0
#define Char 1
#define Bool 2
#define Int 3
#define Long 4
#define Float 5
#define Double 6
#define String 7
#define Unit 8
#define Any 9
#define Const 10
#define Question 20
#define List 30
#define C_fun 100
#define Class 200
#define Classtype 300


FILE * yyout;

char * id_name[1000] = { 0 };
char * fun_name[1000] = { 0 };
double data[1000] = { 0 };
int id_type[1000] = { 0 };
int fun_type[1000] = { 0 };
char * class_type[1000] = { 0 };
char * class_name[1000] = { 0 };

typedef struct parse_node
{
	char * name;
	int type;
	int token_type;
	int space;
	char * classtype;
	double data;
	struct parse_node *child;
	struct parse_node *next;
	struct parse_node *prev;
	struct parse_node *parent;
}NODE;

NODE * root;
NODE * curr;



static int Find_Class_Type_Name(char * class_type, char ** class_type_name);
static void Print_Enter(char * token);
char * ttos(int type);

NODE * make_id_node(char * id_name, int id_type, double id_data);
NODE * make_fun_node(char * fun_name, int fun_type);
NODE * make_class_node(char * class_name, char * classtype);
NODE * make_class_type_node(char * classtype);
NODE * make_nt_node();
NODE * make_token_node(char * token_token_name, int needspace);

void Add_Last(NODE * tmp, int needsemicolumn);
void Add_Child(NODE * parent, NODE * child, int needsemicolumn);
void Print_Tree(NODE * parent, int blank);
void Print_Stt(NODE * parent);

NODE * make_id_node(char * id_name, int id_type, double id_data)
{
	NODE * tmp = (NODE*)malloc(sizeof(NODE));
	tmp -> name = (char*)calloc(strlen(id_name) + 1, sizeof(char));
	strcpy(tmp -> name, id_name);
	tmp -> type = id_type;
	tmp -> token_type = 1000;
	tmp -> data = id_data;
	tmp -> parent = NULL;
	tmp -> child = NULL;
	tmp -> next = NULL;
	tmp -> prev = NULL;

	return tmp;
}

NODE * make_fun_node(char * fun_name, int fun_type)
{
	NODE * tmp = (NODE*)malloc(sizeof(NODE));
	tmp -> name = (char*)calloc(strlen(fun_name) + 1,sizeof(char));
	strcpy(tmp -> name, fun_name);
	tmp -> type = fun_type;
	tmp -> token_type = 1000;
	tmp -> parent = NULL;
	tmp -> child = NULL;
	tmp -> next = NULL;
	tmp -> prev = NULL;

	return tmp;
}

NODE * make_class_node(char * class_name, char * class_type)
{
	NODE * tmp = (NODE*)malloc(sizeof(NODE));
	tmp -> name = (char*)calloc(strlen(class_name) + 1, sizeof(char));
	strcpy(tmp -> name, class_name);
	if(class_type != NULL)
	{
		tmp -> classtype = (char*)calloc(strlen(class_type) + 1, sizeof(char));
		strcpy(tmp -> classtype, class_type);
	}
	else
		tmp -> classtype = NULL;
	tmp -> token_type = 1000;
	tmp -> parent = NULL;
	tmp -> child = NULL;
	tmp -> next = NULL;
	tmp -> prev = NULL;

	return tmp;
}

NODE * make_class_type_node(char * class_type)
{
	NODE * tmp = (NODE*)malloc(sizeof(NODE));
	tmp -> name = (char*)calloc(strlen(class_type) + 1,sizeof(char));
	strcpy(tmp -> name, class_type);
	tmp -> classtype = (char*)calloc(strlen(class_type) + 1, sizeof(char));
	strcpy(tmp -> classtype, class_type);
	tmp -> token_type = 1000;
	tmp -> parent = NULL;
	tmp -> child = NULL;
	tmp -> next = NULL;
	tmp -> prev = NULL;

	return tmp;
}

NODE * make_nt_node()
{
	NODE * tmp = (NODE*)malloc(sizeof(NODE));
	tmp -> token_type = 0;
	tmp -> name = NULL;
	tmp -> parent = NULL;
	tmp -> child = NULL;
	tmp -> next = NULL;
	tmp -> prev = NULL;

	return tmp;
}

NODE * make_token_node(char * token_token_name, int needspace)
{
	NODE * tmp = (NODE*)malloc(sizeof(NODE));
	if(token_token_name != NULL)
	{
		tmp -> name = (char*)calloc(strlen(token_token_name) + 1,sizeof(char));
		strcpy(tmp -> name, token_token_name);
	}
	else
		tmp -> name = NULL;
	tmp -> token_type = 1000;
	tmp -> space = needspace;
	tmp -> parent = NULL;
	tmp -> child = NULL;
	tmp -> next = NULL;
	tmp -> prev = NULL;

	return tmp;
}

int Find_Class_Type_Name(char * class_type, char ** class_type_name)
{
	for(int i = 0; class_type_name[i] != 0; i++)
	{
		if(strcmp(class_type_name[i], class_type) == 0)
			return i;
	}
	
	return -1;
}

void Add_Last(NODE * tmp, int needsemicolumn)
{
	curr -> next = tmp;
	tmp -> prev = curr;
	tmp -> parent = curr -> parent;
	curr = tmp;
	if(tmp -> token_type == 0)
		tmp -> token_type += needsemicolumn;
}

void Add_Child(NODE * parent, NODE * child, int needsemicolumn)
{
	parent -> child = child;
	child -> parent = parent;
	curr = child;
	if(child -> token_type == 0)
		child -> token_type += needsemicolumn;
}

void Print_Tree(NODE * parent, int blank)
{
	if(parent -> child == NULL)
		return;	
	NODE * tmp = parent -> child;

	while(tmp != NULL)
	{
		if(tmp -> name != NULL)
		{
			if(tmp -> type == decl_with_no_type)
			{
				int tmp_idx = Find_var_index(tmp -> name, id_name);
		 		printf("%s ", ttos(id_type[tmp_idx])); 
			}
			if(tmp -> token_type == 1000)
			{
				printf("%s ", tmp -> name);
				fprintf(yyout, "%s ", tmp -> name);
			}
			if(tmp -> space == NOT_SPACE)
			{
				fseek(yyout, -1, SEEK_CUR);
				printf("\b");
			}
			if(tmp -> token_type == NEED_NOW)
			{
				fprintf(yyout, ";\n");
				printf(";\n");
			}
			if(tmp -> name[0] == '/' && tmp -> name[1] == '/')
			{
				fprintf(yyout, "\n");
				printf("\n");
			}
		}
		Print_Tree(tmp, blank);
		if(tmp -> token_type == NEED)
		{
			fprintf(yyout, ";\n");
			printf(";\n");
		}
		tmp = tmp -> next;
	}

}

char * ttos(int type)
{
	char * tmp = (char*)calloc(10, sizeof(char));
	strcpy(tmp, "");
	switch(type)
	{
	case Int:
		strcpy(tmp, "int");
		return tmp;
	case Long:
		strcpy(tmp, "long");
		return tmp;
	case Float:
		strcpy(tmp, "float");
		return tmp;
	case Double:
		strcpy(tmp, "double");
		return tmp;
	case String:
		strcpy(tmp, "String");
		return tmp;
	case Char:
		strcpy(tmp, "char");
		return tmp;
	case Bool:
		strcpy(tmp, "bool");
		return tmp;
	case Unit:
		strcpy(tmp, "void");
		return tmp;
	case Any:
		strcpy(tmp, "Object");
		return tmp;
	case List + Int:
		strcpy(tmp, "List<int>");
		return tmp;
	case List + Long:
		strcpy(tmp, "List<long>");
		return tmp;
	case List + Float:
		strcpy(tmp, "List<float>");
		return tmp;
	case List + Double:
		strcpy(tmp, "List<double>");
		return tmp;
	case List + String:
		strcpy(tmp, "List<String>");
		return tmp;
	case List + Char:
		strcpy(tmp, "List<char>");
		return tmp;
	case List + Bool:
		strcpy(tmp, "List<Bool>");
		return tmp;
	case Question + Int:
		strcpy(tmp, "Integer");
		return tmp;
	case Question + Long:
		strcpy(tmp, "Long");
		return tmp;
	case Question + Float:
		strcpy(tmp, "Float");
		return tmp;
	case Question + Double:
		strcpy(tmp, "Double");
		return tmp;
	case Question + String:
		strcpy(tmp, "String");
		return tmp;
	case Question + Char:
		strcpy(tmp, "Char");
		return tmp;
	case Question + Bool:
		strcpy(tmp, "Bool");
		return tmp;
	case Question + Any:
		strcpy(tmp, "Object");
		return tmp;
	default:
		strcpy(tmp, "");
		return tmp;
	}
}
