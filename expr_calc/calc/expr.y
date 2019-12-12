%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "find_data.h"

extern int yylex(void);
extern void yyterminate();
extern int yyerror(const char *s);

char * var_name[100] = { 0 };
double data[100] = { 0 };
int idx = 0;

%}
%union { double d_var; int i_var; char* c_var;}

%type <d_var> eval
%type <d_var> expr
%type <d_var> term
%type <d_var> factor
%type <d_var> signed_factor

%token <d_var> NUMBER
%token <i_var> EOL
%token <c_var> ID

%left  EQUAL
%left  PLUS MINUS
%left  MULT DIV
%left  OPEN CLOSE

%%
/* Rules */
goal:	eval goal	{}
    |	eval		{}
	;
eval:	expr EOL	{ printf("%lf\n", $1); 
    	}
    |	ID EQUAL eval	{ Save($1, $3, var_name, data);
	}
    ;
expr:	expr PLUS term	{ $$ = $1 + $3;
    	}
    |	expr MINUS term	{ $$ = $1 - $3;
	}
    |	term		{ $$ = $1;
	} 
    ;
term:	term MULT signed_factor { $$ = $1 * $3;
    	} 
    |	term DIV signed_factor	{ $$ = $1 / $3;
	} 
    |	signed_factor	{ $$ = $1;
	}
    ;
signed_factor:	PLUS factor { $$ = $2;
	     	}
    |	MINUS factor { $$ = -1 * $2;
	}
    |	factor { $$ = $1;
	}
    ;
factor: NUMBER	{ $$ = $1;
        }
    |	ID 	{ idx = Find_index($1, var_name);
		  $$ = data[idx];
	}
    |	OPEN expr CLOSE { $$ = $2;
	}
    ;

%%
/* User code */
int yyerror(const char *s)
{
	return printf("%s\n", s);
}




