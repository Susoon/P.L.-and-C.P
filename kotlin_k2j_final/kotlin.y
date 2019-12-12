%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "find_data.h"
#include "parse_tree.h"

#define NOT_SPACE -20
#define NEED_SPACE -10
#define NEED -1
#define NOT_NEED -2
#define NEED_NOW -3
#define Not_defined 0
#define Char 1
#define Bool 2
#define Int 3
#define Long 4
#define Float 5
#define Double 6
#define String 7
#define Unit 8
#define Any 9
#define Const 10
#define Question 20
#define List 30
#define C_fun 100
#define Class 200
#define Classtype 300

extern int yylex(void);
extern void yyterminate();
extern int yyerror(const char *s);

int Check_Type_Saved(char * name, int kind);
int Check_Type_Not_Saved(double value);
char * ttos(int type);

extern char * id_name[1000];
extern char * fun_name[1000];
extern double data[1000];
extern int id_type[1000];
extern int fun_type[1000];
extern char * class_type[1000];
extern char * class_name[1000];
int tmp_type;
int tmp_idx;
double tmp_data;
char * tmp_str;
char * main_class;

NODE * parent;
NODE * child;
NODE * tmp_node;

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
%type <node_var> list_content
%type <node_var> decl_content
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

%token <s_var> L_NUMBER
%token <s_var> NUMBER
%token <s_var> STR
%token <s_var> PACK
%token <node_var> FUNC
%token <node_var> VAL
%token <node_var> VAR
%token <s_var> IMPORT
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
%token <node_var> SETOF
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
%token <s_var> COMMENT
%token <s_var> COMMENT_LONG
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
		root -> next= NULL;
		root -> prev = NULL;
		root -> parent = NULL;
		root -> token_type = NOT_NEED;
		root -> type = Not_defined;
		child = make_token_node("import java.util.*;\n", NOT_SPACE);
		Add_Child(root, child, NOT_NEED);
		Add_Last($1, NOT_NEED);
		Print_Tree(root, 0);
	}
    ;
start:	IMPORT start	
	{
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type;
		child = make_token_node($1, NOT_SPACE);
		Add_Child(parent, child, NEED_NOW);
		Add_Last($2, NOT_NEED);

		$$ = parent;
	}
    |	PACK start 
    	{
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type;
		child = make_token_node($1, NOT_SPACE);
		Add_Child(parent, child, NEED_NOW);
		Add_Last($2, NOT_NEED);
		
		$$ = parent;
	}
    |	eval
	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		child = make_token_node("public class", NEED_SPACE);
		Add_Child(parent, child, NOT_NEED);
		child = make_class_node(main_class, NULL);
		Add_Last(child, NOT_NEED);
		child = make_token_node("{\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($1, NOT_NEED);
		child = make_token_node("}\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);

		$$ = parent; 
	}
    ;
eval:	expr eval	
    	{
		parent = make_nt_node();
		tmp_node = $1;
		tmp_type = tmp_node -> type;
		tmp_node = $2;
		if(tmp_type >= tmp_node -> type)
			tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
		Add_Last($2, NOT_NEED);

		$$ = parent;
    	}
    |	expr	
	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
		
		$$ = parent;
	}
    |	main_fun eval
	{
		parent = make_nt_node();
		tmp_node = $1;
		tmp_type = tmp_node -> type;
		tmp_node = $2;
		if(tmp_type >= tmp_node -> type)
			tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1,NOT_NEED);
		Add_Last($2, NOT_NEED);

		$$ = parent;
	}
    ;
expr:	for_stt
 	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
		
		$$ = parent; 
	}	
    |	while_stt	
	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
	
		$$ = parent;
	}
    |	if_stt	
	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
		
		$$ = parent;
	}
    |	when_stt
	{
		parent= make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);

		$$ = parent;
	}
    |	var_decl
	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NEED);
	
		$$ = parent;
	}
    |	val_decl
	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NEED);
		
		$$ = parent; 
	}
    |	cal_sent	
	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NEED);
	
		$$ = parent; 
	}
    |	fun_stt		
	{ 
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);

		$$ = parent;
	}
    |	com
	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
		
		$$ = parent;
	}
    |	ID assign cal_sent
	{
		parent = make_nt_node();
		tmp_node = $3;
		parent -> type = tmp_node -> type;
		tmp_idx = Find_var_index($1, id_name);
		if(tmp_idx == -1)
			tmp_idx = Var_Save($1, tmp_node -> data, tmp_node -> type, id_name, data, id_type);
		child = make_id_node(id_name[tmp_idx], id_type[tmp_idx], data[tmp_idx]);
		child -> data = tmp_node -> data;
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);
		Add_Last($3, NEED);

		$$ = parent;
	}
    |	ID EQUAL STR
	{
		parent = make_nt_node();
		tmp_str = $3;
		tmp_idx = Find_var_index($1, id_name);
		if(tmp_idx == -1)
			tmp_idx = Var_Save($1, 0, String, id_name, data, id_type); 
		child = make_id_node(id_name[tmp_idx], id_type[tmp_idx], 0);
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node("=", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		child = make_token_node($3, NOT_SPACE);
		Add_Last(child, NEED);

		$$ = parent;
	}
    |	ID lambda
	{
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type;
		child = make_id_node($1, tmp_node -> type, tmp_node -> data);
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node(".", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		child = make_token_node("stream()", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($2, NEED);

		$$ = parent;
	}
    |	class_stt
	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NEED);
		
		$$ = parent;
	}
    |	epsilone
	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);

		$$ = parent;
	}
    ;
generic:	GREATER type LESS
		{
			parent = make_nt_node();
			child = make_token_node("<", NOT_SPACE);
			tmp_node = $2;
			child -> type = tmp_node -> type;
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);
			child = make_token_node(">", NEED_SPACE);
			Add_Last(child, NOT_NEED);
	
			$$ = parent;
		}
	;
