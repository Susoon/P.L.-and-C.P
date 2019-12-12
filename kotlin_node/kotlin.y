%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "find_data.h"
#include "parse_tree.h"

extern int yylex(void);
extern void yyterminate();
extern int yyerror(const char *s);

int Check_Type_Saved(char * name);
int Check_Type_Not_Saved(double value);

NODE * parent;
NODE * child;

%}

%union { struct parse_node* node_var; double d_var; float f_var; int i_var; long l_var; char* s_var; char c_var; char** sp_var}


%type <node_var> start
%type <node_var> eval
%type <node_var> expr
%type <node_var> term
%type <node_var> factor
%type <node_var> signed_factor
%type <node_var> id_decl
%type <node_var> id_decl_stt
%type <node_var> fun_body
%type <node_var> loop_body
%type <node_var> cf_body
%type <node_var> withelse
%type <node_var> noelse
%type <node_var> when_body
%type <node_var> param
%type <node_var> type
%type <node_var> epsilone
%type <node_var> com
%type <node_var> range
%type <node_var> condition
%type <node_var> is_condition
%type <node_var> fun_stt
%type <node_var> while_stt
%type <node_var> for_stt
%type <node_var> if_stt
%type <node_var> when_stt
%type <node_var> cal_sent
%type <node_var> step_count
%type <node_var> ret_type
%type <node_var> decl_content
%type <node_var> list_content
%type <node_var> else_part
%type <node_var> fun_call
%type <node_var> argument
%type <node_var> main_fun
%type <node_var> mul_argument
%type <node_var> assign
%type <node_var> cf
%type <node_var> when_id
%type <node_var> when_condition
%type <node_var> lambda
%type <node_var> class_id_decl
%type <node_var> class_decl
%type <node_var> class_method_decl
%type <node_var> class_stt
%type <node_var> inheritance
%type <node_var> c_inheritance
%type <node_var> generic
%type <node_var> var_decl
%type <node_var> val_decl
%type <node_var> fun_type
%type <node_var> class_param
%type <node_var> class_keyword

%token <i_var> L_NUMBER
%token <d_var> NUMBER
%token <node_var> STR
%token <node_var> PACK
%token <node_var> FUNC
%token <node_var> VAL
%token <node_var> VAR
%token <node_var> IMPORT
%token <node_var> IF
%token <node_var> ELSEIF
%token <node_var> ELSE
%token <node_var> NUL
%token <node_var> RETURN
%token <node_var> FOR
%token <node_var> WHILE
%token <node_var> WHEN
%token <node_var> IS
%token <node_var> IN
%token <node_var> DOWNTO
%token <node_var> STEP
%token <node_var> LISTOF
%token <node_var> LIST
%token <i_var> INT
%token <i_var> FLOAT
%token <i_var> LONG
%token <i_var> DOUBLE
%token <i_var> STRING
%token <i_var> CHAR
%token <i_var> BOOL
%token <i_var> ANY
%token <i_var> UNIT
%token <node_var> MAIN
%token <s_var> ID
%token <node_var> COMMENT
%token <node_var> COMMENT_LONG
%token <node_var> ABST
%token <node_var> CLASS
%token <node_var> OVER
%token <node_var> INTER

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
		root = (NODE*)malloc(sizeof(NODE));
		root -> token_name = "goal";
		Add_Child(root, $1);
		Print_Tree(root, 0);
	}
    ;
start:	IMPORT start	
	{
		parent = make_nt_node("start");
		child = make_token_node("IMPORT");
		Add_Child(parent, child);
		Add_Last($2);
		
		$$ = parent;
	}
    |	PACK start 
    	{
		parent = make_nt_node("start");
		child = make_token_node("PACK");
		Add_Child(parent, child);
		Add_Last($2);
		
		$$ = parent;
	}
    |	eval
	{
		parent = make_nt_node("start");
		Add_Child(parent, $1);
		
		$$ = parent; 
	}
    ;
eval:	expr eval	
    	{
		parent = make_nt_node("eval");
		Add_Child(parent, $1);
		Add_Last($2);

		$$ = parent;
    	}
    |	expr	
	{
		parent = make_nt_node("eval");
		Add_Child(parent, $1);
		
		$$ = parent;
	}
    |	main_fun eval
	{
		parent = make_nt_node("eval");
		Add_Child(parent, $1);
		Add_Last($2);

		$$ = parent;
	}
    ;
expr:	for_stt
 	{
		parent = make_nt_node("expr");
		Add_Child(parent, $1);
		
		$$ = parent; 
	}	
    |	while_stt	
	{
		parent = make_nt_node("expr");
		Add_Child(parent, $1);
	
		$$ = parent;
	}
    |	if_stt	
	{
		parent = make_nt_node("expr");
		Add_Child(parent, $1);
		
		$$ = parent;
	}
    |	when_stt
	{
		parent= make_nt_node("expr");
		Add_Child(parent, $1);

		$$ = parent;
	}
    |	var_decl
	{
		parent = make_nt_node("expr");
		Add_Child(parent, $1);
	
		$$ = parent;
	}
    |	val_decl
	{
		parent = make_nt_node("expr");
		Add_Child(parent, $1);
		
		$$ = parent; 
	}
    |	cal_sent	
	{
		parent = make_nt_node("expr");
		Add_Child(parent, $1);
	
		$$ = parent; 
	}
    |	fun_stt		
	{ 
		parent = make_nt_node("expr");
		Add_Child(parent, $1);

		$$ = parent;
	}
    |	com
	{
		parent = make_nt_node("expr");
		Add_Child(parent, $1);
		
		$$ = parent;
	}
    |	ID assign cal_sent
	{
		parent = make_nt_node("expr");
		child = make_token_node($1);
		Add_Child(parent, child);
		Add_Last($2);
		Add_Last($3);

		$$ = parent;
	}
    |	ID EQUAL STR
	{
		parent = make_nt_node("expr");
		child = make_token_node($1);
		Add_Child(parent, child);
		child = make_token_node("EQUAL");
		Add_Last(child);
		child = make_token_node("STR");
		Add_Last(child);

		$$ = parent;
	}
    |	ID lambda
	{
		parent = make_nt_node("expr");
		child = make_token_node($1);
		Add_Child(parent, child);
		Add_Last($2);

		parent;
	}
    |	class_stt
	{
		parent = make_nt_node("expr");
		Add_Child(parent, $1);
		
		$$ = parent;
	}
    |	epsilone
	{
		parent = make_nt_node("expr");
		Add_Child(parent, $1);

		$$ = parent;
	}
    ;
