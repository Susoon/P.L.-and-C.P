%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "find_data.h"

extern int yylex(void);
extern void yyterminate();
extern int yyerror(const char *s);

char * var_name[1000] = { 0 };
char * fun_name[1000] = { 0 };
double data[1000] = { 0 };
//Type value - 0 : Not_defined 1 : INT, 2 : LONG, 3 : FLOAT, 4 : DOUBLE, 5 : STRING, 6 : CHAR, 7 : BOOL, const : +10
int var_type[100] = { 0 }; 
//Type value - 0 : Not_defined 1 : INT, 2 : LONG, 3 : FLOAT, 4 : DOUBLE, 5 : STRING, 6 : CHAR, 7 : BOOL, 8 : UNIT, 9 : ANY, const : +10, question : +20, class_fct : +100
int fun_type[100] = { 0 };
char * class_type[1000] = { 0 };
char * class_name[1000] = { 0 };
int var_idx = 0, fun_idx = 0, err = 0, tmp_blank, tmp_blank, tmp_idx;

int Check_Type_Saved(char * name);
int Check_Type_Not_Saved(double value);
void Print_Blank(double n);

%}

%union { double d_var; float f_var; int i_var; long l_var; char* s_var; char c_var; char** sp_var}

%type <d_var> start
%type <d_var> eval
%type <d_var> expr
%type <d_var> term
%type <d_var> factor
%type <d_var> signed_factor
%type <d_var> id_decl
%type <d_var> id_decl_stt
%type <d_var> fun_body
%type <d_var> loop_body
%type <d_var> cf_body
%type <d_var> withelse
%type <d_var> noelse
%type <d_var> when_body
%type <d_var> param
%type <d_var> type
%type <d_var> epsilone
%type <d_var> com
%type <d_var> range
%type <d_var> condition
%type <d_var> is_condition
%type <d_var> fun_stt
%type <d_var> while_stt
%type <d_var> for_stt
%type <d_var> if_stt
%type <d_var> when_stt
%type <d_var> cal_sent
%type <d_var> step_count
%type <d_var> ret_type
%type <d_var> decl_content
%type <d_var> list_content
%type <d_var> else_part
%type <d_var> fun_call
%type <d_var> argument
%type <d_var> main_fun
%type <d_var> mul_argument
%type <d_var> assign
%type <d_var> cf
%type <d_var> when_id
%type <d_var> when_condition
%type <d_var> lambda
%type <d_var> class_id_decl
%type <d_var> class_decl
%type <d_var> class_method_decl
%type <d_var> class_stt
%type <d_var> inheritance
%type <d_var> c_inheritance
%type <d_var> generic
%type <d_var> var_decl
%type <d_var> val_decl
%type <d_var> fun_type
%type <d_var> class_param
%type <d_var> class_keyword

%token <l_var> L_NUMBER
%token <d_var> NUMBER
%token <s_var> STR
%token <d_var> PACK
%token <d_var> FUNC
%token <d_var> VAL
%token <d_var> VAR
%token <d_var> IMPORT
%token <d_var> IF
%token <d_var> ELSEIF
%token <d_var> ELSE
%token <d_var> NUL
%token <d_var> RETURN
%token <d_var> FOR
%token <d_var> WHILE
%token <d_var> WHEN
%token <d_var> IS
%token <d_var> IN
%token <d_var> DOWNTO
%token <d_var> STEP
%token <d_var> LISTOF
%token <d_var> LIST
%token <i_var> INT
%token <i_var> FLOAT
%token <i_var> LONG
%token <i_var> DOUBLE
%token <i_var> STRING
%token <i_var> CHAR
%token <i_var> BOOL
%token <i_var> ANY
%token <i_var> UNIT
%token <d_var> MAIN
%token <s_var> ID
%token <s_var> COMMENT
%token <s_var> COMMENT_LONG
%token <i_var> ABST
%token <i_var> CLASS
%token <i_var> OVER
%token <d_var> INTER

%left  M_OPEN M_CLOSE
%left  COMMA ARROW
%left  EQUAL E_PLUS E_MINUS E_MULT E_DIV
%left  OR
%left  AND
%left  B_OR
%left  B_XOR
%left  B_AND
%left  SAME NOT_SAME
%left  DOUBLEDOT
%left  E_LESS E_GREATER GREATER LESS
%left  L_SHIFT R_SHIFT
%left  PLUS MINUS
%left  MULT DIV
%left  INC DEC
%left  COLUMN
%left  DOT NOT QUESTION
%left  OPEN CLOSE B_OPEN B_CLOSE
%left  CALL
%left  STRING INT FLOAT DOUBLE CHAR

%%

/* Rules */
goal:	start
    	{
		Print_Blank($1);
		printf("goal <- start\n");
	}
    ;
start:	IMPORT start	
	{
		Print_Blank($2);
		printf("start <- IMPORT start\n");
		$$ = $2 + 1;
	}
    |	PACK start 
    	{
		Print_Blank($2);
		printf("start <- PACK start\n");
		$$ = $2 + 1;
	}
    |	eval
	{ 
		Print_Blank($1);
		printf("start <- eval\n");
		$$ = $1 + 1;
	}
    ;