class_stt:	ABST CLASS ID OPEN class_param CLOSE c_inheritance M_OPEN class_decl M_CLOSE
	  	{
			parent = make_nt_node();
			parent -> type = Class;
			child = make_token_node("abstract", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			child = make_token_node("class", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			tmp_idx = Class_type_Save($3, class_type); 
			if(tmp_idx == -1)
			{
				printf("Error : Duplicated Class Type.\n");
				exit(1);
			}
			child = make_class_type_node(class_type[tmp_idx]);
			Add_Last(child, NOT_NEED);
			child = make_token_node("(", NOT_SPACE);	
			Add_Last(child, NOT_NEED);
			Add_Last($5, NOT_NEED);
			child = make_token_node(")", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($7, NOT_NEED);
			child = make_token_node("{\n", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($9, NOT_NEED);
			child = make_token_node("}", NOT_SPACE);
			Add_Last(child, NOT_NEED);
	
			$$ = parent;
		}
	|	CLASS ID OPEN class_param CLOSE c_inheritance M_OPEN class_decl M_CLOSE
	  	{
			parent = make_nt_node();
			parent -> type = Class;
			child = make_token_node("class", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			tmp_idx = Class_type_Save($2, class_type); 
			if(tmp_idx == -1)
			{
				printf("Error : Duplicated Class Type.\n");
				exit(1);
			}
			child = make_class_type_node(class_type[tmp_idx]);
			Add_Last(child, NOT_NEED);
			child = make_token_node("(", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($4, NOT_NEED);
			child = make_token_node(")", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($6, NOT_NEED);
			child = make_token_node("{\n", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($8, NOT_NEED);
			child = make_token_node("}", NOT_SPACE);
			Add_Last(child, NOT_NEED);
	
			$$ = parent;
		}
	|	INTER ID M_OPEN class_decl M_CLOSE
	  	{
			parent = make_nt_node();
			parent -> type = Class;
			child = make_token_node("interface", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			tmp_idx = Class_type_Save($2, class_type); 
			if(tmp_idx == -1)
			{
				printf("Error : Duplicated Class Type.\n");
				exit(1);
			}
			child = make_class_type_node(class_type[tmp_idx]);
			Add_Last(child, NOT_NEED);
			child = make_token_node("{\n", NOT_NEED);
			Add_Last(child, NOT_NEED);
			Add_Last($4, NOT_NEED);
			child = make_token_node("}", NOT_NEED);
			Add_Last(child, NOT_NEED);
	
			$$ = parent;
		}
	;
val_decl:	VAL id_decl_stt
	    	{
			parent = make_nt_node();
			tmp_node = $2;
			parent -> type = tmp_node -> type;
			child = make_token_node("final", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);

			$$ = parent;
		}
	;
var_decl:	VAR id_decl_stt
	    	{
			parent = make_nt_node();
			parent -> type = tmp_node -> type;
			child = make_token_node("", NOT_NEED);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);

			$$ = parent;
		}
	;
class_keyword:	OVER
	     	{
			parent = make_nt_node();
			parent -> type = Classtype;
			child = make_token_node("", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);

			$$ = parent;
		}
	|	ABST
		{
			parent = make_nt_node();
			parent -> type = Classtype;
			parent = make_token_node("abstract", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);

			$$ = parent;
		}
	|	epsilone
		{
			parent = make_nt_node();
			parent -> type = Not_defined;
			Add_Child(parent, $1, NOT_NEED);

			$$ = parent;
		}
	;
/*Have to check*/
class_id_decl:	class_keyword var_decl
	     	{
			parent = make_nt_node();
			tmp_node = $2;
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);
			Add_Last($2, NEED);
		
			$$ = parent;
		}
	|	class_keyword val_decl
	     	{
			parent = make_nt_node();
			tmp_node = $2;
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);
			Add_Last($2, NEED);
		
			$$ = parent;
		}
	;
class_decl:	class_id_decl class_decl
	  	{
			parent = make_nt_node();
			tmp_node = $1;
			tmp_type = tmp_node -> type;
			tmp_node = $2;
			if(tmp_type >= tmp_node -> type)
				tmp_node = $1;
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);
			Add_Last($2, NOT_NEED);
		
			$$ = parent;
		}
	|	class_method_decl class_decl
	  	{
			parent = make_nt_node();
			tmp_node = $1;
			tmp_type = tmp_node -> type;
			tmp_node = $2;
			if(tmp_type >= tmp_node -> type)
				tmp_node = $1;
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);
			Add_Last($2, NOT_NEED);
		
			$$ = parent;
		}
	|	class_id_decl
	  	{
			parent = make_nt_node();
			tmp_node = $1;
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);
		
			$$ = parent;
		}
	|	class_method_decl
	  	{
			parent = make_nt_node();
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);
		
			$$ = parent;
		}
	|	epsilone
		{
			parent = make_nt_node();
			parent -> type = Not_defined;
			Add_Child(parent, $1, NOT_NEED);
	
			$$ = parent;
		}
	;
/*Have to check*/
class_method_decl:	class_keyword fun_stt
		 	{
				parent = make_nt_node();
				tmp_node = $2;
				parent -> type = tmp_node -> type;
				Add_Child(parent, $1, NOT_NEED);
				Add_Last($2, NOT_NEED);				

				$$ = parent;
			}
	;
c_inheritance:	COLUMN inheritance
	     	{
			parent = make_nt_node();
			tmp_node = $2;
			parent -> type = tmp_node -> type;
			child = make_token_node(":", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);
		
			$$ = parent;
		}
	|	epsilone
		{
			parent = make_nt_node();
			parent -> type = Not_defined;
			Add_Child(parent, $1, NOT_NEED);
	
			$$ = parent;
		}
	;
inheritance:	fun_call COMMA inheritance
	   	{
			parent = make_nt_node();
			tmp_node = $1;
			tmp_type = tmp_node -> type;
			tmp_node = $3;
			if(tmp_type >= tmp_node -> type)
				tmp_node = $1;
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node(",", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);

			$$ = parent;
		}
	|	ID COMMA inheritance
		{
			parent = make_nt_node();
			tmp_node = $3;
			parent -> type = tmp_node -> type;
			tmp_idx = Find_class_type_index($1, class_type);
			if(tmp_idx == -1)
			{
				printf("There is no such class\n");
				exit(1);
			}
			child = make_class_type_node(class_type[tmp_idx]);
			Add_Child(parent, child, NOT_NEED);
			child = make_token_node(",", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);

			$$ = parent;
		}
	|	ID
		{
			parent = make_nt_node();
			parent -> type = Class;
			tmp_idx = Find_class_type_index($1, class_type);
			child = make_class_type_node(class_type[tmp_idx]);
			Add_Child(parent, child, NOT_NEED);

			$$ = parent;
		}
	|	fun_call
		{
			parent = make_nt_node();
			tmp_node = $1;
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);

			$$ = parent;
		}
	;
lambda: DOT ID M_OPEN cal_sent M_CLOSE lambda
      	{
		parent = make_nt_node();
		tmp_node = $4;
		tmp_type = tmp_node -> type;
		tmp_node = $6;
		if(tmp_type >= tmp_node -> type)
			tmp_node = $4;
		parent -> type = tmp_node -> type;
		child = make_token_node(".", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		tmp_idx = Fun_Save($2, Unit, fun_name, fun_type);
		child = make_fun_node(fun_name[tmp_idx], fun_type[tmp_idx]);
		Add_Last(child, NOT_NEED);
		child = make_token_node("(", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		child = make_token_node("it -> ", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($4, NOT_NEED);
		child = make_token_node(")\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($6, NOT_NEED);

		$$ = parent;
	}
    |	epsilone
	{
		parent = make_nt_node();
		parent -> type = Not_defined;
		Add_Child(parent, $1, NOT_NEED);

		$$ = parent;
	}
    ;
assign:	EQUAL
      	{
		parent = make_nt_node();
		parent -> type = Not_defined;
		child = make_token_node("=", NEED_SPACE);
		Add_Child(parent, child, NOT_NEED);

		$$ = parent;
	}
    |	E_PLUS
      	{
		parent = make_nt_node();
		parent -> type = Not_defined;
		child = make_token_node("+=", NEED_SPACE);
		Add_Child(parent, child, NOT_NEED);

		$$ = parent;
	}
    |	E_MINUS
      	{
		parent = make_nt_node();
		parent -> type = Not_defined;
		child = make_token_node("-=", NEED_SPACE);
		Add_Child(parent, child, NOT_NEED);

		$$ = parent;
	}
    |	E_MULT
      	{
		parent = make_nt_node();
		parent -> type = Not_defined;
		child = make_token_node("*=", NEED_SPACE);
		Add_Child(parent, child, NOT_NEED);

		$$ = parent;
	}
    |	E_DIV
      	{
		parent = make_nt_node();
		parent -> type = Not_defined;
		child = make_token_node("/=", NEED_SPACE);
		Add_Child(parent, child, NOT_NEED);

		$$ = parent;
	}
    ;
main_fun: FUNC MAIN OPEN CLOSE fun_body
	{
		parent = make_nt_node();
		tmp_node = $5;
		parent -> type = Unit;
		child = make_token_node("public static void", NEED_SPACE);
		Add_Child(parent, child, NOT_NEED);
		child = make_fun_node("main", Unit);
		Add_Last(child, NOT_NEED);
		child = make_token_node("(", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		child = make_token_node("String[] args", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		child = make_token_node(")", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($5, NOT_NEED);
	
		$$ = parent;
	}
    ;
cal_sent: cal_sent PLUS term	
       	  {
		parent = make_nt_node();
		tmp_node = $1;
		tmp_type = tmp_node -> type;
		tmp_node = $3;
		if(tmp_type >= tmp_node -> type)
			tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
		child = make_token_node("+", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NOT_NEED);

		$$ = parent;
	  }
    |	  cal_sent MINUS term
	  {
		parent = make_nt_node();
		tmp_node = $1;
		tmp_type = tmp_node -> type;
		tmp_node = $3;
		if(tmp_type >= tmp_node -> type)
			tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
		child = make_token_node("-", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NOT_NEED);

		$$ = parent;
	  }
    |	  term			
	  {
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		parent -> name = tmp_node -> name;
		Add_Child(parent, $1, NOT_NEED);
	
		$$ = parent;
	  }
    ;
term:	term MULT signed_factor 
    	{ 
		parent = make_nt_node();
		tmp_node = $1;
		tmp_type = tmp_node -> type;
		tmp_node = $3;
		if(tmp_type >= tmp_node -> type)
			tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
		child = make_token_node("*", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NOT_NEED);

		$$ = parent;
    	} 
    |	term DIV signed_factor	
	{ 
		parent = make_nt_node();
		tmp_node = $1;
		tmp_type = tmp_node -> type;
		tmp_node = $3;
		if(tmp_type >= tmp_node -> type)
			tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
		child = make_token_node("/", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NOT_NEED);

		$$ = parent;
	} 
    |	signed_factor	
	{ 
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		parent -> name = tmp_node -> name;
		Add_Child(parent, $1, NOT_NEED);

		$$ = parent;
	}
    ;
signed_factor:	PLUS factor 
	     	{ 
			parent = make_nt_node();
			tmp_node = $2;
			parent -> type = tmp_node -> type;
			child = make_token_node("+", NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);

			$$ = parent;
	     	}
	|    	MINUS factor 
		{ 
			parent = make_nt_node();
			tmp_node = $2;
			parent -> type = tmp_node -> type;
			child = make_token_node("-", NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);

			$$ = parent;
		}
    	|	factor 
		{
			parent = make_nt_node();
			tmp_node = $1;
			parent -> type = tmp_node -> type;
			parent -> name = tmp_node -> name;
			Add_Child(parent, $1, NOT_NEED);

			$$ = parent;
		}
    ;
factor: NUMBER	
      	{
		parent = make_nt_node();
		tmp_str = $1;
		int len = strlen(tmp_str);
		tmp_type = Int;
		for(int i = 0; i < len; i++)
		{
			if(tmp_str[i] =='.')
				tmp_type = Double;
		}	
		parent -> type = tmp_type;
		child = make_token_node($1, NEED_SPACE);
		child -> type = tmp_type;
		Add_Child(parent, child, NOT_NEED);
		
		$$ = parent;
        }
    |	L_NUMBER	
      	{
		parent = make_nt_node();
		parent -> type = Long;
		child = make_token_node($1, NEED_SPACE);
		child -> type = tmp_type;
		Add_Child(parent, child, NOT_NEED);

		$$ = parent;
	}
    |	ID 	
	{ 
		parent = make_nt_node();
		tmp_idx = Find_var_index($1, id_name);
		if(tmp_idx == -1)
			tmp_idx = Var_Save($1, 0, Not_defined, id_name, data, id_type);
		parent -> type = id_type[tmp_idx];
		child = make_id_node(id_name[tmp_idx], id_type[tmp_idx], 0);
		child -> type = id_type[tmp_idx];
		Add_Child(parent, child, NOT_NEED);

		$$ = parent;
	}
    |	ID DOT fun_call 
	{ 
		parent = make_nt_node();
		tmp_node = $3;
		parent -> type = tmp_node -> type;
		tmp_idx = Find_var_index($1, id_name);
		if(tmp_idx == -1)
			tmp_idx = Var_Save($1, 0, tmp_node -> type, id_name, data, id_type);
		child = make_id_node(id_name[tmp_idx], id_type[tmp_idx], 0);
		child -> space = NOT_SPACE;
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node(".", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NOT_NEED);

		$$ = parent;
	}	
    |	ID DOT ID
	{ 
		parent = make_nt_node();
		tmp_idx = Find_var_index($1, id_name);
		if(tmp_idx == -1)
			tmp_idx = Var_Save($1, 0, Not_defined, id_name, data, id_type);
		parent -> type = id_type[tmp_idx];
		child = make_id_node(id_name[tmp_idx], id_type[tmp_idx], 0);
		child -> space = NOT_SPACE;
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node(".", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		tmp_idx = Find_var_index($3, id_name);
		if(tmp_idx == -1)
			tmp_idx = Var_Save($3, 0, Not_defined, id_name, data, id_type);
		child = make_id_node(id_name[tmp_idx], id_type[tmp_idx], 0);
		Add_Last(child, NOT_NEED);

		$$ = parent;
	}
    |	ID INC
	{ 
		parent = make_nt_node();
		parent -> type = Int;
		tmp_idx = Find_var_index($1, id_name);
		child = make_id_node(id_name[tmp_idx], Int, 0);
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node("++", NOT_SPACE);
		Add_Last(child, NOT_NEED);

		$$ = parent;
	}
    |	ID DEC
	{ 
		parent = make_nt_node();
		parent -> type = Int;
		tmp_idx = Find_var_index($1, id_name);
		child = make_id_node(id_name[tmp_idx], Int, 0);
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node("--", NOT_SPACE);
		Add_Last(child, NOT_NEED);

		$$ = parent;
	}
    |	INC ID
	{ 
		parent = make_nt_node();
		parent -> type = Int;
		child = make_token_node("++", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		tmp_idx = Find_var_index($2, id_name);
		child = make_id_node(id_name[tmp_idx], Int, 0);
		Add_Last(child, NOT_NEED);

		$$ = parent;
	}
    |	DEC ID
	{ 
		parent = make_nt_node();
		parent -> type = Int;
		child = make_token_node("--", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		tmp_idx = Find_var_index($2, id_name);
		child = make_id_node(id_name[tmp_idx], Int, 0);
		Add_Last(child, NOT_NEED);

		$$ = parent;
	}
    |	OPEN cal_sent CLOSE 
	{ 
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type;
		child = make_token_node("(", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);
		child = make_token_node(")", NOT_SPACE);
		Add_Last(child, NOT_NEED);

		$$ = parent;
	}
    |	fun_call
	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		parent -> name = tmp_node -> name;
		Add_Child(parent, $1, NOT_NEED);

		$$ = parent;
	}
    |	NUL	
	{ 
		parent = make_nt_node();
		parent -> type = Int;
		child = make_token_node("null", NOT_SPACE);
		child -> type = Int;
		Add_Child(parent, child, NOT_NEED);

		$$ = parent;
	}
    ;
param:	ID COLUMN fun_type COMMA param 
     	{ 
		parent = make_nt_node();
		Add_Child(parent, $3, NOT_NEED);
		tmp_node = $3;
		tmp_type = tmp_node -> type;
		tmp_node = $5;
		if(tmp_type >= tmp_node -> type)
			tmp_node = $3;
		tmp_idx = Var_Save($1, 0, tmp_node -> type, id_name, data, id_type);
		child = make_id_node(id_name[tmp_idx], tmp_node -> type, 0);
		parent -> type = tmp_node -> type;	
		Add_Last(child, NOT_NEED);
		child = make_token_node(",", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($5, NOT_NEED);
		
		$$ = parent;
     	}
    |	ID COLUMN fun_type		
	{
		parent = make_nt_node();
		Add_Child(parent, $3, NOT_NEED);
		tmp_node = $3;
		parent -> type = tmp_node -> type;	
		tmp_idx = Var_Save($1, 0, tmp_node -> type, id_name, data, id_type);
		child = make_id_node(id_name[tmp_idx], id_type[tmp_idx], 0);
		Add_Last(child, NOT_NEED);

		$$ = parent;
	}
    |	epsilone
	{
		parent = make_nt_node();
		parent -> type = 0;
		Add_Child(parent, $1, NOT_NEED);
		
		$$ = parent;
	}
    ;
class_param:	VAL id_decl COMMA class_param
	    	{
			parent = make_nt_node();
			tmp_node = $2;
			tmp_type = tmp_node -> type;
			tmp_node = $4;
			if(tmp_type >= tmp_node -> type)
				tmp_node = $2;
			parent -> type = tmp_node -> type;
			child = make_token_node("final", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);
			child = make_token_node(",", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($4, NOT_NEED);

			$$ = parent;
		}
	|	VAR id_decl COMMA class_param
	    	{
			parent = make_nt_node();
			tmp_node = $2;
			tmp_type = tmp_node -> type;
			tmp_node = $4;
			if(tmp_type >= tmp_node -> type)
				tmp_node = $2;
			parent -> type = tmp_node -> type;
			child = make_token_node("", NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);
			child = make_token_node(",", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($4, NOT_NEED);

			$$ = parent;
		}
	|	VAL id_decl
	    	{
			parent = make_nt_node();
			tmp_node = $2;
			parent -> type = tmp_node -> type;
			child = make_token_node("final", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);

			$$ = parent;
		}
	|	VAR id_decl
	    	{
			parent = make_nt_node();
			tmp_node = $2;
			parent -> type = tmp_node -> type;
			child = make_token_node("", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);

			$$ = parent;
		}
	|	epsilone
		{
			parent = make_nt_node();
			parent -> type = Not_defined;
			Add_Child(parent, $1, NOT_NEED);
			
			$$ = parent;
		}
	;
type:	INT	
    	{
		parent = make_nt_node();
		parent -> type = Int;
		child = make_token_node("int", NEED_SPACE);
		child -> type = Int;
		Add_Child(parent, child, NOT_NEED);
		
		$$ = parent;
    	}
    |	LONG
    	{
		parent = make_nt_node();
		parent -> type = Long;
		child = make_token_node("long", NEED_SPACE);
		child -> type = Long;
		Add_Child(parent, child, NOT_NEED);
		
		$$ = parent;
    	}
    |	FLOAT	
	{ 
		parent = make_nt_node();
		parent -> type = Float;
		child = make_token_node("float", NEED_SPACE);
		child -> type = Float;
		Add_Child(parent, child, NOT_NEED);
		
		$$ = parent;
	}
    |	DOUBLE	
	{ 
		parent = make_nt_node();
		parent -> type = Double;
		child = make_token_node("double", NEED_SPACE);
		child -> type = Double;
		Add_Child(parent, child, NOT_NEED);
		
		$$ = parent;
	}
    |	STRING	
	{ 
		parent = make_nt_node();
		parent -> type = String;
		child = make_token_node("String", NEED_SPACE);
		child -> type = String;
		Add_Child(parent, child, NOT_NEED);
		
		$$ = parent;
	}
    |	CHAR	
	{ 
		parent = make_nt_node();
		parent -> type = Char;
		child = make_token_node("char", NEED_SPACE);
		child -> type = Char;
		Add_Child(parent, child, NOT_NEED);
		
		$$ = parent;
	}
    |	BOOL
	{
		parent = make_nt_node();
		parent -> type = Bool;
		child = make_token_node("bool", NEED_SPACE);
		child -> type = Bool;
		Add_Child(parent, child, NOT_NEED);
		
		$$ = parent;
	}
/*Have to check*/
    |	LIST generic
	{
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type + List;
		child = make_token_node("List", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		
		$$ = parent;
	}
    ;
fun_type:	type
	  	{
			parent = make_nt_node();
			tmp_node = $1;
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);

			$$ = parent;
		}
	|
	  	UNIT	
		{ 
			parent = make_nt_node();
			parent -> type = Unit;
			child = make_token_node("void", NEED_SPACE);
			child -> type = Unit;
			Add_Child(parent, child, NOT_NEED);
			child -> type = Unit;

			$$ = parent;
		}
    	|	ANY	
		{ 
			parent = make_nt_node();
			parent -> type = Any;
			child = make_token_node("Object", NEED_SPACE);
			child -> type = Any;
			Add_Child(parent, child, NOT_NEED);
			child -> type = Any;

			$$ = parent;
		}
    	;
fun_stt:  FUNC ID OPEN param CLOSE ret_type fun_body 
       	{
		parent = make_nt_node();
		child = make_token_node("public static", NEED_SPACE);
		Add_Child(parent, child, NOT_NEED);
		tmp_node = $6;
		if(tmp_node -> type == Not_defined)
		{
			tmp_node = $4;
			if(tmp_node -> type == Not_defined)
				tmp_node = $7;
		}
		child = make_token_node(ttos(tmp_node -> type), NEED_SPACE);
		parent -> type = tmp_node -> type;
		Add_Last(child, NOT_NEED);
		tmp_idx = Fun_Save($2, tmp_node -> type, fun_name, fun_type);
		child = make_fun_node(fun_name[tmp_idx], fun_type[tmp_idx]);
		Add_Last(child, NOT_NEED);
		child = make_token_node("(", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($4, NOT_NEED);
		child = make_token_node(")", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($7, NOT_NEED);

		$$ = parent;
      	}
    ;
ret_type: COLUMN type QUESTION 
	{
		parent = make_nt_node();
		tmp_node = $2;
		tmp_node -> type += Question;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $2, NOT_NEED);

		$$ = parent;
	}
    |	  COLUMN fun_type
	{
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $2, NOT_NEED);

		$$ = parent;
	}
    |	 epsilone
	{
		parent = make_nt_node();
		parent -> type = Not_defined;
		Add_Child(parent, $1, NOT_NEED);
	
		$$ = parent;
	}
    ;
fun_body: M_OPEN eval RETURN cal_sent M_CLOSE	
	{
		parent = make_nt_node();
		tmp_node = $4;
		parent -> type = tmp_node -> type;
		child = make_token_node("{\n", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);
		child = make_token_node("return", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($4, NEED);
		child = make_token_node("}\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);

		$$ = parent;
	}
    |	 M_OPEN eval RETURN M_CLOSE	
	{
		parent = make_nt_node();
		parent -> type = Unit;
		child = make_token_node("{\n", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);
		child = make_token_node("return", NEED_SPACE);
		Add_Last(child, NEED);
		child = make_token_node("}\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);

		$$ = parent;
	}
    |	  M_OPEN eval M_CLOSE	
	{ 
		parent = make_nt_node();
		parent -> type = Unit;
		child = make_token_node("{\n", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);
		child = make_token_node("}\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);

		$$ = parent;
	}
    |	  EQUAL cal_sent	
	{
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type;
		child = make_token_node("{\n", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node("return", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($2, NEED);
		child = make_token_node("}\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);
	
		$$ = parent;
	}
    |	 EQUAL if_stt
	{
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type;
		child = make_token_node("{\n", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);
		child = make_token_node("}\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);
	
		$$ = parent;
	}
    |	 EQUAL when_stt
	{
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type;
		child = make_token_node("{\n", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);
		child = make_token_node("}\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);
	
		$$ = parent;
	}
    |	  epsilone		
	{
		parent = make_nt_node();
		parent -> type = Not_defined;
		Add_Child(parent, $1, NOT_NEED);

		$$ = parent;
	}
    ;
while_stt: WHILE OPEN condition CLOSE M_OPEN loop_body M_CLOSE 
	 {
		parent = make_nt_node();
		tmp_node = $6;
		parent -> type = tmp_node -> type;
		child = make_token_node("while", NEED_SPACE);
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node("(", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NOT_NEED);
		child = make_token_node(")", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		child = make_token_node("{\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($6, NOT_NEED);
		child = make_token_node("}\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);

		$$ = parent;
	 }
    ;
for_stt: FOR OPEN condition CLOSE M_OPEN loop_body M_CLOSE 
	 {
		parent = make_nt_node();
		tmp_node = $6;
		parent -> type = tmp_node -> type;
		child = make_token_node("for", NEED_SPACE);
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node("(", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NOT_NEED);
		child = make_token_node(")", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		child = make_token_node("{\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($6, NOT_NEED);
		child = make_token_node("}\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);

		$$ = parent;
      	 }
    ;
loop_body: eval		
	 {
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
		
		$$ = parent;
	 }
    ;
when_body: when_id ARROW when_id when_body
	{
		parent = make_nt_node();
		tmp_node = $3;
		parent -> type = tmp_node -> type;
		child = make_token_node("case", NEED_SPACE);
		Add_Child(parent ,child, NOT_NEED);
		Add_Last($1, NOT_NEED);
		child = make_token_node(":", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		child = make_token_node("return", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NEED);
		Add_Last($4, NOT_NEED);
		
		$$ = parent;
	}
    |	   ELSE ARROW when_id
	{
		parent = make_nt_node();
		tmp_node = $3;
		parent -> type = tmp_node -> type;
		child = make_token_node("default", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node(":", NEED_SPACE);
		Add_Last(child, NEED);
		child = make_token_node("return", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NOT_NEED);

		$$ = parent;
	}
    |	  when_condition ARROW when_id when_body
	{
		parent = make_nt_node();
		tmp_node = $3;
		parent -> type = tmp_node -> type;
		child = make_token_node("case", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($1, NOT_NEED);
		child = make_token_node(":", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		child = make_token_node("return", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NEED);
		Add_Last($4, NOT_NEED);

		$$ = parent;
	}
    |	   epsilone	
	{
		parent = make_nt_node();
		parent -> type = Not_defined;
		Add_Child(parent, $1, NOT_NEED);
	
		$$ = parent;
	}
    ;
/*Have to check*/
when_id: STR
	{
		parent = make_nt_node();
		parent -> type = String;
		child = make_token_node($1, NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);

		$$ = parent;
	}
    |	 cal_sent
	{
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);

		$$ = parent;
	}
    ;
when_condition:	IS type
		{
			parent = make_nt_node();
			parent -> type = Bool;
			child = make_token_node("instanceof", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);

			$$ = parent;
		}
	|	NOT IS type
		{
			parent = make_nt_node();
			parent -> type = Bool;
			child = make_token_node("!", NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
			child = make_token_node("instanceof", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);

			$$ = parent;
		}
	|	when_id IN cal_sent range
		{
			parent = make_nt_node();
			parent -> type = Bool;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node(":", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
			Add_Last($4, NOT_NEED);
		
			$$ = parent;
		}
	|	when_id NOT IN cal_sent range
		{
			parent = make_nt_node();
			parent -> type = Bool;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node("!", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			child = make_token_node(":", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($4, NOT_NEED);
			Add_Last($5, NOT_NEED);
		
			$$ = parent;
		}
	;
when_stt:  WHEN OPEN ID CLOSE M_OPEN when_body M_CLOSE	
	{
		parent = make_nt_node();
		tmp_node = $6;
		parent -> type = tmp_node -> type;
		child = make_token_node("switch", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node("(", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		tmp_idx = Var_Save($3, 0, Not_defined, id_name, data, id_type);
		child = make_id_node(id_name[tmp_idx], id_type[tmp_idx], 0);
		Add_Last(child, NOT_NEED);
		child = make_token_node(")", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		child = make_token_node("{\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($6, NOT_NEED);
		child = make_token_node("}\n", NOT_SPACE);	
		Add_Last(child, NOT_NEED);
		
		$$ = parent;
	}
    |	   WHEN M_OPEN when_body M_CLOSE
	{
		parent = make_nt_node();
		tmp_node = $3;
		parent -> type = tmp_node -> type;
		child = make_token_node("switch", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node("{\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NOT_NEED);
		child = make_token_node("}\n", NOT_SPACE);	
		Add_Last(child, NOT_NEED);

		$$ = parent;
	}
    ;
if_stt:	IF noelse
      	{
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type;
		child = make_token_node("if", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);

		$$ = parent;
	}
    |	IF withelse
	{
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type;
		child = make_token_node("if", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);

		$$ = parent;
	}
    ;
noelse:	OPEN condition CLOSE cf
      	{
		parent = make_nt_node();
		tmp_node = $4;
		parent -> type = tmp_node -> type;
		child = make_token_node("(", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);
		child = make_token_node(")", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($4, NOT_NEED);

		$$ = parent;
	}
    ;
withelse: OPEN condition CLOSE cf
	{
		parent = make_nt_node();
		tmp_node = $4;
		parent -> type = tmp_node -> type;
		child = make_token_node("(", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);
		child = make_token_node(")", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($4, NOT_NEED);

		$$ = parent;
	}
    |	  OPEN condition CLOSE cf else_part
	{
		parent = make_nt_node();
		tmp_node = $4;
		parent -> type = tmp_node -> type;
		child = make_token_node("(", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);
		child = make_token_node(")", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($4, NOT_NEED);
		Add_Last($5, NOT_NEED);

		$$ = parent;
	}
    ;
else_part: ELSEIF OPEN condition CLOSE cf else_part
	 {
		parent = make_nt_node();
		tmp_node = $5;
		parent -> type = tmp_node -> type;
		child = make_token_node("else if", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		child = make_token_node("(", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NOT_NEED);
		child = make_token_node(")", NOT_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($5, NOT_NEED);
		Add_Last($6, NOT_NEED);
	
		$$ = parent;
	 }
    |	   ELSE cf
	 {
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type;
		child = make_token_node("else", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);

		$$ = parent;
	 }
    |	   epsilone
	 {
		parent = make_nt_node();
		parent -> type = Not_defined;
		Add_Child(parent, $1, NOT_NEED);
	
		$$ = parent;
	 }
    ;
cf:	 M_OPEN cf_body M_CLOSE
	 {
		parent = make_nt_node();
		tmp_node = $2;
		parent -> type = tmp_node -> type;
		child = make_token_node("{\n", NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);
		Add_Last($2, NOT_NEED);
		child = make_token_node("}\n", NOT_SPACE);
		Add_Last(child, NOT_NEED);

		$$ = parent;
	 }
    |	 cf_body
	 {
		parent = make_nt_node();
		tmp_node = $1;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
		
		$$ = parent;
	 }
	 
cf_body: eval RETURN cal_sent	
       	{
		parent = make_nt_node();
		tmp_node = $3;
		parent -> type = tmp_node -> type;
		Add_Child(parent, $1, NOT_NEED);
		child = make_token_node("return", NEED_SPACE);
		Add_Last(child, NOT_NEED);
		Add_Last($3, NEED);
		
		$$ = parent;
	}
    |	eval RETURN	
       	{
		parent = make_nt_node();
		parent -> type = Unit;
		Add_Child(parent, $1, NOT_NEED);
		child = make_token_node("return", NEED_SPACE);
		Add_Last(child, NEED);
		
		$$ = parent;
	}	
    |	eval
       	{
		parent = make_nt_node();
		parent -> type = Unit;
		Add_Child(parent, $1, NOT_NEED);
		
		$$ = parent;
	}
    ;
com: 	COMMENT	
     	{
		parent = make_nt_node();
		parent -> type = Unit;
		child = make_token_node($1, NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);

		$$ = parent;
	}
    |	COMMENT_LONG	
	{ 
		parent = make_nt_node();
		parent -> type = Unit;
		child = make_token_node($1, NOT_SPACE);
		Add_Child(parent, child, NOT_NEED);

		$$ = parent;
	}
    ;
condition  :	is_condition	
	   	{ 
			parent = make_nt_node();
			parent -> type = Bool;
			Add_Child(parent, $1, NOT_NEED);
		
			$$ = parent;
		}
	|	condition SAME condition	
		{	
			parent = make_nt_node();
			parent -> type = Bool;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node("==", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
	
			$$ = parent;
		}
	|	condition GREATER condition
		{
			parent = make_nt_node();
			parent -> type = Bool;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node("<", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
	
			$$ = parent;
		}
	|	condition LESS condition
		{
			parent = make_nt_node();
			parent -> type = Bool;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node(">", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
	
			$$ = parent;
		}
	|	condition E_GREATER condition
		{
			parent = make_nt_node();
			parent -> type = Bool;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node("<=", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
	
			$$ = parent;
		}
	|	condition E_LESS condition
		{
			parent = make_nt_node();
			parent -> type = Bool;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node(">=", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
	
			$$ = parent;
		}
	|	condition AND condition
		{
			parent = make_nt_node();
			parent -> type = Bool;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node("&&", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
	
			$$ = parent;
		}
	|	condition OR condition
		{
			parent = make_nt_node();
			parent -> type = Bool;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node("||", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
	
			$$ = parent;
		}
	|	condition NOT_SAME condition
		{
			parent = make_nt_node();
			parent -> type = Bool;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node("!=", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
	
			$$ = parent;
		}
	|	cal_sent	
		{ 
			parent = make_nt_node();
			tmp_node = $1;
			parent -> name = tmp_node -> name;
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);

			$$ = parent;
		}
	|	signed_factor IN cal_sent range	
		{
			parent = make_nt_node();
			parent -> type = Bool;
			tmp_node = $3;
			tmp_str = ttos(tmp_node -> type - List);
			child = make_token_node(tmp_str, NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($1, NOT_NEED);
			tmp_node = $4;
			if(tmp_node -> type == Not_defined)
			{
				child = make_token_node(":", NEED_SPACE);
				Add_Last(child, NOT_NEED);
				Add_Last($3, NOT_NEED);
			}
			else
			{
				Add_Last($3, NEED);
				Add_Last($1, NOT_NEED);
				Add_Last($4, NOT_NEED);
			}

			$$ = parent;
		}
	|	signed_factor NOT IN cal_sent range	
		{
			parent = make_nt_node();
			parent -> type = Bool;
			tmp_node = $4;
			if(tmp_node -> type > List)
			{
				tmp_str = ttos(tmp_node -> type - List);
				child = make_token_node(tmp_str, NEED_SPACE);
				Add_Child(parent, child, NOT_NEED);
			}
			Add_Last($1, NOT_NEED);
			child = make_token_node("!", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			child = make_token_node(":", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($4, NOT_NEED);
			Add_Last($5, NOT_NEED);

			$$ = parent;
		}
	;
is_condition :	ID IS type	
	     	{ 
			parent = make_nt_node();
			parent -> type = Bool;
			tmp_idx = Var_Save($1, 0, Not_defined, id_name, data, id_type);
			child = make_id_node(id_name[tmp_idx], id_type[tmp_idx], 0);
			Add_Child(parent, child, NOT_NEED);
			child = make_token_node("instanceof", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);

			$$ = parent;
	     	}
	|	ID NOT IS type	
		{
			parent = make_nt_node();
			parent -> type = Bool;
			tmp_idx = Var_Save($1, 0, Not_defined, id_name, data, id_type);
			child = make_id_node(id_name[tmp_idx], id_type[tmp_idx], 0);
			Add_Child(parent, child, NOT_NEED);
			child = make_token_node("!", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			child = make_token_node("instanceof", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($4, NOT_NEED);

			$$ = parent;
		}
	;
range	:	DOT cal_sent step_count 
      		{
			parent = make_nt_node();
			parent -> type = Bool;
			child = make_token_node("<=", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);
			child = make_token_node("+", NOT_SPACE);
			Add_Last($3, NOT_NEED);

			$$ = parent;
      		}
	|	DOWNTO cal_sent step_count 
		{
			parent = make_nt_node();
			parent -> type = Bool;
			child = make_token_node("-", NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);
			Add_Last($3, NOT_NEED);

			$$ = parent;
		}
	|	epsilone
		{
			parent = make_nt_node();
			parent -> type = Not_defined;
			Add_Child(parent, $1, NOT_NEED);
	
			$$ = parent;
		}
	;
step_count:	STEP factor
	  	{ 
			parent = make_nt_node();
			tmp_node = $2;
			parent -> type = tmp_node -> type;
			child = make_token_node("=", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);
	
			$$ = parent;
	  	}
	|	epsilone
		{
			parent = make_nt_node();
			parent -> type = Not_defined;
			Add_Child(parent, $1, NOT_NEED);
	
			$$ = parent;
		}
	;
withelse:	ELSEIF expr withelse	
		{
			parent = make_nt_node();
			tmp_node = $2;
			parent -> type = tmp_node -> type;
			child = make_token_node("else if", NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);
			Add_Last($3, NOT_NEED);

			$$ = parent;
		}
	|	ELSE expr		
		{
			parent = make_nt_node();
			tmp_node = $2;
			parent -> type = tmp_node -> type;
			child = make_token_node("else", NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);

			$$ = parent;
		}
	;
id_decl:	ID 
       		{
			parent = make_nt_node();
			tmp_idx = Find_var_index($1, id_name);
			if(tmp_idx == -1)
			{
				tmp_idx = Var_Save($1, 0, Not_defined, id_name, data, id_type);
			}
			parent -> type = id_type[tmp_idx];
			parent -> name = $1;
			child = make_id_node(id_name[tmp_idx], id_type[tmp_idx], 0);
			child -> type = id_type[tmp_idx];
			Add_Child(parent, child, NOT_NEED);

			$$ = parent;
		}
	|	ID COLUMN type
		{
			parent = make_nt_node();
			tmp_node = $3;
			parent -> type = tmp_node -> type;
			tmp_idx = Var_Save($1, 0, tmp_node -> type, id_name, data, id_type);
			child = make_id_node(id_name[tmp_idx], tmp_node -> type, 0);
			Add_Child(parent, child, NOT_NEED);
		
			$$ = parent;
		}
	;
id_decl_stt:	id_decl EQUAL decl_content COMMA id_decl_stt 
		{
			parent = make_nt_node();
			tmp_node = $1;
			if(tmp_node -> type == 0)
			{
				tmp_node = $3;
				tmp_type = tmp_node -> type;
				tmp_node = $1;
				tmp_node -> type = tmp_type;
			}
			if(tmp_node -> type == Class)
			{
				tmp_node = $3;
				tmp_idx = Find_class_type_index(tmp_node -> name, class_type);
				child = make_token_node(class_type[tmp_idx], NEED_SPACE);
				Add_Child(parent, child, NOT_NEED);
				tmp_node = $1;
			}
			else
			{
				tmp_str = ttos(tmp_node -> type);
				parent -> type = tmp_node -> type;
				tmp_node = $1;
				tmp_idx = Find_var_index(tmp_node -> child -> name, id_name);
				id_type[tmp_idx] = parent -> type;
				child = make_token_node(tmp_str, NEED_SPACE);
				Add_Child(parent, child, NOT_NEED);
			}
			Add_Last($1, NOT_NEED);
			child = make_token_node("=", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
			child = make_token_node(",", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($5, NOT_NEED);
		
			$$ = parent;
		}
 	|	id_decl	
		{
			parent = make_nt_node();
			tmp_node = $1;
			parent -> type = tmp_node -> type;
			child = make_token_node(ttos(tmp_node -> type), NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($1, NOT_NEED);

			$$ = parent;
		}
 	|	id_decl COMMA id_decl_stt	
		{
			parent = make_nt_node();
			tmp_node = $1;
			if(tmp_node -> type == 0)
				tmp_node = $3;
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node(",", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
		
			$$ = parent;
		}
	|	id_decl EQUAL decl_content	
		{
			parent = make_nt_node();
			tmp_node = $1;
			if(tmp_node -> type == 0)
			{
				tmp_node = $3;
				tmp_type = tmp_node -> type;
				tmp_node = $1;
				tmp_node -> type = tmp_type;
			}
			parent -> type = tmp_node -> type;
			if(tmp_node -> type == Class)
			{
				tmp_node = $3;
				tmp_idx = Find_class_type_index(tmp_node -> name, class_type);
				child = make_token_node(class_type[tmp_idx], NEED_SPACE);
				Add_Child(parent, child, NOT_NEED);
				tmp_node = $1;
			}
			else
			{	
				tmp_str = ttos(tmp_node -> type);
				tmp_node = $1;
				tmp_idx = Find_var_index(tmp_node -> child -> name, id_name);
				id_type[tmp_idx] = parent -> type;
				child = make_token_node(tmp_str, NEED_SPACE);
				Add_Child(parent, child, NOT_NEED);
			}
			Add_Last($1, NOT_NEED);
			child = make_token_node("=", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
		
			$$ = parent;
		}
	;
decl_content:	SETOF OPEN list_content CLOSE	
		{
			parent = make_nt_node();
			tmp_node = $3;
			parent -> type = List + tmp_node -> type;
			child = make_token_node("Set.of", NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
			child = make_token_node("(", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
			child = make_token_node(")", NOT_SPACE);
			Add_Last(child, NOT_NEED);

			$$ = parent;
		}
	|	LISTOF OPEN list_content CLOSE	
		{
			parent = make_nt_node();
			tmp_node = $3;
			parent -> type = List + tmp_node -> type;
			child = make_token_node("List.of", NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
			child = make_token_node("(", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
			child = make_token_node(")", NOT_SPACE);
			Add_Last(child, NOT_NEED);
		
			$$ = parent;
		}
	|	STR
		{
			parent = make_nt_node();
			parent -> type = String;
			child = make_token_node($1, NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);

			$$ = parent;
		}
	|	condition
		{
			parent = make_nt_node();
			tmp_node = $1;
			parent -> type = tmp_node -> type;
			parent -> name = tmp_node -> name;
			Add_Child(parent, $1, NOT_NEED);

			$$ = parent;
		}
	;
list_content:	STR COMMA list_content
	    	{
			parent = make_nt_node();
			parent -> type = String;
			child = make_token_node($1, NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
			child = make_token_node(",", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
	
			$$ = parent;
	    	}
	|	STR
		{
			parent = make_nt_node();
			parent -> type = String;
			child = make_token_node($1, NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
	
			$$ = parent;
		}
	|	cal_sent COMMA list_content
	    	{
			parent = make_nt_node();
			tmp_node = $1;
			tmp_type = tmp_node -> type;
			tmp_node = $3;
			if(tmp_type >= tmp_node -> type);
				tmp_node = $1;
			parent -> type = Double;
			Add_Child(parent, $1, NOT_NEED);
			child = make_token_node(",", NEED_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);

			$$ = parent;
	    	}
	|	cal_sent
		{
			parent = make_nt_node();
			tmp_node = $1;
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);

			$$ = parent;
		}
	;
fun_call:	ID OPEN argument CLOSE
		{
			parent = make_nt_node();
			if(strcmp($1, "println") == 0 || strcmp($1, "print") == 0)
			{
				tmp_idx = Fun_Save("System.out.println", Not_defined, fun_name, fun_type);
				parent -> type = Not_defined;
				child = make_fun_node(fun_name[tmp_idx], Not_defined);
			}
			else
			{
				tmp_idx = Find_fun_index($1, id_name);
				if(tmp_idx == -1)
				{
					tmp_idx = Find_class_type_index($1, class_type);
					if(tmp_idx == -1)
					{
						tmp_idx = Fun_Save($1, Not_defined, fun_name, fun_type);
						parent -> type = id_type[tmp_idx];
						child = make_fun_node(fun_name[tmp_idx], id_type[tmp_idx]);
					}
					else
					{
						child = make_class_type_node(class_type[tmp_idx]);
						parent -> type = Class;
						parent -> name = (char*)calloc(strlen($1) + 1, sizeof(char));
						strcpy(parent -> name, $1);
					}
				}
				else
				{
					child = make_fun_node(fun_name[tmp_idx], fun_type[tmp_idx]);
					parent -> type = fun_type[tmp_idx];
				}
			}
			child -> space = NOT_SPACE;
			Add_Child(parent, child, NOT_NEED);
			child = make_token_node("(", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
			child = make_token_node(")", NOT_SPACE);
			Add_Last(child, NOT_NEED);

			$$ = parent;
		}
	;
argument:	cal_sent mul_argument
		{
			parent = make_nt_node();
			tmp_node = $1;
			tmp_type = tmp_node -> type;
			tmp_node = $2;
			if(tmp_type >= tmp_node -> type)
				tmp_node = $1;
			parent -> type = tmp_node -> type;
			Add_Child(parent, $1, NOT_NEED);
			Add_Last($2, NOT_NEED);

			$$ = parent;
		}
	|	STR mul_argument
		{
			parent = make_nt_node();
			tmp_node = $2;
			if(String >= tmp_node -> type)
				parent -> type = String;
			else
				parent -> type = tmp_node -> type;
			child = make_token_node($1, NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);
	
			$$ = parent;
		}
	|	LISTOF OPEN list_content CLOSE mul_argument
		{
			parent = make_nt_node();
			tmp_node = $3;
			parent -> type = tmp_node -> type + List;
			child = make_token_node("List.of", NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
			child = make_token_node("(", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
			child = make_token_node(")", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($5, NOT_NEED);
	
			$$ = parent;
		}
	|	SETOF OPEN list_content CLOSE mul_argument
		{
			parent = make_nt_node();
			tmp_node = $3;
			parent -> type = tmp_node -> type + List;
			child = make_token_node("Set.of", NOT_SPACE);
			Add_Child(parent, child, NOT_NEED);
			child = make_token_node("(", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($3, NOT_NEED);
			child = make_token_node(")", NOT_SPACE);
			Add_Last(child, NOT_NEED);
			Add_Last($5, NOT_NEED);
	
			$$ = parent;
		}
	|	fun_call mul_argument
		{
			parent = make_nt_node();
			tmp_node = $1;
			tmp_type = tmp_node -> type;
			tmp_node = $2;
			if(tmp_type >= tmp_node -> type)
				tmp_node = $1;
			parent -> type = tmp_node -> type;
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);

			$$ = parent;
		}
	|	epsilone
		{
			parent = make_nt_node();
			parent -> type = Not_defined;
			Add_Child(parent, $1, NOT_NEED);
			
			$$ = parent;
		}
	;
mul_argument:	COMMA argument
	    	{
			parent = make_nt_node();
			tmp_node = $2;
			parent -> type = tmp_node -> type;
			child = make_token_node(",", NEED_SPACE);
			Add_Child(parent, child, NOT_NEED);
			Add_Last($2, NOT_NEED);
		
			$$ = parent;
		}
	|	epsilone
		{
			parent = make_nt_node();
			parent -> type = Not_defined;
			Add_Child(parent, $1, NOT_NEED);
	
			$$ = parent;
		}
	;

epsilone: /*empty*/	
	{
		parent = make_token_node("", NOT_SPACE);
		parent -> type = Not_defined;
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
	double * tmp = &value;
	if(*((int*)tmp) == value)
		return Int;
	else if(*((long*)tmp) == value)
		return Long;
	else if(*((char*)tmp) == value)
		return Char;
	else if(*((float*)tmp) == value)
		return Float;

	return Double;
}

int Check_Type_Saved(char * name, int kind)
{
	int i = 0;
	switch(kind)
	{
	//For id
	case 1:
		i = Find_var_index(name, id_name);
		return i; 
	//for function
	case 2:
		i = Find_fun_index(name, fun_name);
		return i;
	//for class
	case 3:
		i = Find_class_index(name, class_name);
	}
}