generic:	GREATER type LESS
		{
			parent = make_nt_node("generic");
			child = make_token_node("GREATER");
			Add_Child(parent, child);
			Add_Last($2);
			child = make_token_node("LESS");
			Add_Last(child);
	
			$$ = parent;
		}
	;
class_stt:	ABST CLASS ID OPEN class_param CLOSE c_inheritance M_OPEN class_decl M_CLOSE
	  	{
			parent = make_nt_node("class_stt");
			child = make_token_node("ABST");
			Add_Child(parent, child);
			child = make_token_node("CLASS");
			Add_Last(child);
			child = make_token_node("ID");
			Add_Last(child);
			child = make_token_node("OPEN");
			Add_Last(child);
			Add_Last($5);
			child = make_token_node("CLOSE");
			Add_Last(child);
			Add_Last($7);
			child = make_token_node("M_OPEN");
			Add_Last(child);
			Add_Last($9);
			child = make_token_node("M_CLOSE");
			Add_Last(child);
	
			$$ = parent;
		}
	|	CLASS ID OPEN class_param CLOSE c_inheritance M_OPEN class_decl M_CLOSE
	  	{
			parent = make_nt_node("class_stt");
			child = make_token_node("CLASS");
			Add_Child(parent, child);
			child = make_token_node("ID");
			Add_Last(child);
			child = make_token_node("OPEN");
			Add_Last(child);
			Add_Last($4);
			child = make_token_node("CLOSE");
			Add_Last(child);
			Add_Last($6);
			child = make_token_node("M_OPEN");
			Add_Last(child);
			Add_Last($8);
			child = make_token_node("M_CLOSE");
			Add_Last(child);
	
			$$ = parent;
		}
	|	INTER ID M_OPEN class_decl M_CLOSE
	  	{
			parent = make_nt_node("class_stt");
			child = make_token_node("INTER");
			Add_Child(parent, child);
			child = make_token_node("ID");
			Add_Last(child);
			child = make_token_node("M_OPEN");
			Add_Last(child);
			Add_Last($4);
			child = make_token_node("M_CLOSE");
			Add_Last(child);
	
			$$ = parent;
		}
	;
val_decl:	VAL id_decl_stt
	    	{
			parent = make_nt_node("val_decl");
			child = make_token_node("VAL");
			Add_Child(parent, child);
			Add_Last($2);

			$$ = parent;
		}
	;
var_decl:	VAR id_decl_stt
	    	{
			parent = make_nt_node("var_decl");
			child = make_token_node("VAR");
			Add_Child(parent, child);
			Add_Last($2);

			$$ = parent;
		}
	;
class_keyword:	OVER
	     	{
			parent = make_nt_node("class_keyword");
			child = make_token_node("OVER");
			Add_Child(parent, child);

			$$ = parent;
		}
	|	ABST
		{
			parent = make_nt_node("class_keyword");
			parent = make_token_node("ABST");
			Add_Child(parent, child);

			$$ = parent;
		}
	|	epsilone
		{
			parent = make_token_node("class_keyword");
			Add_Child(parent, $1);

			$$ = parent;
		}
	;	
class_id_decl:	class_keyword var_decl
	     	{
			parent = make_nt_node("class_id_decl");
			Add_Child(parent, $1);
			Add_Last($2);
		
			$$ = parent;
		}
	|	class_keyword val_decl
	     	{
			parent = make_nt_node("class_id_decl");
			Add_Child(parent, $1);
			Add_Last($2);
		
			$$ = parent;
		}
	;
class_decl:	class_id_decl class_decl
	  	{
			parent = make_nt_node("class_decl");
			Add_Child(parent, $1);
			Add_Last($2);
		
			$$ = parent;
		}
	|	class_method_decl class_decl
	  	{
			parent = make_nt_node("class_decl");
			Add_Child(parent, $1);
			Add_Last($2);
		
			$$ = parent;
		}
	|	class_id_decl
	  	{
			parent = make_nt_node("class_decl");
			Add_Child(parent, $1);
		
			$$ = parent;
		}
	|	class_method_decl
	  	{
			parent = make_nt_node("class_decl");
			Add_Child(parent, $1);
		
			$$ = parent;
		}
	;
class_method_decl:	class_keyword fun_stt
		 	{
				parent = make_nt_node("class_method_decl");
				Add_Child(parent, $1);
			
				$$ = parent;
			}
	;