eval:	expr eval	
    	{
		if($1 > $2)
			tmp_blank = $1;
		else
			tmp_blank = $2;
		Print_Blank(tmp_blank);
		printf("eval <- expr eval\n");
		$$ = tmp_blank + 1; 
    	}
    |	expr	
	{
		Print_Blank($1);
		printf("eval <- expr\n");
		$$ = $1 + 1;
	}
    |	main_fun eval
	{
		if($1 > $2)
			tmp_blank = $1;
		else
			tmp_blank = $2;
		Print_Blank(tmp_blank);
		printf("expr <- mainfun eval\n");
		$$ = tmp_blank + 1;
	}
    ;
expr:	for_stt
 	{ 
		Print_Blank($1);
		printf("expr <- for_stt\n");
		$$ = $1 + 1;
	}	
    |	while_stt	
	{
		Print_Blank($1);
		printf("expr <- while_stt\n");
		$$ = $1;
	}
    |	if_stt	
	{ 
		Print_Blank($1);
		printf("expr <- if_stt\n");
		$$ = $1 + 1;
	}
    |	when_stt
	{ 
		Print_Blank($1);
		printf("expr <- when_stt\n");
		$$ = $1 + 1;
	}
    |	var_decl
	{
		Print_Blank($1);
		printf("expr <- var_decl\n");
		$$ = $1 + 1;
	}
    |	val_decl
	{ 
		Print_Blank($1);
		printf("expr <- val_decl\n");
		$$ = $1 + 1;
	}
    |	cal_sent	
	{ 
		Print_Blank($1);
		printf("expr <- cal_sent\n");
		$$ = $1 + 1;
	}
    |	fun_stt		
	{ 
		Print_Blank($1 + 1);
		printf("expr <- fun_stt\n");
		printf("\n\n");
		$$ = $1;
	}
    |	com
	{
		Print_Blank($1);
		printf("expr <- comment\n");
		$$ = $1 + 1;
		printf("\n\n");
	}
    |	ID assign cal_sent
	{
		if($2 > $3)
			tmp_blank = $2;
		else
			tmp_blank = $3;	
		Print_Blank(tmp_blank);
		printf("expr <- ID assign cal_sent\n");
		$$ = tmp_blank + 1;
	}
    |	ID EQUAL STR
	{
		Print_Blank(0);
		printf("expr <- ID EQUAL STR\n");
		$$ = 1;
	}
    |	ID lambda
	{
		Print_Blank($2);
		printf("expr <- ID lambda\n");
		$$ = $2;
	}
    |	class_stt
	{
		Print_Blank($1);
		printf("expr <- class_stt\n");
		$$ = $1;
	}
    |	epsilone
	{
		/*empty*/
	}
    ;
generic:	GREATER type LESS
		{
			Print_Blank($2);
			printf("generic <- GREATER type LESS\n");
			$$ = $2;
		}
	;
class_stt:	ABST CLASS ID OPEN class_param CLOSE c_inheritance M_OPEN class_decl M_CLOSE
	  	{
			tmp_blank = ($5 > $7) ? $5 : $7;
			tmp_blank = (tmp_blank > $9) ? tmp_blank : $9;
			Print_Blank(tmp_blank);
			printf("class_stt <- ABST CLASS ID OPEN param CLOSE c_inheritance M_OPEN class_decl M_CLOSE\n");
			$$ = tmp_blank + 1;
		}
	|	CLASS ID OPEN class_param CLOSE c_inheritance M_OPEN class_decl M_CLOSE
	  	{
			tmp_blank = ($4 > $6) ? $4 : $6;
			tmp_blank = (tmp_blank > $8) ? tmp_blank : $8;
			Print_Blank(tmp_blank);
			printf("class_stt <- CLASS ID OPEN param CLOSE c_inheritance M_OPEN class_decl M_CLOSE\n");
			$$ = tmp_blank + 1;
		}
	|	INTER ID M_OPEN class_decl M_CLOSE
	  	{
			Print_Blank($4);
			printf("class_stt <- INTER ID M_OPEN class_decl M_CLOSE\n");
			$$ = $4 + 1;
		}
	;
val_decl:	VAL id_decl_stt
	    	{
			Print_Blank($2);
			printf("val_decl <- VAL id_decl_stt\n");
			$$ = $2 + 1;
		}
	;
var_decl:	VAR id_decl_stt
	    	{
			Print_Blank($2);
			printf("var_decl <- VAR id_decl_stt\n");
			$$ = $2 + 1;
		}
	;
class_keyword:	OVER
	     	{
			Print_Blank(0);
			printf("class_keyword <- OVER\n");
			$$ = 1;
		}
	|	ABST
		{
			Print_Blank(0);
			printf("class_keyword <- ABST\n");
			$$ = 1;
		}
	|	epsilone
		{
			/*empty*/
		}
	;	
class_id_decl:	class_keyword var_decl
	     	{
			Print_Blank($2);
			printf("class_id_decl <- class_keyword var_decl\n");
			$$ = $2 + 1;
		}
	|	class_keyword val_decl
	     	{
			Print_Blank($2);
			printf("class_id_decl <- class_keyword val_decl\n");
			$$ = $2 + 1;
		}
	;
