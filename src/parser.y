%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);

/* Global Execution Flag for If-Else logic */
int exec_enabled = 1;

typedef struct Symbol {
    char name[64];
    double value;
    int is_string;
    char str_val[256];
    struct Symbol *next;
} Symbol;

Symbol *symbol_table = NULL;

Symbol* get_symbol(const char *name) {
    Symbol *curr = symbol_table;
    while (curr) {
        if (strcmp(curr->name, name) == 0) return curr;
        curr = curr->next;
    }
    return NULL;
}

void set_number_symbol(const char *name, double val) {
    Symbol *sym = get_symbol(name);
    if (!sym) {
        sym = (Symbol*) malloc(sizeof(Symbol));
        strcpy(sym->name, name);
        sym->next = symbol_table;
        symbol_table = sym;
    }
    sym->value = val;
    sym->is_string = 0;
}

void set_string_symbol(const char *name, const char *val) {
    Symbol *sym = get_symbol(name);
    if (!sym) {
        sym = (Symbol*) malloc(sizeof(Symbol));
        strcpy(sym->name, name);
        sym->next = symbol_table;
        symbol_table = sym;
    }
    strcpy(sym->str_val, val);
    sym->is_string = 1;
}
%}

%union {
    int int_val;
    double float_val;
    char *str_val;
}

%token LET ECHO_KW ASK CHECK OTHERWISE LOOP REPEAT
%token <int_val> BOOL_VAL INT_VAL
%token <float_val> FLOAT_VAL
%token <str_val> STRING_VAL IDENTIFIER

%token EQ NE LE GE LT GT ASSIGN
%token PLUS MINUS MULT DIV MOD
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA

%type <float_val> expression

%left EQ NE LT GT LE GE
%left PLUS MINUS
%left MULT DIV MOD

%%

program:
    statement_list
    ;

statement_list:
    statement
    | statement_list statement
    ;

statement:
      var_decl SEMICOLON
    | assignment SEMICOLON
    | print_stmt SEMICOLON
    | input_stmt SEMICOLON
    | check_stmt
    | loop_stmt
    | repeat_stmt
    ;

var_decl:
      LET IDENTIFIER ASSIGN expression {
            if (exec_enabled) {
                set_number_symbol($2, $4);
            }
            free($2);
      }
    | LET IDENTIFIER ASSIGN STRING_VAL {
            if (exec_enabled) {
                set_string_symbol($2, $4);
            }
            free($2);
            free($4);
      }
    ;

assignment:
      IDENTIFIER ASSIGN expression {
            if (exec_enabled) {
                Symbol *sym = get_symbol($1);
                if (sym) {
                    set_number_symbol($1, $3);
                } else {
                    printf("Runtime Error: Variable '%s' not declared.\n", $1);
                }
            }
            free($1);
      }
    | IDENTIFIER ASSIGN STRING_VAL {
            if (exec_enabled) {
                Symbol *sym = get_symbol($1);
                if (sym) {
                    set_string_symbol($1, $3);
                } else {
                    printf("Runtime Error: Variable '%s' not declared.\n", $1);
                }
            }
            free($1);
            free($3);
      }
    ;

print_stmt:
      ECHO_KW LPAREN expression RPAREN {
            if (exec_enabled) {
                printf("%g\n", $3);
            }
      }
    | ECHO_KW LPAREN STRING_VAL RPAREN {
            if (exec_enabled) {
                printf("%s\n", $3);
            }
            free($3);
      }
    | ECHO_KW LPAREN IDENTIFIER RPAREN {
            if (exec_enabled) {
                Symbol *sym = get_symbol($3);
                if (sym) {
                    if (sym->is_string) {
                        printf("%s\n", sym->str_val);
                    } else {
                        printf("%g\n", sym->value);
                    }
                } else {
                    printf("Runtime Error: Variable '%s' not declared.\n", $3);
                }
            }
            free($3);
      }
    ;

input_stmt:
      LET IDENTIFIER ASSIGN ASK LPAREN STRING_VAL RPAREN {
            if (exec_enabled) {
                printf("%s", $6);
                double input_val;
                if (scanf("%lf", &input_val) == 1) {
                    set_number_symbol($2, input_val);
                } else {
                    printf("Input Error!\n");
                }
            }
            free($2);
            free($6);
      }
    ;

check_stmt:
      CHECK LPAREN expression RPAREN {
            $<int_val>$ = exec_enabled; /* Save outer state */
            if (exec_enabled) {
                exec_enabled = ($3 != 0);
            }
      } LBRACE statement_list RBRACE {
            if ($<int_val>5) {
                exec_enabled = ($3 == 0);
            }
      } OTHERWISE LBRACE statement_list RBRACE {
            exec_enabled = $<int_val>5; /* Restore outer state */
      }
    | CHECK LPAREN expression RPAREN {
            $<int_val>$ = exec_enabled;
            if (exec_enabled) {
                exec_enabled = ($3 != 0);
            }
      } LBRACE statement_list RBRACE {
            exec_enabled = $<int_val>5;
      }
    ;

loop_stmt:
      LOOP LPAREN expression RPAREN LBRACE statement_list RBRACE { }
    ;

repeat_stmt:
      REPEAT LPAREN expression RPAREN LBRACE statement_list RBRACE { }
    ;

expression:
      INT_VAL                  { $$ = (double)$1; }
    | FLOAT_VAL                { $$ = $1; }
    | BOOL_VAL                 { $$ = (double)$1; }
    | IDENTIFIER {
            Symbol *sym = get_symbol($1);
            if (sym && !sym->is_string) {
                $$ = sym->value;
            } else {
                if (!sym) printf("Runtime Error: Variable '%s' uninitialized.\n", $1);
                else printf("Runtime Error: Cannot use string in arithmetic expression.\n");
                $$ = 0;
            }
            free($1);
      }
    | expression PLUS expression      { $$ = $1 + $3; }
    | expression MINUS expression     { $$ = $1 - $3; }
    | expression MULT expression      { $$ = $1 * $3; }
    | expression DIV expression       { 
                                         if ($3 == 0) {
                                             printf("Runtime Error: Division by zero!\n");
                                             $$ = 0;
                                         } else {
                                             $$ = $1 / $3; 
                                         }
                                       }
    | expression MOD expression       { 
                                         if ((int)$3 == 0) {
                                             printf("Runtime Error: Modulo by zero!\n");
                                             $$ = 0;
                                         } else {
                                             $$ = (int)$1 % (int)$3; 
                                         }
                                       }
    | expression EQ expression        { $$ = ($1 == $3); }
    | expression NE expression        { $$ = ($1 != $3); }
    | expression LT expression        { $$ = ($1 < $3); }
    | expression GT expression        { $$ = ($1 > $3); }
    | expression LE expression        { $$ = ($1 <= $3); }
    | expression GE expression        { $$ = ($1 >= $3); }
    | LPAREN expression RPAREN        { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error: %s\n", s);
}

int main(int argc, char **argv) {
    extern FILE *yyin;
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            printf("Error: Could not open file %s\n", argv[1]);
            return 1;
        }
        yyin = file;
    }
    yyparse();
    return 0;
}