c_inheritance:	COLUMN inheritance
	     	{
			parent = make_nt_node("c_inheritance");
			child = make_token_node("COLUMN");
			Add_Child(parent, child);
			Add_Last($2);
		
			$$ = parent;
		}
	|	epsilone
		{
			parent = make_nt_node("c_inheritance");
			Add_Child(parent, $1);
		
			$$ = parent;
		}
	;
inheritance:	fun_call COMMA inheritance
	   	{
			parent = make_nt_node("inheritnace");
			Add_Child(parent, $1);
			child = make_token_node("COMMA");
			Add_Last(child);
			Add_Last($3);

			$$ = parent;
		}
	|	ID COMMA inheritance
		{
			parent = make_nt_node("inheritance");
			child = make_token_node("ID");
			Add_Child(parent, child);
			child = make_token_node("COMMA");
			Add_Last(child);
			Add_Last($3);

			$$ = parent;
		}
	|	ID
		{
			parent = make_nt_node("inheritance");
			child = make_token_node("ID");
			Add_Child(parent, child);

			$$ = parent;
		}
	|	fun_call
		{
			parent = make_nt_node("inheritnace");
			Add_Child(parent, $1);

			$$ = parent;
		}
	;
lambda: DOT ID M_OPEN cal_sent M_CLOSE lambda
      	{
		parent = make_nt_node("lambda");
		child = make_token_node("DOT");
		Add_Child(parent, child);
		child = make_token_node("ID");
		Add_Last(child);
		child = make_token_node("M_OPEN");
		Add_Last(child);
		Add_Last($4);
		child = make_token_node("M_CLOSE");
		Add_Last(child);
		Add_Last($6);

		$$ = parent;
	}
    |	epsilone
	{
		parent = make_nt_node("lambda");
		Add_Child(parent, $1);

		$$ = parent;
	}
    ;
assign:	EQUAL
      	{
		parent = make_nt_node("assign");
		child = make_token_node("EQUAL");
		Add_Child(parent, child);

		$$ = parent;
	}
    |	E_PLUS
      	{
		parent = make_nt_node("assign");
		child = make_token_node("E_PLUS");
		Add_Child(parent, child);

		$$ = parent;
	}
    |	E_MINUS
      	{
		parent = make_nt_node("assign");
		child = make_token_node("E_MINUS");
		Add_Child(parent, child);

		$$ = parent;
	}
    |	E_MULT
      	{
		parent = make_nt_node("assign");
		child = make_token_node("E_MULT");
		Add_Child(parent, child);

		$$ = parent;
	}
    |	E_DIV
      	{
		parent = make_nt_node("assign");
		child = make_token_node("E_DIV");
		Add_Child(parent, child);

		$$ = parent;
	}
    ;
main_fun: FUNC MAIN OPEN CLOSE fun_body
	{
		parent = make_nt_node("main_fun");
		child = make_token_node("FUNC");
		Add_Child(parent, child);
		child = make_token_node("MAIN");
		Add_Last(child);
		child = make_token_node("OPEN");
		Add_Last(child);
		child = make_token_node("CLOSE");
		Add_Last(child);
		Add_Last($5);
	
		$$ = parent;
	}
    ;
cal_sent: cal_sent PLUS term	
       	  {
		parent = make_nt_node("cal_sent");
		Add_Child(parent, $1);
		child = make_token_node("PLUS");
		Add_Last(child);
		Add_Last($3);

		$$ = parent;
	  }
    |	  cal_sent MINUS term
	  {
		parent = make_nt_node("cal_sent");
		Add_Child(parent, $1);
		child = make_token_node("MINUS");
		Add_Last(child);
		Add_Last($3);

		$$ = parent;
	  }
    |	  term			
	  { 
		parent = make_nt_node("term");
		Add_Child(parent, $1);
	
		$$ = parent;
	  }
    ;
term:	term MULT signed_factor 
    	{ 
		parent = make_nt_node("term");
		Add_Child(parent, $1);
		child = make_token_node("MULT");
		Add_Last(child);
		Add_Last($3);

		$$ = parent;
    	} 
    |	term DIV signed_factor	
	{ 
		parent = make_nt_node("term");
		Add_Child(parent, $1);
		child = make_token_node("DIV");
		Add_Last(child);
		Add_Last($3);

		$$ = parent;
	} 
    |	signed_factor	
	{ 
		parent = make_nt_node("term");
		Add_Child(parent, $1);

		$$ = parent;
	}
    ;
signed_factor:	PLUS factor 
	     	{ 
			parent = make_nt_node("signed_factor");
			child = make_token_node("PLUS");
			Add_Child(parent, child);
			Add_Last($2);

			$$ = parent;
	     	}
	|    	MINUS factor 
		{ 
			parent = make_nt_node("signed_factor");
			child = make_token_node("MINUS");
			Add_Child(parent, child);
			Add_Last($2);

			$$ = parent;
		}
    	|	factor 
		{
			parent = make_nt_node("signed_factor");
			Add_Child(parent, $1);

			$$ = parent;
		}
    ;