class_decl:	class_id_decl class_decl
	  	{
			tmp_blank = ($1 > $2) ? $1 : $2;
			Print_Blank(tmp_blank);
			printf("class_decl <- class_id_decl class_decl\n");
			$$ = tmp_blank + 1;
		}
	|	class_method_decl class_decl
	  	{
			tmp_blank = ($1 > $2) ? $1 : $2;
			Print_Blank(tmp_blank);
			printf("class_decl <- class_method_decl class_decl\n");
			$$ = tmp_blank + 1;
		}
	|	class_id_decl
	  	{
			Print_Blank($1);
			printf("class_decl <- class_id_decl\n");
			$$ = $1 + 1;
		}
	|	class_method_decl
	  	{
			Print_Blank($1);
			printf("class_decl <- class_method_decl\n");
			$$ = $1 + 1;
		}
	;
class_method_decl:	class_keyword fun_stt
		 	{
				tmp_blank = ($1 > $2) ? $1 : $2;
				Print_Blank(tmp_blank);
				printf("class_method_decl <- class_keyword fun_stt\n");
				$$ = tmp_blank + 1;
			}
	;
c_inheritance:	COLUMN inheritance
	     	{
			Print_Blank($2);
			printf("c_inheritance <- COLUMN inheritance\n");
			$$ = $2 + 1;
		}
	|	epsilone
		{
			/*empty*/
		}
	;
inheritance:	fun_call COMMA inheritance
	   	{
			tmp_blank = ($3 > $1) ? $3 : $1;
			Print_Blank(tmp_blank);
			printf("inheritance <- fun_call COMMA inheritance\n");
			$$ = tmp_blank + 1;
		}
	|	ID COMMA inheritance
		{
			Print_Blank($3);
			printf("inheritance <- ID COMMA inheritance\n");
			$$ = $3 + 1;
		}
	|	ID
		{
			Print_Blank(0);
			printf("inheritance <- ID\n");
			$$ = 1;
		}
	|	fun_call
		{
			Print_Blank($1);
			printf("inheritance <- fun_call\n");
			$$ = $1 + 1;
		}
	;
lambda: DOT ID M_OPEN cal_sent M_CLOSE lambda
      	{
		tmp_blank = ($4 > $6) ? $4 : $6;
		Print_Blank(tmp_blank);
		printf("lambda <- DOT ID M_OPEN cal_sent M_CLOSE lambda\n");
		$$ = tmp_blank;
	}
    |	epsilone
	{
		/*empty*/
	}
    ;
assign:	EQUAL
      	{
		Print_Blank(0);
		printf("assign <- EQUAL\n");
		$$ = 1;
	}
    |	E_PLUS
      	{
		Print_Blank(0);
		printf("assign <- E_PLUS\n");
		$$ = 1;
	}
    |	E_MINUS
      	{
		Print_Blank(0);
		printf("assign <- E_MINUS\n");
		$$ = 1;
	}
    |	E_MULT
      	{
		Print_Blank(0);
		printf("assign <- E_MULT\n");
		$$ = 1;
	}
    |	E_DIV
      	{
		Print_Blank(0);
		printf("assign <- E_DIV\n");
		$$ = 1;
	}
    ;
main_fun: FUNC MAIN OPEN CLOSE fun_body
	{
		Print_Blank($5);
		printf("main_fun <- FUNC MAIN OPEN CLOSE fun_body\n");
		printf("\n\n");
		$$ = $5 + 1;
	}
    ;
cal_sent: cal_sent PLUS term	
       	  {	
		tmp_blank = ($1 > $3) ? $1 : $3;
		Print_Blank(tmp_blank);
		printf("cal_sent <- cal_sent PLUS term\n");
		$$ = tmp_blank + 1;
	  }
    |	  cal_sent MINUS term
	  {
		tmp_blank = ($1 > $3) ? $1 : $3;
		Print_Blank(tmp_blank);
		printf("cal_sent <- cal_sent MINUS term\n");
		$$ = tmp_blank + 1;
	  }
    |	  term			
	  { 
		Print_Blank($1);
		printf("cal_sent <- term\n");
		$$ = $1 + 1;
	  }
    ;
term:	term MULT signed_factor 
    	{ 
		tmp_blank = ($1 > $3) ? $1 : $3;
		Print_Blank(tmp_blank);
		printf("term <- term MULT signed_factor\n");
		$$ = tmp_blank + 1;
    	} 
    |	term DIV signed_factor	
	{ 
		tmp_blank = ($1 > $3) ? $1 : $3;
		Print_Blank(tmp_blank);
		printf("term <- term DIV signed_factor\n");
		$$ = tmp_blank + 1;
	} 
    |	signed_factor	
	{ 
		Print_Blank($1);
		printf("term <- signed_factor\n");
		$$ = $1 + 1;
	}
    ;
signed_factor:	PLUS factor 
	     	{ 
			Print_Blank($2);
			printf("signed_factor <- PLUS factor\n");
			$$ = $2 + 1;
	     	}
	|    	MINUS factor 
		{ 
			Print_Blank($2);
			printf("signed_factor <- MINUS factor\n");
			$$ = $2 + 1;
		}
    	|	factor 
		{ 
			Print_Blank($1);
			printf("signed_factor <- factor\n");
			$$ = $1 + 1;
		}
    ;
