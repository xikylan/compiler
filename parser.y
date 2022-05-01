%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "node.h"

int yylex(void);
int yyerror(char *);
int sym_tab[26];

node* make_const(int type, int i_val, char* s_val);
node* make_opr(int opr, int num_ops, ...);

#define NO_INT -1
#define NO_STR ""

FILE *output;
%}

%union
{
    int         i_val;
    char*       s_val;
    union node* n_ptr;

    char        sym_id; 
}

%token <i_val>  NUM
%token <s_val>  IDENT BOOLLIT OP2 OP3 OP4 

%token  LP RP ASGN SC IF THEN ELSE BGIN END WHILE DO PROGRAM VAR AS INT BOOL 
        WRITEINT READINT

%type <n_ptr>   program declarations type statementSequence statement assignment
                ifStatement elseClause whileStatement writeInt expression
                simpleExpression term factor

%start program
%%

program
    : PROGRAM  {fprintf(output, "int main() {\n");}
    declarations BGIN statementSequence END   
    {
        node* root = make_opr(PROGRAM, 2, $3, $5); 
        /* print_tree(root); */
        fprintf(output, "}\n")
    }
    ;

declarations
    : VAR IDENT AS type SC 
    {
        if ($4->opr.opr_type == INT)
            fprintf(output, "int "); 
        else if ($4->opr.opr_type == BOOL)
            fprintf(output, "bool "); 
        fprintf(output, "%s;\n", $2);
    }
    declarations
    {
        node* id = make_const(STR_CONST, NO_INT, $2); 
        $$ = make_opr(VAR, 3, id, $4, $7);
    }
    | /* empty */
    {
        $$ = NULL;
    }
    ;

type
    : INT 
    {
        $$ = make_opr(INT, 0);
    }
    | BOOL
    {
        $$ = make_opr(BOOL, 0);
    }
    ;

statementSequence
    : statement SC statementSequence
    {
        $$ = make_opr(SC, 2, $1, $3);
    }
    | /* empty */
    {
        $$ = NULL;
    }
    ;

statement
    : assignment
    {
        fprintf(output, ";\n");
        $$ = $1;
    }
    | ifStatement
    {
        $$ = $1;
    }
    | whileStatement
    {
        $$ = $1;
    }
    | writeInt
    {
        fprintf(output, ";\n");
        $$ = $1;
    }
    ;

assignment
    : IDENT ASGN 
    {
        fprintf(output, "%s = ", $1);
    }
    expression
    {
        node* id = make_const(STR_CONST, NO_INT, $1);
        $$ = make_opr(ASGN, 2, id, $4);
    }
    | IDENT ASGN READINT
    {
        fprintf(output, "%s = READINT", $1);
        node* id = make_const(STR_CONST, NO_INT, $1);
        $$ = make_opr(ASGN, 2, id, NULL);
    }
    ;

ifStatement
    : IF {fprintf(output, "if (");}
    expression {fprintf(output, ") \n{\n");}
    THEN statementSequence elseClause END
    {
        fprintf(output, "}\n");
        $$ = make_opr(IF, 3, $3, $6, $7);
    }
    ;
        
elseClause
    : ELSE {fprintf(output, "\n}\nelse\n{\n");}
    statementSequence
    {
        $$ = make_opr(ELSE, 1, $3);
    }
    | /* empty */
    {
        $$ = NULL;
    }
    ;

whileStatement
    : WHILE {fprintf(output, "while (");}
    expression {fprintf(output, ") \n{\n");}
    DO statementSequence END
    {
        fprintf(output, "}\n");
        $$ = make_opr(WHILE, 2, $3, $6);
    }
    ;

writeInt
    : WRITEINT {fprintf(output, "WRITEINT ");}
    expression
    {
        $$ = make_opr(WRITEINT, 1, $3);
    }
    ;

expression
    : simpleExpression
    {
        $$ = $1;
    }
    | simpleExpression OP4 {fprintf(output, " %s ", $2);}
    simpleExpression
    {
        node* op = make_const(STR_CONST, NO_INT, $2);
        $$ = make_opr(OP4, 3, $1, op, $4);
    }
    ;

simpleExpression
    : term OP3 {fprintf(output, " %s ", $2);}
    term
    {
        node* op = make_const(STR_CONST, NO_INT, $2);
        $$ = make_opr(OP3, 3, $1, op, $4);
    }
    | term
    {
        $$ = $1;
    }
    ;

term
    : factor OP2 {fprintf(output, " %s ", $2);}
    factor
    {
        node* op = make_const(STR_CONST, NO_INT, $2);
        $$ = make_opr(OP2, 3, $1, op, $4);
    }
    | factor
    {
        $$ = $1;
    }
    ;

factor
    : IDENT 
    {
        fprintf(output, "%s", $1);
        $$ = make_const(STR_CONST, NO_INT, $1);
    }
    | NUM 
    {
        fprintf(output, "%d", $1);
        $$ = make_const(INT_CONST, $1, NO_STR);
    }
    | BOOLLIT 
    {
        fprintf(output, "%s", $1);
        $$ = make_const(STR_CONST, NO_INT, $1);
    }
    | LP {fprintf(output, "(");} 
    expression RP
    {
        fprintf(output, ")");
        $$ = $3;
    }
    ;
%%

node* make_const(int type, int i_val, char* s_val)
{
	node* p;

	/* allocate node */
	if ((p = malloc(sizeof(const_node))) == NULL)
		yyerror("out of memory");

	/* copy information */
	p->type = type;
    if (type == INT_CONST)
        p->con.i_val = i_val;
    else if (type == STR_CONST)
        p->con.s_val = s_val;
	return p;
}

node* make_opr(int opr, int num_ops, ...)
{
	node* p;

	va_list ap;
	size_t size;
	int i;

	/* allocate node */
	size = sizeof(opr_node) + (num_ops - 1) * sizeof(node*);

	if ((p = malloc(size)) == NULL)
		yyerror("out of memory");

	/* copy information */
	p->type = OPR;
	p->opr.opr_type = opr;
	p->opr.num_ops = num_ops;

	va_start(ap, num_ops);
	for (i = 0; i < num_ops; i++)
		p->opr.operands[i] = va_arg(ap, node*);
	va_end(ap);

	return p;
}

int main(void) {
    output = fopen("output.c", "w");
    yyparse();
    return 0;
}

int yyerror(char *s) {
    printf("yyerror: %s\n", s);
    return 1;
}

int yywrap() {
    return 1;
}