factor: NUMBER	
      	{
		parent = make_nt_node("factor");
		child = make_token_node("NUMBER");
		Add_Child(parent, child);
		
		$$ = parent;
        }
    |	L_NUMBER	
      	{
		parent = make_nt_node("factor");
		child = make_token_node("L_NUMBER");
		Add_Child(parent, child);

		$$ = parent;
	}
    |	ID 	
	{ 
		parent = make_nt_node("factor");
		child = make_token_node("ID");
		Add_Child(parent, child);

		$$ = parent;
	}
    |	ID DOT fun_call 
	{ 
		parent = make_nt_node("factor");
		child = make_token_node("ID");
		Add_Child(parent, child);
		child = make_token_node("DOT");
		Add_Last(child);
		Add_Last($3);

		$$ = parent;
	}	
    |	ID DOT ID
	{ 
		parent = make_nt_node("factor");
		child = make_token_node("ID");
		Add_Child(parent, child);
		child = make_token_node("DOT");
		Add_Last(child);
		child = make_token_node("ID");
		Add_Last(child);

		$$ = parent;
	}
    |	ID INC
	{ 
		parent = make_nt_node("factor");
		child = make_token_node("ID");
		Add_Child(parent, child);
		child = make_token_node("INC");
		Add_Last(child);

		$$ = parent;
	}
    |	ID DEC
	{ 
		parent = make_nt_node("factor");
		child = make_token_node("ID");
		Add_Child(parent, child);
		child = make_token_node("DEC");
		Add_Last(child);

		$$ = parent;
	}
    |	INC ID
	{ 
		parent = make_nt_node("factor");
		child = make_token_node("INC");
		Add_Child(parent, child);
		child = make_token_node("ID");
		Add_Last(child);

		$$ = parent;
	}
    |	DEC ID
	{ 
		parent = make_nt_node("factor");
		child = make_token_node("DEC");
		Add_Child(parent, child);
		child = make_token_node("ID");
		Add_Last(child);

		$$ = parent;
	}
    |	OPEN cal_sent CLOSE 
	{ 
		parent = make_nt_node("factor");
		child = make_token_node("OPEN");
		Add_Child(parent, child);
		Add_Last($2);
		child = make_token_node("CLOSE");
		Add_Last(child);

		$$ = parent;
	}
    |	fun_call
	{ 
		parent = make_nt_node("factor");
		Add_Child(parent, $1);

		$$ = parent;
	}
    |	NUL	
	{ 
		parent = make_nt_node("factor");
		child = make_token_node("NULL");
		Add_Child(parent, child);

		$$ = parent;
	}
    ;
param:	ID COLUMN fun_type COMMA param 
     	{ 
		parent = make_nt_node("param");
		child = make_token_node("ID");
		Add_Child(parent, child);
		child = make_token_node("COLUMN");
		Add_Last(child);
		Add_Last($3);
		child = make_token_node("COMMA");
		Add_Last(child);
		Add_Last($5);
		
		$$ = parent;
     	}
    |	ID COLUMN fun_type		
	{
		parent = make_nt_node("param");
		child = make_token_node("ID");
		Add_Child(parent, child);
		child = make_token_node("COLUMN");
		Add_Last(child);
		Add_Last($3);

		$$ = parent;
	}
    |	epsilone
	{
		parent = make_nt_node("param");
		Add_Child(parent, $1);
		
		$$ = parent;
	}
    ;
class_param:	VAL id_decl COMMA class_param
	    	{
			parent = make_nt_node("class_param");
			child = make_token_node("VAL");
			Add_Child(parent, child);
			Add_Last($2);
			child = make_token_node("COMMA");
			Add_Last(child);
			Add_Last($4);

			$$ = parent;
		}
	|	VAR id_decl COMMA class_param
	    	{
			parent = make_nt_node("class_param");
			child = make_token_node("VAR");
			Add_Child(parent, child);
			Add_Last($2);
			child = make_token_node("COMMA");
			Add_Last(child);
			Add_Last($4);

			$$ = parent;
		}
	|	VAL id_decl
	    	{
			parent = make_nt_node("class_param");
			child = make_token_node("VAL");
			Add_Child(parent, child);
			Add_Last($2);

			$$ = parent;
		}
	|	VAR id_decl
	    	{
			parent = make_nt_node("class_param");
			child = make_token_node("VAR");
			Add_Child(parent, child);
			Add_Last($2);

			$$ = parent;
		}
	|	epsilone
		{
			parent = make_nt_node("class_param");
			Add_Child(parent, $1);
			
			$$ = parent;
		}
	;
type:	INT	
    	{
		parent = make_nt_node("type");
		child = make_token_node("INT");
		child -> type = 1;
		Add_Child(parent, child);
		
		$$ = parent;
    	}
    |	LONG
    	{
		parent = make_nt_node("type");
		child = make_token_node("LONG");
		child -> type = 2;
		Add_Child(parent, child);
		
		$$ = parent;
    	}
    |	FLOAT	
	{ 
		parent = make_nt_node("type");
		child = make_token_node("FLOAT");
		child -> type = 3;
		Add_Child(parent, child);
		
		$$ = parent;
	}
    |	DOUBLE	
	{ 
		parent = make_nt_node("type");
		child = make_token_node("DOUBLE");
		child -> type = 4;
		Add_Child(parent, child);
		
		$$ = parent;
	}
    |	STRING	
	{ 
		parent = make_nt_node("type");
		child = make_token_node("STRING");
		child -> type = 5;
		Add_Child(parent, child);
		
		$$ = parent;
	}
    |	CHAR	
	{ 
		parent = make_nt_node("type");
		child = make_token_node("CHAR");
		child -> type = 6;
		Add_Child(parent, child);
		
		$$ = parent;
	}
    |	BOOL
	{
		parent = make_nt_node("type");
		child = make_token_node("BOOL");
		child -> type = 7;
		Add_Child(parent, child);
		
		$$ = parent;
	}
    |	LIST generic
	{
		parent = make_nt_node("type");
		child = make_token_node("LIST");
		child -> type = 30;
		Add_Child(parent, child);
		
		$$ = parent;
	}
    ;