factor: NUMBER	
      	{
		Print_Blank(0);
		printf("factor <- NUMBER\n");
		$$ = 1;
        }
    |	L_NUMBER	
      	{
		Print_Blank(0);
		printf("factor <- L_NUMBER\n");
		$$ = 1;
	}
    |	ID 	
	{ 
		Print_Blank(0);
		printf("factor <- ID\n");
		//var_idx = Find_var_index($1, var_name);
		//$$ = data[var_idx];
		$$ = 1;
	}
    |	ID DOT fun_call 
	{ 
		Print_Blank($3);
		printf("factor <- ID DOT fun_call\n");
		//var_idx = Find_var_index($1, var_name);
		//$$ = data[var_idx];
		$$ = $3 + 1;
	}	
    |	ID DOT ID
	{ 
		Print_Blank(0);
		printf("factor <- ID DOT ID\n");
		//var_idx = Find_var_index($1, var_name);
		//$$ = data[var_idx];
		$$ = 1;
	}
    |	ID INC
	{ 
		Print_Blank(0);
		printf("factor <- ID INC\n");
		//var_idx = Find_var_index($1, var_name);
		//$$ = data[var_idx];
		$$ = 1;
	}
    |	ID DEC
	{ 
		Print_Blank(0);
		printf("factor <- ID DEC\n");
		//var_idx = Find_var_index($1, var_name);
		//$$ = data[var_idx];
		$$ = 1;	
	}
    |	INC ID
	{ 
		Print_Blank(0);
		printf("factor <- INC ID\n");
		//var_idx = Find_var_index($1, var_name);
		//$$ = data[var_idx];
		$$ = 1;
	}
    |	DEC ID
	{ 
		Print_Blank(0);
		printf("factor <- DEC ID\n");
		//var_idx = Find_var_index($1, var_name);
		//$$ = data[var_idx];
		$$ = 1;
	}
    |	OPEN cal_sent CLOSE 
	{ 
		Print_Blank($2);
		printf("factor <- OPEN cal_sent CLOSE\n");
		$$ = $2 + 1;
	}
    |	fun_call
	{ 
		Print_Blank($1);
		printf("factor <- fun_call\n");
		$$ = $1 + 1;
	}
    |	NUL	
	{ 
		Print_Blank(0);
		printf("factor <- NULL\n");
		$$ = 1;
	}
    ;
param:	ID COLUMN fun_type COMMA param 
     	{ 
		tmp_blank = ($3 > $5)? $3 : $5; 
		Print_Blank(tmp_blank);
		printf("param <- ID COLUMN fun_type COMMA param\n");
		$$ = tmp_blank + 1;	
     	}
    |	ID COLUMN fun_type		
	{
		Print_Blank($3);
		printf("param <- ID COLUMN fun_type\n");
		$$ = $3 + 1;
	}
    |	epsilone
	{
		/*empty*/
	}
    ;
class_param:	VAL id_decl COMMA class_param
	    	{
			tmp_blank = ($2 > $4) ? $2 : $4;
			Print_Blank(tmp_blank);
			printf("class_param <- VAR id_decl COMMA class_param\n");
			$$ = tmp_blank + 1;
		}
	|	VAR id_decl COMMA class_param
	    	{
			tmp_blank = ($2 > $4) ? $2 : $4;
			Print_Blank(tmp_blank);
			printf("class_param <- VAR id_decl COMMA class_param\n");
			$$ = tmp_blank + 1;
		}
	|	VAL id_decl
	    	{
			Print_Blank($2);
			printf("class_param <- VAL id_decl\n");
			$$ = $2 + 1;
		}
	|	VAR id_decl
	    	{
			Print_Blank($2);
			printf("class_param <- VAR id_decl\n");
			$$ = $2 + 1;
		}
	|	epsilone
		{
			/*empty*/
		}
	;
type:	INT	
    	{
		Print_Blank(0);
		printf("type <- INT\n");
		$$ = 1;
    	}
    |	LONG
    	{
		Print_Blank(0);
		printf("type <- LONG\n");
		//$$ = 2;
		$$ = 1;
    	}
    |	FLOAT	
	{ 
		Print_Blank(0);
		printf("type <- FLOAT\n");
		//$$ = 3;
		$$ = 1;
	}
    |	DOUBLE	
	{ 
		Print_Blank(0);
		printf("type <- DOUBLE\n");
		//$$ = 4;
		$$ = 1;
	}
    |	STRING	
	{ 
		Print_Blank(0);
		printf("type <- STRING\n");
		//$$ = 5;
		$$ = 1;
	}
    |	CHAR	
	{ 
		Print_Blank(0);
		printf("type <- CHAR\n");
		//$$ = 6;
		$$ = 1;
	}
    |	BOOL
	{
		Print_Blank(0);
		printf("type <- BOOL\n");
		//$$ = 7;
		$$ = 1;
	}
    |	LIST generic
	{
		Print_Blank($2);
		printf("type <- LIST generic\n");
		$$ = $2 + 1;
	}
    ;
fun_type:	type
	  	{
			Print_Blank($1);
			printf("fun_type <- type\n");
			$$ = $1 + 1;
		}
	|
	  	UNIT	
		{ 
			Print_Blank(0);
			printf("fun_type <- UNIT\n");
			//$$ = 7;
			$$ = 1;
		}
    	|	ANY	
		{ 
			Print_Blank(0);
			printf("fun_type <- ANY\n");
			//$$ = 8;
			$$ = 1;
		}
    	;
