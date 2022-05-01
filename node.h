//typedef enum {
//    OP2_MULT,
//    OP2_DIV,
//    OP2_MOD
//} op2_type
//
//typedef enum {
//    OP3_PLUS,
//    OP3_MINUS,
//} op3_type
//
//typedef enum {
//    OP4_EQ,
//    OP4_NOT_EQ,
//    OP4_LESS,
//    OP4_GREATER,
//    OP4_LESS_EQ,
//    OP4_GREATER_EQ,
//} op4_type
//
typedef enum { 
    INT_CONST, 
    STR_CONST, 
    ID, 
    OPR 
} node_type;

/* constants */
typedef struct {
    node_type type;     /* type of node */
	int i_val;          /* value of constant */
    char* s_val;
} const_node;

/* identifiers */
typedef struct {
	node_type type;     /* type of node */
	int sym_i;          /* subscript to ident array */
} id_node;

/* operators */
typedef struct {
	node_type type;     /* type of node */
	int opr_type;       /* operator */
	int num_ops;        /* number of operands */
	union node *operands[1];     /* operands (expandable) */
} opr_node;

typedef union node {
	node_type type;     /* type of node */
	const_node con;     /* constants */
	id_node ident;      /* identifiers */
	opr_node opr;       /* operators */
} node;

extern int sym_tab[26];

char* get_op_name(int e)
{
    switch(e) {
        case PROGRAM: return "PROGRAM";
        case VAR: return "VAR";
        case INT: return "INT";
        case BOOL: return "BOOL";
        case SC: return "SC";
        case ASGN: return "ASGN";
        case IF: return "IF";
        case ELSE: return "ELSE";
        case WHILE: return "WHILE";
        case WRITEINT: return "WRITEINT";
        case OP4: return "OP4";
        case OP3: return "OP3";
        case OP2: return "OP2";
        default: 
            printf("Unknown op\n");
            return NULL;
    }
}

int print_tree(node* p) 
{
    if (!p) 
        return 0;
    switch(p->type) {
        case INT_CONST:
            printf("\tNUM: %d\n", p->con.i_val);
            break;
        case STR_CONST:
            printf("\tID: %s\n", p->con.s_val);
            break;
        case ID:
            break;
        case OPR:
            switch(p->opr.opr_type) {
                case PROGRAM:
                case VAR:
                case INT:
                case BOOL:
                case SC:
                case ASGN:
                case IF:
                case ELSE:
                case WHILE:
                case WRITEINT:
                case OP4:
                case OP3:
                case OP2:
                    printf("\t%s\n", get_op_name(p->opr.opr_type)); 
                    for (int i = 0; i < p->opr.num_ops; i++) {
                        print_tree(p->opr.operands[i]);
                    }
                    break;
        default:
            printf("Unknown\n");
            return -1;
        }
    }
}