fun_type:	type
	  	{
			parent = make_nt_node("fun_type");
			Add_Child(parent, $1);

			$$ = parent;
		}
	|
	  	UNIT	
		{ 
			parent = make_nt_node("fun_type");
			child = make_token_node("UNIT");
			Add_Child(parent, child);
			child -> type = 8;

			$$ = parent;
		}
    	|	ANY	
		{ 
			parent = make_nt_node("fun_type");
			child = make_token_node("ANY");
			Add_Child(parent, child);
			child -> type = 9;

			$$ = parent;
		}
    	;
fun_stt:  FUNC ID OPEN param CLOSE ret_type fun_body 
       	{
		parent = make_nt_node("fun_stt");
		child = make_token_node("FUNC");
		Add_Child(parent, child);
		child = make_token_node("ID");
		Add_Last(child);
		child = make_token_node("OPEN");
		Add_Last(child);
		Add_Last($4);
		child = make_token_node("CLOSE");
		Add_Last(child);
		Add_Last($6);
		Add_Last($7);

		$$ = parent;
      	}
    ;
ret_type: COLUMN type QUESTION 
	{
		parent = make_nt_node("ret_type");
		child = make_token_node("COLUMN");
		Add_Child(parent, child);
		Add_Last($2);
		child = make_token_node("QUESTION");
		Add_Last(child);

		$$ = parent;
	}
    |	  COLUMN fun_type
	{
		parent = make_nt_node("ret_type");
		child = make_token_node("COLUMN");
		Add_Child(parent, child);
		Add_Last($2);

		$$ = parent;
	}
    |	 epsilone
	{
		parent = make_nt_node("ret_type");
		Add_Child(parent, $1);
	
		$$ = parent;
	}
    ;
fun_body: M_OPEN eval RETURN cal_sent M_CLOSE	
	{
		parent = make_nt_node("fun_body");
		child = make_token_node("M_OPEN");
		Add_Child(parent, child);
		Add_Last($2);
		child = make_token_node("RETURN");
		Add_Last(child);
		Add_Last($4);
		child = make_token_node("M_CLOSE");
		Add_Last(child);

		$$ = parent;
	}
    |	 M_OPEN eval RETURN M_CLOSE	
	{
		parent = make_nt_node("fun_body");
		child = make_token_node("M_OPEN");
		Add_Child(parent, child);
		Add_Last($2);
		child = make_token_node("RETURN");
		Add_Last(child);
		child = make_token_node("M_CLOSE");
		Add_Last(child);

		$$ = parent;
	}
    |	  M_OPEN eval M_CLOSE	
	{ 
		parent = make_nt_node("fun_body");
		child = make_token_node("M_OPEN");
		Add_Child(parent, child);
		Add_Last($2);
		child = make_token_node("M_CLOSE");
		Add_Last(child);

		$$ = parent;
	}
    |	  EQUAL cal_sent	
	{
		parent = make_nt_node("fun_body");
		child = make_token_node("EQUAL");
		Add_Child(parent, child);
		Add_Last($2);
	
		$$ = parent;
	}
    |	 EQUAL if_stt
	{
		parent = make_nt_node("fun_body");
		child = make_token_node("EQUAL");
		Add_Child(parent, child);
		Add_Last($2);
	
		$$ = parent;
	}
    |	 EQUAL when_stt
	{
		parent = make_nt_node("fun_body");
		child = make_token_node("EQUAL");
		Add_Child(parent, child);
		Add_Last($2);
	
		$$ = parent;
	}
    |	  epsilone		
	{
		parent = make_nt_node("fun_body");
		Add_Child(parent, $1);

		$$ = parent;
	}
    ;
while_stt: WHILE OPEN condition CLOSE M_OPEN loop_body M_CLOSE 
	 {
		parent = make_nt_node("while_stt");
		child = make_token_node("WHILE");
		Add_Child(parent, child);
		child = make_token_node("OPEN");
		Add_Last(child);
		Add_Last($3);
		child = make_token_node("CLOSE");
		Add_Last(child);
		child = make_token_node("M_OPEN");
		Add_Last(child);
		Add_Last($6);
		child = make_token_node("M_CLOSE");
		Add_Last(child);

		$$ = parent;
	 }
    ;
for_stt: FOR OPEN condition CLOSE M_OPEN loop_body M_CLOSE 
	 {
		parent = make_nt_node("for_stt");
		child = make_token_node("FOR");
		Add_Child(parent, child);
		child = make_token_node("OPEN");
		Add_Last(child);
		Add_Last($3);
		child = make_token_node("CLOSE");
		Add_Last(child);
		child = make_token_node("M_OPEN");
		Add_Last(child);
		Add_Last($6);
		child = make_token_node("M_CLOSE");
		Add_Last(child);

		$$ = parent;
      	 }
    ;
loop_body: eval		
	 {
		parent = make_nt_node("loop_body");
		Add_Child(parent, $1);
		
		$$ = parent;
	 }
    ;