fun_stt:  FUNC ID OPEN param CLOSE ret_type fun_body 
       	{
		tmp_blank = ($4 > $6)? $4 : $6;
		tmp_blank = (tmp_blank > $7) ? tmp_blank : $7;
		Print_Blank(tmp_blank);
		printf("fun_stt <- FUNC ID OPEN param CLOSE ret_type fun_body\n");
		$$ = tmp_blank + 1;
      	}
    ;
ret_type: COLUMN type QUESTION 
	{
		Print_Blank($2);
		printf("ret_type <- COLUMN type QUESTION\n");
		//$$ = $2;
		$$ = $2 + 1;
	}
    |	  COLUMN fun_type
	{
		Print_Blank($2);
		printf("ret_type <- COLUMN fun_type\n");
		//$$ = $2 + 20;
		$$ = $2;
	}
    |	 epsilone
	{
		/*empty*/
	}
    ;
fun_body: M_OPEN eval RETURN cal_sent M_CLOSE	
	{
		tmp_blank = ($2 > $4) ? $2 : $4;
		Print_Blank(tmp_blank);
		printf("fun_body <- M_OPEN eval RETURN cal_sent M_CLOSE\n");
		$$ = tmp_blank + 1;
	}
    |	 M_OPEN eval RETURN M_CLOSE	
	{
		Print_Blank($2);
		printf("fun_body <- M_OPEN eval RETURN M_CLOSE\n");
		$$ = $2 + 1;
	}
    |	  M_OPEN eval M_CLOSE	
	{ 
		Print_Blank($2);
		printf("fun_body <- M_OPEN eval M_CLOSE\n");
		$$ = $2 + 1;
	}
    |	  EQUAL cal_sent	
	{
		Print_Blank($2);
		printf("fun_body <- EQUAL cal_sent\n");
		$$ = $2 + 1;	
	}
    |	 EQUAL if_stt
	{
		Print_Blank($2);
		printf("fun_body <- EQUAL if_stt\n");
		$$ = $2 + 1;	
	}
    |	 EQUAL when_stt
	{
		Print_Blank($2);
		printf("fun_body <- EQUAL when_stt\n");
		$$ = $2 + 1;	
	}
    |	  epsilone		
	{
		//empty	
	}
    ;
while_stt: WHILE OPEN condition CLOSE M_OPEN loop_body M_CLOSE 
	 {
		tmp_blank = ($3 > $6) ? $3 : $6;
		Print_Blank(tmp_blank);
		printf("while_stt <- WHILE OPEN condition CLOSE M_OPEN loop_body M_CLOSE\n");
		$$ = tmp_blank + 1;
	 }
    ;
for_stt: FOR OPEN condition CLOSE M_OPEN loop_body M_CLOSE 
	 {
		tmp_blank = ($3 > $6) ? $3 : $6;
		Print_Blank(tmp_blank);
		printf("for_stt <- FOR OPEN condition CLOSE M_OPEN loop_body M_CLOSE\n");
		$$ = $3 + 1;
      	 }
    ;
loop_body: eval		
	 {
		Print_Blank($1);
		printf("loop_body <- eval\n");
		$$ = $1 + 1;
	 }
    ;
when_body: when_id ARROW when_id when_body
	{
		tmp_blank = ($1 > $3) ? $1 : $3;
		Print_Blank(tmp_blank);
		printf("when_body <- when_id ARROW when_id when_body\n");
		$$ = tmp_blank + 1;
	}
    |	   ELSE ARROW when_id
	{
		Print_Blank($3);
		printf("when_body <- ELSE ARROW when_id\n");
		$$ = $3 + 1;
	}
    |	  when_condition ARROW when_id when_body
	{
		tmp_blank = ($1 > $3) ? $1 : $3;
		tmp_blank = (tmp_blank> $4) ? tmp_blank : $4;
		Print_Blank(tmp_blank);
		printf("when_body <- when_condition ARROW cal_sent when_body\n");
		$$ = tmp_blank + 1;
	}
    |	   epsilone	
	{
		//empty
	}
    ;
when_id: STR
	{
		Print_Blank(0);
		printf("when_id <- STR\n");
		$$ = 1;
	}
    |	 cal_sent
	{
		Print_Blank($1);
		printf("when_id <- cal_sent\n");
		$$ = $1 + 1;
	}
    ;
when_condition:	IS type
		{
			Print_Blank($2);
			printf("when_condition <- IS type\n");
			$$ = $2;
		}
	|	NOT IS type
		{
			Print_Blank($3);
			printf("when_condition <- NOT IS type\n");
			$$ = $3;
		}
	|	when_id IN cal_sent range
		{
			tmp_blank = ($1 > $3) ? $1 : $3;
			tmp_blank = (tmp_blank > $4) ? tmp_blank : $4;
			Print_Blank(tmp_blank);
			printf("when_condition <- when_id IN range\n");
			$$ = tmp_blank + 1;
		}
	|	when_id NOT IN cal_sent range
		{
			tmp_blank = ($1 > $4) ? $1 : $4;
			Print_Blank(tmp_blank);
			printf("when_condition <- when_id NOT IN cal_sent range\n");
			$$ = tmp_blank + 1;
		}
	;
