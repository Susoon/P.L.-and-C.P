#ifndef _STOD_H_
#define _STOD_H_

#include <stdio.h>

int _range(char test)
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

char * _Find_name(char * find)
{
	int i = 0;
	char * tmp = (char*)malloc(sizeof(char) * strlen(find));
	for(i = 0; _range(find[i]) ; i++)
	{
		tmp[i] = find[i];
	}
	tmp[i] = '\0';

	return tmp;
}

char * removespace(char * str)
{
	int i = 0, j = 0;
	int len = strlen(str);
	char * tmp = (char*)calloc(len, sizeof(char));
	while(j < len)
	{
		while(str[j] == ' ') { j++; }
		tmp[i] = str[j];
		i++;
		j++;
	}
	tmp[i] = '\0';

	return tmp;
}

double stod(char * str)
{
	int max, i = 0, sign = 1;
	double ret = 0, exp = 1;

	if(str[0] == '-')
	{
		sign = -1;
		i++;
	}
	else if(str[0] == '+')
	{
		sign = 1;
		i++;
	}

	max = i;
	while((str[max] >= '0' && str[max] <= '9') || (str[max] == '.')) { max++; }
	while(i < max && str[i] != '.')
	{
		ret *= 10;
		ret += (str[i] - '0');
		i++;
	}

	ret *= sign;

	if(str[i] == '\0')
		return ret;
	
	i++;
	while(i < max)
	{
		ret *= 10;
		ret += (str[i] - '0');
		exp *= 0.1;
		i++;
	}
	ret *= exp;

	return ret;
}

char * alltoneed(char *  str)
{
	int max;
	char * tmp;

	for(max = 1; str[max] != '\"'; max++);
	
	tmp = (char*)calloc(max + 2, sizeof(char));
	strcpy(tmp, str);
	tmp[max + 1] = '\0';
		
	return tmp;
}

char * iptoneed(char * str)
{
	int max;
	char * tmp;

	for(max = 1; str[max] != '*' && str[max] != '\n' && str[max] != '\0'; max++);
	
	tmp = (char*)calloc(max + 1, sizeof(char));
	strcpy(tmp, str);
	tmp[max + 1] = '\0';

	return tmp;
}

#endif