when_body: when_id ARROW when_id when_body
	{
		parent = make_nt_node("when_body");
		Add_Child(parent ,$1);
		child = make_token_node("ARROW");
		Add_Last(child);
		Add_Last($3);
		Add_Last($4);
		
		$$ = parent;
	}
    |	   ELSE ARROW when_id
	{
		parent = make_nt_node("when_body");
		child = make_token_node("ELSE");
		Add_Child(parent, child);
		child = make_token_node("ARROW");
		Add_Last(child);
		Add_Last($3);

		$$ = parent;
	}
    |	  when_condition ARROW when_id when_body
	{
		parent = make_nt_node("when_body");
		Add_Child(parent, $1);
		child = make_token_node("ARROW");
		Add_Last(child);
		Add_Last($3);
		Add_Last($4);

		$$ = parent;
	}
    |	   epsilone	
	{
		parent = make_nt_node("when_body");
		Add_Child(parent, $1);
	
		$$ = parent;
	}
    ;
when_id: STR
	{
		parent = make_nt_node("when_id");
		child = make_token_node("STR");
		Add_Child(parent, child);

		$$ = parent;
	}
    |	 cal_sent
	{
		parent = make_nt_node("when_id");
		Add_Child(parent, $1);

		$$ = parent;
	}
    ;
when_condition:	IS type
		{
			parent = make_nt_node("when_condition");
			child = make_token_node("IS");
			Add_Child(parent, child);
			Add_Last($2);

			$$ = parent;
		}
	|	NOT IS type
		{
			parent = make_nt_node("when_condition");
			child = make_token_node("NOT");
			Add_Child(parent, child);
			child = make_token_node("IS");
			Add_Last(child);
			Add_Last($3);

			$$ = parent;
		}
	|	when_id IN cal_sent range
		{
			parent = make_nt_node("when_condition");
			Add_Child(parent, $1);
			child = make_token_node("IN");
			Add_Last(child);
			Add_Last($3);
			Add_Last($4);
		
			$$ = parent;
		}
	|	when_id NOT IN cal_sent range
		{
			parent = make_nt_node("when_condition");
			Add_Child(parent, $1);
			child = make_token_node("NOT");
			Add_Last(child);
			child = make_token_node("IN");
			Add_Last(child);
			Add_Last($4);
			Add_Last($5);
		
			$$ = parent;
		}
	;
when_stt:  WHEN OPEN ID CLOSE M_OPEN when_body M_CLOSE	
	{
		parent = make_nt_node("when_stt");
		child = make_token_node("WHEN");
		Add_Child(parent, child);
		child = make_token_node("OPEN");
		Add_Last(child);
		child = make_token_node("ID");
		Add_Last(child);
		child = make_token_node("CLOSE");
		Add_Last(child);
		child = make_token_node("M_OPEN");
		Add_Last(child);
		Add_Last($6);
		child = make_token_node("M_CLOSE");	
		Add_Last(child);
		
		$$ = parent;
	}
    |	   WHEN M_OPEN when_body M_CLOSE
	{
		parent = make_nt_node("when_stt");
		child = make_token_node("WHEN");
		Add_Child(parent, child);
		child = make_token_node("M_OPEN");
		Add_Last(child);
		Add_Last($3);
		child = make_token_node("M_CLOSE");	
		Add_Last(child);

		$$ = parent;
	}
    ;
if_stt:	IF noelse
      	{
		parent = make_nt_node("if_stt");
		child = make_token_node("IF");
		Add_Child(parent, child);
		Add_Last($2);

		$$ = parent;
	}
    |	IF withelse
	{
		parent = make_nt_node("if_stt");
		child = make_token_node("IF");
		Add_Child(parent, child);
		Add_Last($2);

		$$ = parent;
	}
    ;
noelse:	OPEN condition CLOSE cf
      	{
		parent = make_nt_node("noelse");
		child = make_token_node("OPEN");
		Add_Child(parent, child);
		Add_Last($2);
		child = make_token_node("CLOSE");
		Add_Last(child);
		Add_Last($4);

		$$ = parent;
	}
    ;
withelse: OPEN condition CLOSE cf
	{
		parent = make_nt_node("withelse");
		child = make_token_node("OPEN");
		Add_Child(parent, child);
		Add_Last($2);
		child = make_token_node("CLOSE");
		Add_Last(child);
		Add_Last($4);

		$$ = parent;
	}
    |	  OPEN condition CLOSE cf else_part
	{
		parent = make_nt_node("withelse");
		child = make_token_node("OPEN");
		Add_Child(parent, child);
		Add_Last($2);
		child = make_token_node("CLOSE");
		Add_Last(child);
		Add_Last($4);
		Add_Last($5);

		$$ = parent;
	}
    ;
else_part: ELSEIF OPEN condition CLOSE cf else_part
	 {
		parent = make_nt_node("else_part");
		child = make_token_node("ELSEIF");
		Add_Child(parent, child);
		child = make_token_node("OPEN");
		Add_Last(child);
		Add_Last($3);
		child = make_token_node("CLOSE");
		Add_Last(child);
		Add_Last($5);
		Add_Last($6);
	
		$$ = parent;
	 }
    |	   ELSE cf
	 {
		parent = make_nt_node("else_part");
		child = make_token_node("ELSE");
		Add_Child(parent, child);
		Add_Last($2);

		$$ = parent;
	 }
    |	   epsilone
	 {
		parent = make_nt_node("else_part");
		Add_Child(parent, $1);
	
		$$ = parent;
	 }
    ;
cf:	 M_OPEN cf_body M_CLOSE
	 {
		parent = make_nt_node("cf");
		child = make_token_node("M_OPEN");
		Add_Child(parent, child);
		Add_Last($2);
		child = make_token_node("M_CLOSE");
		Add_Last(child);

		$$ = parent;
	 }
    |	 cf_body
	 {
		parent = make_nt_node("cf");
		Add_Child(parent, $1);
		
		$$ = parent;
	 }
	 
