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

int Find_index(char* find, char * var_name[])
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

void Save(char* var, double num, char* var_name[], double data[])
{
	int idx = Find_index(var, var_name);
	char * tmp = (char*)malloc(sizeof(char) * 100);
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

		free(tmp);

		return;
	}
	
	data[idx] = num;

	free(tmp);

	return;
}
		
#endif
