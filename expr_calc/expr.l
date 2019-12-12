%{
#include <stdlib.h>
#include <string.h>

#include "expr.tab.h"

extern int yyerror(const char*);
%}

NUMBER [+-]?[0-9]+
ID [a-zA-Z]+
SPACE [ \t\r\n]+

%%


{NUMBER} { yylval = atoi(yytext);
	return NUMBER;
}

"+"	{ return PLUS; 
}

"-"	{ return MINUS;
}

"*"	{ return MULT; 
}

"/"	{ return DIV;
}

";"	{ return EOL;
}

{SPACE} { /* ignore */ 
}

.	{  printf("%d\n", yytext[0]);
           yyerror("unexpected input"); 
}


%%
/* User code */