when_stt:  WHEN OPEN ID CLOSE M_OPEN when_body M_CLOSE	
	{
		Print_Blank($6);
		printf("when_stt <- WHEN OPEN ID CLOSE M_OPEN when_body M_CLOSE\n");
		$$ = $6 + 1;
	}
    |	   WHEN M_OPEN when_body M_CLOSE
	{
		Print_Blank($3);
		printf("when_stt <- WHEN M_OPEN when_body M_CLOSE\n");
		$$ = $3 + 1;
	}
    ;
if_stt:	IF noelse
      	{
		Print_Blank($2);
		printf("if_stt <- IF noelse\n");
		$$ = $2 + 1;
	}
    |	IF withelse
	{
		Print_Blank($2);
		printf("if_stt <- IF withelse\n");
		$$ = $2 + 1;
	}
    ;
noelse:	OPEN condition CLOSE cf
      	{
		tmp_blank = ($2 > $4) ? $2 : $4;
		Print_Blank(tmp_blank);
		printf("noelse <- OPEN condition CLOSE cf\n");
		/*if($2)
		{
			$$ = $4;
		}*/
		$$ = tmp_blank + 1;	
	}
    ;
withelse: OPEN condition CLOSE cf
	{
		tmp_blank = ($2 > $4) ? $2 : $4;
		Print_Blank(tmp_blank);
		printf("withelse <- OPEN condition CLOSE cf\n");
		$$ = tmp_blank + 1;
	}
    |	  OPEN condition CLOSE cf else_part
	{
		tmp_blank = ($2 > $4) ? $2 : $4;
		tmp_blank = (tmp_blank > $5) ? tmp_blank : $5; 
		Print_Blank(tmp_blank);
		printf("OPEN condition CLOSE cf else_part\n");
		$$ = tmp_blank + 1; 
	}
    ;
else_part: ELSEIF OPEN condition CLOSE cf else_part
	 {
		tmp_blank = ($3 > $5) ? $3 : $5;
		tmp_blank = (tmp_blank > $6) ? tmp_blank : $6;
		Print_Blank(tmp_blank);
		printf("else_part <- ELSEIF OPEN condition CLOSE cf else_part\n");
		$$ = tmp_blank + 1;
	 }
    |	   ELSE cf
	 {
		Print_Blank($2);
		printf("else_part <- ELSE cf\n");
		$$ = $2 + 1;
	 }
    |	   epsilone
	 {
		//empty
	 }
    ;
cf:	 M_OPEN cf_body M_CLOSE
	 {
		Print_Blank($2);
		printf("cf <- M_OPEN cf_body M_CLOSE\n");
		$$ = $2 + 1;
	 }
    |	 cf_body
	 {
		Print_Blank($1);
		printf("cf <- cf_body\n");
		$$ = $1 + 1;
	 }
	 
cf_body: eval RETURN cal_sent	
       	{
		tmp_blank = ($1 > $3) ? $1 : $3;
		Print_Blank(tmp_blank);
		printf("cf_body <- eval RETURN cal_sent\n");
		$$ = tmp_blank + 1;
	}
    |	eval RETURN	
       	{
		Print_Blank($1);
		printf("cf_body <- eval RETURN\n");
		$$ = $1 + 1;
	}	
    |	eval
       	{
		Print_Blank($1);
		printf("cf_body <- M_OPEN eval M_CLOSE\n");
		$$ = $1 + 1;
	}
    ;
com: 	COMMENT	
     	{ 
		Print_Blank(0);
		printf("com <- COMMENT\n");
		$$ = 1;
	}
    |	COMMENT_LONG	
	{ 
		Print_Blank(0);
		printf("com <- COMMENT_LONG\n");
		$$ = 1;
	}
    ;
