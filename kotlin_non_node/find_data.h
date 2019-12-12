#ifndef __FIND_H_
#define __FIND_H_

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

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

int Find_var_index(char* find, char * var_name[])
{
	int i, ret;
	char * tmp = (char*)malloc(sizeof(char) * 100);
	for(i = 0; range(find[i]) ; i++)
	{
		tmp[i] = find[i];
	}
	tmp[i] = '\0';

	for(i = 0; var_name[i] != 0; i++)
	{
		if(strcmp(tmp, var_name[i]) == 0)
		{
			free(tmp);
			return i;
		}
	}

	free(tmp);

	return -1;
}

int Find_Fun_index(char* find, char * fun_name[])
{
	int i, ret;
	char * tmp = (char*)malloc(sizeof(char) * 100);
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

int Var_Save(char* var, double num, int tp, char* var_name[], double data[], int type[])
{
	int idx = Find_var_index(var, var_name);
	char * tmp = (char*)malloc(sizeof(char) * 100);
	if(idx != -1 && tp != type[idx])
		return -1;
	if(idx == -1)
	{
		int i, j;
		for(i = 0; var_name[i] != 0; i++);

		for(j = 0; range(var[j]); j++)
		{
			tmp[j] = var[j];
		}
		tmp[j] = '\0';
		
		var_name[i] = (char*)malloc(sizeof(char) * 100);
		strcpy(var_name[i], tmp);

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
	int idx = Find_Fun_index(var, fun_name);
	char * tmp = (char*)malloc(sizeof(char) * 100);
	
	if(idx == -1)
	{
		int i, j;
		for(i = 0; fun_name[i] != 0; i++);

		for(j = 0; range(var[j]); j++)
		{
			tmp[j] = var[j];
		}
		tmp[j] = '\0';
		
		fun_name[i] = (char*)malloc(sizeof(char) * 100);
		strcpy(fun_name[i], tmp);

		type[i] = tp;

		free(tmp);

		return i;
	}
	
	free(tmp);

	return -1;
}

#endif
