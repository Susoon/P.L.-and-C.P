%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern void yyterminate();
extern int yyerror(const char *s);

%}

%token NUMBER EOL
%left  PLUS MINUS
%left  MULT DIV

%%
/* Rules */
goal:	eval goal	{}
    |	eval		{}
	;
eval:	expr EOL	{ printf("%d\n", $1); 
    	}
	;
expr:	expr PLUS term	{ $$ = $1 + $3;
    	}
    |	expr MINUS term	{ $$ = $1 - $3;
	} 
    |	term		{ $$ = $1;
	} 
    ;
term:	term MULT factor { $$ = $1 * $3;
    	} 
    |	term DIV factor	{ $$ = $1 / $3;
	} 
    |	factor		{ $$ = $1;
	}
    ;
factor: NUMBER	{ $$ = $1;
        }
    ;

%%
/* User code */
int yyerror(const char *s)
{
	return printf("%s\n", s);
}