condition  :	is_condition	
	   	{ 
			Print_Blank($1);
			printf("condition <- is_condition\n");
			$$ = $1 + 1;	
		}
	|	condition SAME condition	
		{	
			tmp_blank = ($1 > $3) ? $1 : $3;	
			Print_Blank(tmp_blank);
			printf("condition <- condition SAME condition\n");
			/*if($1 == $3)
				$$ = 1;
			else
				$$ = 0;*/
			$$ = tmp_blank + 1;
		}
	|	condition GREATER condition
		{
			tmp_blank = ($1 > $3) ? $1 : $3;
			Print_Blank(tmp_blank);
			printf("condition <- condition GREATER condition\n");
			/*if($1 < $3)
				$$ = 1;
			else
				$$ = 0;*/
			$$ = tmp_blank + 1;
		}
	|	condition LESS condition
		{
			tmp_blank = ($1 > $3) ? $1 : $3;
			Print_Blank(tmp_blank);
			printf("condition <- condition LESS condition\n");
			/*if($1 > $3)
				$$ = 1;
			else
				$$ = 0;*/
			$$ = tmp_blank + 1;
		}
	|	condition E_GREATER condition
		{
			tmp_blank = ($1 > $3) ? $1 : $3;
			Print_Blank(tmp_blank);
			printf("condition <- condition E_GREATER condition\n");
			/*if($1 <= $3)
				$$ = 1;
			else
				$$ = 0;*/
			$$ = tmp_blank + 1;
		}
	|	condition E_LESS condition
		{
			tmp_blank = ($1 > $3) ? $1 : $3;
			Print_Blank(tmp_blank);
			printf("condition <- condition E_LESS condition\n");
			/*if($1 >= $3)
				$$ = 1;
			else
				$$ = 0;*/
			$$ = tmp_blank + 1;	
		}
	|	condition AND condition
		{
			tmp_blank = ($1 > $3) ? $1 : $3;	
			Print_Blank(tmp_blank);
			printf("condition <- condition AND condition\n");
			/*if($1 && $3)
				$$ = 1;
			else
				$$ = 0;*/
			$$ = tmp_blank + 1;
		}
	|	condition OR condition
		{
			tmp_blank = ($1 > $3) ? $1 : $3;
			Print_Blank(tmp_blank);
			printf("condition <- condition OR condition\n");
			/*if($1 || $3)
				$$ = 1;
			else
				$$ = 0;*/
			$$ = tmp_blank + 1;
		}
	|	condition NOT_SAME condition
		{
			tmp_blank = ($1 > $3) ? $1 : $3;
			Print_Blank(tmp_blank);
			printf("condition <- condition NOT_SAME condition\n");
			/*if($1 != $3)
				$$ = 1;
			else
				$$ = 0;*/
			$$ = tmp_blank + 1;
		}
	|	cal_sent	
		{ 
			Print_Blank($1);
			printf("condition <- cal_sent\n");
			$$ = $1 + 1;
		}
	|	signed_factor IN cal_sent range	
		{
			tmp_blank = ($1 > $3) ? $1 : $3;
			tmp_blank = (tmp_blank > $4) ? tmp_blank : $4;
			Print_Blank(tmp_blank);
			printf("condition <- factor IN cal_sent range\n");
			$$ = tmp_blank + 1;
		}
	|	signed_factor NOT IN cal_sent range	
		{
			tmp_blank = ($1 > $4) ? $1 : $4;
			tmp_blank = (tmp_blank > $5) ? tmp_blank : $5;
			Print_Blank(tmp_blank);
			printf("condition <- factor NOT IN cal_sent range\n");
			$$ = tmp_blank + 1;
		}
	;
is_condition :	ID IS type	
	     	{ 
			printf("is_condition <- ID IS type\n");
			Print_Blank($3);
			//tmp_idx = Find_var_index($1, var_name);
			//tmp_data = Check_Type_Saved($1);
			//if(var_type[tmp_idx] == tmp_data)
			//	$$ = 1;
			//else
			//	$$ = 0;
			$$ = $3 + 1;
	     	}
	|	ID NOT IS type	
		{
			printf("is_condition <- ID NOT IS type\n");
			Print_Blank($4);
			//tmp_idx = Find_var_index($1, var_name);
			//tmp_data = Check_Type_Saved($1);
			//if(var_type[tmp_idx] != tmp_data)
			//	$$ = 1;
			//else
			//	$$ = 0;
			$$ = $4 + 1;
		}
	;
range	:	DOT cal_sent step_count 
      		{
			printf("range <- DOUBLEDOT cal_sent step_count\n");
			tmp_blank = ($2 > $3) ? $2 : $3;
			Print_Blank(tmp_blank);
			$$ = tmp_blank + 1;
      		}
	|	DOWNTO cal_sent step_count 
		{
			printf("range <- DOWNTO cal_sent step_count\n");
			tmp_blank = ($2 > $3) ? $2 : $3;
			Print_Blank(tmp_blank);
			$$ = tmp_blank + 1;
		}
	|	epsilone
		{
			/*empty*/
		}
	;
step_count:	STEP factor
	  	{ 
			printf("step_count <- STEP factor\n");
			Print_Blank($2);
			$$ = $2 + 1;
	  	}
	|	epsilone
		{
			/*empty*/
		}
	;
withelse:	ELSEIF expr withelse	
		{
			printf("withelse <- ELSEIF expr withelse\n");
			tmp_blank = ($2 > $3) ? $2 : $3;	
			Print_Blank(tmp_blank);
			$$ = tmp_blank + 1;
		}
	|	ELSE expr		
		{
			printf("withelse <- ELSE expr\n");
			Print_Blank($2);
			$$ = $2 + 1;
		}
	;
id_decl:	ID 
       		{
			printf("id_decl <- ID\n");
			Print_Blank(0);
			$$ = 1;
		}
	|	ID COLUMN type
		{
			printf("id_decl <- ID COLUMN type\n");
			Print_Blank($3);
			$$ = $3;
		}
	;
