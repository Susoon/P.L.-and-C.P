#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yyparse(void);
extern FILE * yyout;
FILE * yyin;
extern char * main_class;

int delete_type(char * str)
{
	int len = strlen(str), i;
	for(i = 0; i < len && str[i] != '.'; i++);
	
	return i;
}

void main(int argc, char ** argv)
{
	yyin = fopen(argv[1], "r");
	if(argv[2] == NULL)
	{
		main_class = (char*)calloc(strlen(argv[1]) + 1, sizeof(char));
	 	strcpy(main_class, argv[1]);
		main_class[delete_type(main_class)] = '\0';
		yyout = fopen(main_class, "w");
	}
	else	
	{
		yyout = fopen(argv[2], "w");
		main_class = (char*)calloc(strlen(argv[2]) + 1, sizeof(char));
		strcpy(main_class, argv[2]);
		main_class[delete_type(main_class)] = '\0';
	}
	yyparse();
	fclose(yyin);
	fclose(yyout);	
}