cf_body: eval RETURN cal_sent	
       	{
		parent = make_nt_node("cf_body");
		Add_Child(parent, $1);
		child = make_token_node("RETURN");
		Add_Last(child);
		Add_Last($3);
		
		$$ = parent;
	}
    |	eval RETURN	
       	{
		parent = make_nt_node("cf_body");
		Add_Child(parent, $1);
		child = make_token_node("RETURN");
		Add_Last(child);
		
		$$ = parent;
	}	
    |	eval
       	{
		parent = make_nt_node("cf_body");
		Add_Child(parent, $1);
		
		$$ = parent;
	}
    ;
com: 	COMMENT	
     	{
		parent = make_nt_node("com");
		child = make_token_node("COMMENT");
		Add_Child(parent, child);

		$$ = parent;
	}
    |	COMMENT_LONG	
	{ 
		parent = make_nt_node("com");
		child = make_token_node("COMMENT_LONG");
		Add_Child(parent, child);

		$$ = parent;
	}
    ;
condition  :	is_condition	
	   	{ 
			parent = make_nt_node("condition");
			Add_Child(parent, $1);
		
			$$ = parent;
		}
	|	condition SAME condition	
		{	
			parent = make_nt_node("condition");
			Add_Child(parent, $1);
			child = make_token_node("SAME");
			Add_Last(child);
			Add_Last($3);
	
			$$ = parent;
		}
	|	condition GREATER condition
		{
			parent = make_nt_node("condition");
			Add_Child(parent, $1);
			child = make_token_node("GREATER");
			Add_Last(child);
			Add_Last($3);
	
			$$ = parent;
		}
	|	condition LESS condition
		{
			parent = make_nt_node("condition");
			Add_Child(parent, $1);
			child = make_token_node("LESS");
			Add_Last(child);
			Add_Last($3);
	
			$$ = parent;
		}
	|	condition E_GREATER condition
		{
			parent = make_nt_node("condition");
			Add_Child(parent, $1);
			child = make_token_node("E_GREATER");
			Add_Last(child);
			Add_Last($3);
	
			$$ = parent;
		}
	|	condition E_LESS condition
		{
			parent = make_nt_node("condition");
			Add_Child(parent, $1);
			child = make_token_node("E_LESS");
			Add_Last(child);
			Add_Last($3);
	
			$$ = parent;
		}
	|	condition AND condition
		{
			parent = make_nt_node("condition");
			Add_Child(parent, $1);
			child = make_token_node("AND");
			Add_Last(child);
			Add_Last($3);
	
			$$ = parent;
		}
	|	condition OR condition
		{
			parent = make_nt_node("condition");
			Add_Child(parent, $1);
			child = make_token_node("OR");
			Add_Last(child);
			Add_Last($3);
	
			$$ = parent;
		}
	|	condition NOT_SAME condition
		{
			parent = make_nt_node("condition");
			Add_Child(parent, $1);
			child = make_token_node("NOT_SAME");
			Add_Last(child);
			Add_Last($3);
	
			$$ = parent;
		}
	|	cal_sent	
		{ 
			parent = make_nt_node("condition");
			Add_Child(parent, $1);

			$$ = parent;
		}
	|	signed_factor IN cal_sent range	
		{
			parent = make_nt_node("condition");
			Add_Child(parent, $1);
			child = make_token_node("IN");
			Add_Last(child);
			Add_Last($3);
			Add_Last($4);

			$$ = parent;
		}
	|	signed_factor NOT IN cal_sent range	
		{
			parent = make_nt_node("condition");
			Add_Child(parent, $1);
			child = make_token_node("NOT");
			Add_Last(child);
			child = make_token_node("IN");
			Add_Last(child);
			Add_Last($4);
			Add_Last($5);

			$$ = parent;
		}
	;
is_condition :	ID IS type	
	     	{ 
			parent = make_nt_node("is_condition");
			child = make_token_node("ID");
			Add_Child(parent, child);
			child = make_token_node("IS");
			Add_Last(child);
			Add_Last($3);

			$$ = parent;
	     	}
	|	ID NOT IS type	
		{
			parent = make_nt_node("is_condition");
			child = make_token_node("ID");
			Add_Child(parent, child);
			child = make_token_node("NOT");
			Add_Last(child);
			child = make_token_node("IS");
			Add_Last(child);
			Add_Last($4);

			$$ = parent;
		}
	;
range	:	DOT cal_sent step_count 
      		{
			parent = make_nt_node("range");
			child = make_token_node("DOT");
			Add_Child(parent, child);
			Add_Last($2);
			Add_Last($3);

			$$ = parent;
      		}
	|	DOWNTO cal_sent step_count 
		{
			parent = make_nt_node("range");
			child = make_token_node("DOWNTO");
			Add_Child(parent, child);
			Add_Last($2);
			Add_Last($3);

			$$ = parent;
		}
	|	epsilone
		{
			parent = make_nt_node("range");
			Add_Child(parent, $1);
	
			$$ = parent;
		}
	;
step_count:	STEP factor
	  	{ 
			parent = make_nt_node("step_count");
			child = make_token_node("STEP");
			Add_Child(parent, child);
			Add_Last($2);
	
			$$ = parent;
	  	}
	|	epsilone
		{
			parent = make_nt_node("step_count");
			Add_Child(parent, $1);
	
			$$ = parent;
		}
	;