id_decl_stt:	id_decl EQUAL decl_content COMMA id_decl_stt 
		{
			printf("id_decl_stt <- id_decl EQUAL decl_content COMMA id_decl_stt\n");
			tmp_blank = ($3 > $5) ? $3 : $5;
			tmp_blank = (tmp_blank > $1) ? tmp_blank : $1;
			Print_Blank(tmp_blank);
			//tmp_data = Check_Type_Not_Saved($3);
			//tmp_idx = Var_Save($1, $3, tmp_data, var_name, data, var_type);
			//if(tmp_idx == -1)
			//	printf("Error : ID is saved already!\n\n");
			//if(tmp_idx == var_idx + 1)
			//	var_idx = tmp_idx;
			//else
			//	printf("Error : Hole in array!\n");
			$$ = tmp_blank + 1;
		}
 	|	id_decl	
		{
			printf("id_decl_stt <- id_decl\n");
			Print_Blank($1);
			//var_type[var_idx] = 0;
			//var_name[var_idx] = $1;
			//data[var_idx] = -1;
			//var_idx++;
			$$ = $1 + 1;
		}
 	|	id_decl COMMA id_decl_stt	
		{
			printf("id_decl_stt <- id_decl\n");
			Print_Blank($1);
			//var_type[var_idx] = 0;
			//var_name[var_idx] = $1;
			//data[var_idx] = -1;
			//var_idx++;
			$$ = $1 + 1;
		}
	|	id_decl EQUAL decl_content	
		{
			printf("id_decl_stt <- id_decl EQUAL decl_content\n");
			tmp_blank = ($1 > $3) ? $1 : $3;
			Print_Blank(tmp_blank);
			//tmp_data = Check_Type_Not_Saved($3);
			//var_type[var_idx] = tmp_data;
			//var_name[var_idx] = $1;
			//data[var_idx] = $3;
			//var_idx++;
			$$ = tmp_blank + 1;	
		}
	;
decl_content:	LISTOF OPEN list_content CLOSE	
		{
			printf("decl_content <- LISTOF OPEN list_content CLOSE\n");
			Print_Blank($3);
			//double * tmp = (double*) &($3);
			//$$ = *tmp;
			$$ = $3 + 1;	
		}
	|	STR
		{
			printf("decl_content <- STR\n");
			Print_Blank(0);
			//tmp_idx = Find_var_index($1, var_name);
			//$$ = data[tmp_idx];
			$$ = 1;	
		}
	|	condition
		{
			printf("decl_content <- condition\n");
			Print_Blank($1);
			$$ = $1;
		}
	;
list_content:	STR COMMA list_content
	    	{
			printf("list_content <- STR COMMA list_content\n");
			Print_Blank($3);
			//*($3 + tmp_idx) = $1;
			//tmp_idx++;
			$$ = $3 + 1;
	    	}
	|	STR
		{
			printf("list_content <- STR\n");
			Print_Blank(0);
			//char** tmp_str = (char**)calloc(100, sizeof(char*));
			//tmp_idx = 0;
			//tmp_str[tmp_idx] = $1;
			//$$ = tmp_str;
			//tmp_idx++;
			$$ = 1;	
		}
	|	cal_sent COMMA list_content
	    	{
			printf("list_content <- cal_sent COMMA list_content\n");
			tmp_blank = ($1 > $3) ? $1 : $3;
			Print_Blank(tmp_blank);
			//*($3 + tmp_idx) = $1;
			//tmp_idx++;
			$$ = tmp_blank + 1;
	    	}
	|	cal_sent
		{
			printf("list_content <- cal_sent\n");
			Print_Blank($1);
			//char** tmp_str = (char**)calloc(100, sizeof(char*));
			//tmp_idx = 0;
			//tmp_str[tmp_idx] = $1;
			//$$ = tmp_str;
			//tmp_idx++;
			$$ = $1 + 1;	
		}
	;
fun_call:	ID OPEN argument CLOSE
		{
			printf("fun_call <- ID OPEN argument CLOSE\n");
			Print_Blank($3);
			$$ = $3 + 1;
		}
	;
argument:	cal_sent mul_argument
		{
			tmp_blank = ($1 > $2) ? $1 : $2;
			Print_Blank(tmp_blank);
			printf("argument <- calc_sent mul_argument\n");
			$$ = tmp_blank;
		}
	|	STR mul_argument
		{
			Print_Blank($2);
			printf("argument <- STR mul_argument\n");
			$$ = $2 + 1;
		}
	|	LISTOF OPEN list_content CLOSE mul_argument
		{
			tmp_blank = ($3 > $5) ? $3 : $5;
			printf("argument <- LISTOF OPEN list_content CLOSE mul_argument\n");
			$$ = tmp_blank + 1;
		}
	|	fun_call mul_argument
		{
			tmp_blank = ($1 > $2) ? $1 : $2;
			Print_Blank(tmp_blank);
			printf("argument <- fun_call mul_argument");
			$$ = tmp_blank + 1;
		}
	|	epsilone
		{
			/*empty*/
		}
	;
mul_argument:	COMMA argument
	    	{
			Print_Blank($2);
			printf("mul_argument <- COMMA argument\n");
			$$ = $2 + 1;
		}
	|	epsilone
		{
			/*empty*/
		}
	;

epsilone: /*empty*/	{} ;
%%


/* User code */
extern int line_num;

int yyerror(const char *s)
{
	return printf("Line : %d is error with %s\n", line_num, s);
}

int Check_Type_Saved(char * name)
{
	int idx = Find_var_index(name, var_name);
	return var_type[idx]; 
}

int Check_Type_Not_Saved(double value)
{
	return 1;
}

void Print_Blank(double n)
{
	for(int i = 0; i < n; i++)
	{
		printf(" ");
	}
}
