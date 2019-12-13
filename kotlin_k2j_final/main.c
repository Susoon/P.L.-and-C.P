#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yyparse(void);
extern FILE * yyout;
FILE * yyin;
extern char * main_class;

void find_filename(char * str, int * start, int *end)
{
	int len = strlen(str), i = 0;
	for(i = len; i >= 0 && str[i] != '/'; i--);
	*start = i + 1;
	for(i = 0; i < len; i++)
	{
		if(str[i] == '.' && str[i + 1] == '.')
			i += 2;
		else if(str[i] == '.' && str[i + 1] != '.')
		{
			break;
		}
	}
	*end = i;
}

void main(int argc, char ** argv)
{
	int start = 0, end = 0;
	yyin = fopen(argv[1], "r");
	if(argv[2] == NULL)
	{
		find_filename(argv[1], &start, &end);
		main_class = (char*)calloc(strlen(argv[1]) + 10, sizeof(char));
		strcpy(main_class, argv[1] + start);
		end -= start + 1;
		main_class[end + 1] = '.';
		main_class[end + 2] = 'j';
		main_class[end + 3] = 'a';
		main_class[end + 4] = 'v';
		main_class[end + 5] = 'a';
		main_class[end + 6] = '\0';
		yyout = fopen(main_class, "w");
		main_class[end + 1] = '\0';
		
	}
	else	
	{
		yyout = fopen(argv[2], "w");
		find_filename(argv[2], &start, &end);
		main_class = (char*)calloc(strlen(argv[2] + start) + 1, sizeof(char));
		strcpy(main_class, argv[2] + start);
		end -= start;
		main_class[end] = '\0';
	}
	yyparse();
	fclose(yyin);
	fclose(yyout);	
}
