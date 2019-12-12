#ifndef __FIND_DATA_H_
#define __FIND_DATA_H_

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

static int range(char test);
static char * Find_name(char * test);
int Find_var_index(char* find, char * id_name[]);
int Find_fun_index(char* find, char * fun_name[]);
int Find_class_index(char* find, char * class_name[]);
int Find_class_type_index(char* find, char * class_type[]);
int Var_Save(char* var, double num, int tp, char* id_name[], double data[], int type[]);
int Fun_Save(char* var, int tp, char* fun_name[], int type[]);
int Class_Save(char* var, char* tp, char* class_name[], char* type[]);
int Class_type_Save(char * tp, char * type[]);

int range(char test)
{
	if(test >= '0' && test <= '9')
		return 1;
	else if(test >= 'A' && test <= 'Z')
		return 1;
	else if(test >= 'a' && test <= 'z')
		return 1;
	else if(test == '_')
		return 1;
	else
		return 0;
}

char * Find_name(char * find)
{
	int i = 0;
	char * tmp = (char*)malloc(sizeof(char) * strlen(find));
	for(i = 0; range(find[i]) ; i++)
	{
		tmp[i] = find[i];
	}
	tmp[i] = '\0';

	return tmp;
}

int Find_var_index(char* find, char * id_name[])
{
	int i, ret;
	char * tmp = (char*)malloc(sizeof(char) * strlen(find));
	for(i = 0; range(find[i]) ; i++)
	{
		tmp[i] = find[i];
	}
	tmp[i] = '\0';

	for(i = 0; id_name[i] != 0; i++)
	{
		if(strcmp(tmp, id_name[i]) == 0)
		{
			free(tmp);
			return i;
		}
	}

	free(tmp);

	return -1;
}

int Find_fun_index(char* find, char * fun_name[])
{
	int i, ret;
	char * tmp = (char*)malloc(sizeof(char) * strlen(find));
	for(i = 0; range(find[i]) ; i++)
	{
		tmp[i] = find[i];
	}
	tmp[i] = '\0';

	for(i = 0; fun_name[i] != 0; i++)
	{
		if(strcmp(tmp, fun_name[i]) == 0)
		{
			free(tmp);
			return i;
		}
	}

	free(tmp);

	return -1;
}

int Find_class_index(char* find, char * class_name[])
{
	int i, ret;
	char * tmp = (char*)malloc(sizeof(char) * strlen(find));
	for(i = 0; range(find[i]) ; i++)
	{
		tmp[i] = find[i];
	}
	tmp[i] = '\0';

	for(i = 0; class_name[i] != 0; i++)
	{
		if(strcmp(tmp, class_name[i]) == 0)
		{
			free(tmp);
			return i;
		}
	}

	free(tmp);

	return -1;
}

int Find_class_type_index(char* find, char * class_type[])
{
	int i, ret;
	char * tmp = (char*)malloc(sizeof(char) * strlen(find));
	for(i = 0; range(find[i]) ; i++)
	{
		tmp[i] = find[i];
	}
	tmp[i] = '\0';

	for(i = 0; class_type[i] != 0; i++)
	{
		if(strcmp(tmp, class_type[i]) == 0)
		{
			free(tmp);
			return i;
		}
	}

	free(tmp);

	return -1;
}

int Var_Save(char* var, double num, int tp, char* id_name[], double data[], int type[])
{
	int idx = Find_var_index(var, id_name);
	char * tmp = (char*)malloc(sizeof(char) * strlen(var));
	
	if(idx == -1)
	{
		int i, j;
		for(i = 0; id_name[i] != 0; i++);
		
		for(j = 0; range(var[j]); j++)
		{
			tmp[j] = var[j];
		}
		tmp[j] = '\0';
		
		id_name[i] = (char*)malloc(sizeof(char) * strlen(var));
		strcpy(id_name[i], tmp);

		data[i] = num;
		
		type[i] = tp;

		free(tmp);

		return i;
	}
	
	data[idx] = num;

	free(tmp);

	return idx;
}
		
int Fun_Save(char* var, int tp, char* fun_name[], int type[])
{
	int idx = Find_fun_index(var, fun_name);
	char * tmp; 
	if(idx == -1)
	{
		int i, j;
		for(i = 0; fun_name[i] != 0; i++);
		if(strcmp(var, "System.out.println") == 0)
		{
			tmp = (char*)calloc(strlen(var) + 1, sizeof(char));
			strcpy(tmp, var);
		}
		else
			tmp = Find_name(var);
		
		fun_name[i] = (char*)malloc(sizeof(char) * strlen(var));
		strcpy(fun_name[i], tmp);

		type[i] = tp;

		free(tmp);

		return i;
	}
	
	free(tmp);

	return idx;
}

int Class_Save(char* var, char* tp, char* class_name[], char* type[])
{
	int idx = Find_class_index(var, class_name);
	char * tmp = (char*)malloc(sizeof(char) * strlen(var));
	
	if(idx == -1)
	{
		int i, j;
		for(i = 0; class_name[i] != 0; i++);

		for(j = 0; range(var[j]); j++)
		{
			tmp[j] = var[j];
		}
		tmp[j] = '\0';
		
		class_name[i] = (char*)malloc(sizeof(char) * strlen(var));
		strcpy(class_name[i], tmp);
		
		type[i] = (char*)malloc(sizeof(char) * strlen(tp));
		strcpy(type[i], tp);

		free(tmp);

		return i;
	}
	
	free(tmp);

	return idx;
}

int Class_type_Save(char * tp, char * type[])
{
	int idx = Find_class_type_index(tp, type);
	char * tmp = (char*)malloc(sizeof(char) * strlen(tp));
	
	if(idx == -1)
	{
		int i, j;
		for(i = 0; type[i] != 0; i++);

		for(j = 0; range(tp[j]); j++)
		{
			tmp[j] = tp[j];
		}
		tmp[j] = '\0';
		
		type[i] = (char*)malloc(sizeof(char) * strlen(tp));
		strcpy(type[i], tmp);
		
		free(tmp);

		return i;
	}
	
	free(tmp);

	return -1;
}

#endif