withelse:	ELSEIF expr withelse	
		{
			parent = make_nt_node("withelse");
			child = make_token_node("ELSEIF");
			Add_Child(parent, child);
			Add_Last($2);
			Add_Last($3);

			$$ = parent;
		}
	|	ELSE expr		
		{
			parent = make_nt_node("withelse");
			child = make_token_node("ELSE");
			Add_Child(parent, child);
			Add_Last($2);

			$$ = parent;
		}
	;
id_decl:	ID 
       		{
			parent = make_nt_node("id_decl");
			child = make_token_node("ID");
			Add_Child(parent, child);

			$$ = parent;
		}
	|	ID COLUMN type
		{
			parent = make_nt_node("id_decl");
			child = make_token_node("ID");
			Add_Child(parent, child);
			child = make_token_node("COLUMN");
			Add_Last(child);
			Add_Last($3);
		
			$$ = parent;
		}
	;
id_decl_stt:	id_decl EQUAL decl_content COMMA id_decl_stt 
		{
			parent = make_nt_node("id_decl_stt");
			Add_Child(parent, $1);
			child = make_token_node("EQUAL");
			Add_Last(child);
			Add_Last($3);
			child = make_token_node("COMMA");
			Add_Last(child);
			Add_Last($5);
		
			$$ = parent;
		}
 	|	id_decl	
		{
			parent = make_nt_node("id_decl_stt");
			Add_Child(parent, $1);

			$$ = parent;
		}
 	|	id_decl COMMA id_decl_stt	
		{
			parent = make_nt_node("id_decl_stt");
			Add_Child(parent, $1);
			child = make_token_node("COMMA");
			Add_Last(child);
			Add_Last($3);
		
			$$ = parent;
		}
	|	id_decl EQUAL decl_content	
		{
			parent = make_nt_node("id_decl_stt");
			Add_Child(parent, $1);
			child = make_token_node("EQUAL");
			Add_Last(child);
			Add_Last($3);
		
			$$ = parent;
		}
	;
decl_content:	LISTOF OPEN list_content CLOSE	
		{
			parent = make_nt_node("decl_content");
			child = make_token_node("LISTOF");
			Add_Child(parent, child);
			child = make_token_node("OPEN");
			Add_Last(child);
			Add_Last($3);
			child = make_token_node("CLOSE");
			Add_Last(child);
		
			$$ = parent;
		}
	|	STR
		{
			parent = make_nt_node("decl_content");
			child = make_token_node("STR");
			Add_Child(parent, child);

			$$ = parent;
		}
	|	condition
		{
			parent = make_nt_node("decl_content");
			Add_Child(parent, $1);

			$$ = parent;
		}
	;
list_content:	STR COMMA list_content
	    	{
			parent = make_nt_node("list_content");
			child = make_token_node("STR");
			Add_Child(parent, child);
			child = make_token_node("COMMA");
			Add_Last(child);
			Add_Last($3);
	
			$$ = parent;
	    	}
	|	STR
		{
			parent = make_nt_node("list_content");
			child = make_token_node("STR");
			Add_Child(parent, child);
	
			$$ = parent;
		}
	|	cal_sent COMMA list_content
	    	{
			parent = make_nt_node("list_content");
			Add_Child(parent, $1);
			child = make_token_node("COMMA");
			Add_Last(child);
			Add_Last($3);

			$$ = parent;
	    	}
	|	cal_sent
		{
			parent = make_nt_node("list_content");
			Add_Child(parent, $1);

			$$ = parent;
		}
	;
fun_call:	ID OPEN argument CLOSE
		{
			parent = make_nt_node("fun_call");
			child = make_token_node("ID");
			Add_Child(parent, child);
			child = make_token_node("OPEN");
			Add_Last(child);
			Add_Last($3);
			child = make_token_node("CLOSE");
			Add_Last(child);

			$$ = parent;
		}
	;
argument:	cal_sent mul_argument
		{
			parent = make_nt_node("argument");
			Add_Child(parent, $1);
			Add_Last($2);

			$$ = parent;
		}
	|	STR mul_argument
		{
			parent = make_nt_node("argument");
			child = make_token_node("STR");
			Add_Child(parent, child);
			Add_Last($2);
	
			$$ = parent;
		}
	|	LISTOF OPEN list_content CLOSE mul_argument
		{
			parent = make_nt_node("argument");
			child = make_token_node("LISTOF");
			Add_Child(parent, child);
			child = make_token_node("OPEN");
			Add_Last(child);
			Add_Last($3);
			child = make_token_node("CLOSE");
			Add_Last(child);
			Add_Last($5);
	
			$$ = parent;
		}
	|	fun_call mul_argument
		{
			parent = make_nt_node("argument");
			Add_Child(parent, child);
			Add_Last($2);

			$$ = parent;
		}
	|	epsilone
		{
			parent = make_nt_node("argument");
			Add_Child(parent, $1);
			
			$$ = parent;
		}
	;
mul_argument:	COMMA argument
	    	{
			parent = make_nt_node("mul_argument");
			child = make_token_node("COMMA");
			Add_Child(parent, child);
			Add_Last($2);
		
			$$ = parent;
		}
	|	epsilone
		{
			parent = make_nt_node("mul_argument");
			Add_Child(parent, $1);
	
			$$ = parent;
		}
	;

epsilone: /*empty*/	
	{
		parent = make_token_node("epsilone");
		$$ = parent;
	}
     ;
%%


/* User code */

extern int line_num;

int yyerror(const char *s)
{
	return printf("Line : %d is error with %s\n", line_num, s);
}

int Check_Type_Not_Saved(double value)
{
	return 1;
}

