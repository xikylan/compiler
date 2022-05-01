%option noyywrap
%{
    #include <string.h> 
    #include "parser.tab.h"
%}

%%
[ \n\t\r]+                  { /* ignore whitespace */ } 
[1-9][0-9]*|0               { yylval.i_val = atoi(yytext);      return NUM;     } 
false|true                  { yylval.s_val = strdup(yytext);    return BOOLLIT; }
[A-Z][A-Z0-9]*              { yylval.s_val = strdup(yytext);    return IDENT;   }
"("                         { return LP;       }
")"                         { return RP;       }
":="                        { return ASGN;     }
";"                         { return SC;       }
"*"|"div"|"mod"             { yylval.s_val = strdup(yytext);    return OP2; }
"+"|"-"                     { yylval.s_val = strdup(yytext);    return OP3; }
"="|"!="|"<"|">"|"<="|">="  { yylval.s_val = strdup(yytext);    return OP4; }
"if"                        { return IF;       }
"then"                      { return THEN;     }
"else"                      { return ELSE;     }
"begin"                     { return BGIN;     }
"end"                       { return END;      }
"while"                     { return WHILE;    }
"do"                        { return DO;       }
"program"                   { return PROGRAM;  }
"var"                       { return VAR;      }
"as"                        { return AS;       }
"int"                       { return INT;      }
"bool"                      { return BOOL;     }
"writeInt"                  { return WRITEINT; }
"readInt"                   { return READINT;  } 
%%
