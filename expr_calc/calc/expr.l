%{
#include <stdlib.h>
#include <string.h>

#include "stod.h"
#include "expr.tab.h"

extern int yyerror(const char*);
%}

NUMBER [0-9]+[.]?[0-9]*
ID [a-zA-Z]+[a-zA-z0-9_]*
SPACE [ \t\r\n]+

%%


{NUMBER} { yylval.d_var = stod(yytext);
	return NUMBER;
}

{ID} { yylval.c_var = yytext;	
	return ID;
}

")"	{ return CLOSE;
}

"("	{ return OPEN;
}

"+"	{ return PLUS; 
}

"-"	{ return MINUS;
}

"*"	{ return MULT; 
}

"/"	{ return DIV;
}

"="	{ return EQUAL;
}

";"	{ return EOL;
}

{SPACE} { /* ignore */ 
}

.	{  printf("%lf\n", (double)yytext[0]);
           yyerror("unexpected input"); 
}


%%
/* User code */




