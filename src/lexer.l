%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

void yyerror(const char *s);
%}

%option noyywrap

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
INT_NUM     {DIGIT}+
FLOAT_NUM   {DIGIT}+\.{DIGIT}+
STRING_LIT  \"([^"\\]|\\.)*\"

%%

[ \t\r\n]+          { /* Ignore whitespace */ }
"//".*              { /* Single-line comment */ }

"let"               { return LET; }
"echo"              { return ECHO_KW; }
"ask"               { return ASK; }
"check"             { return CHECK; }
"otherwise"         { return OTHERWISE; }
"loop"              { return LOOP; }
"repeat"            { return REPEAT; }
"true"              { yylval.int_val = 1; return BOOL_VAL; }
"false"             { yylval.int_val = 0; return BOOL_VAL; }

{FLOAT_NUM}         { yylval.float_val = atof(yytext); return FLOAT_VAL; }
{INT_NUM}           { yylval.int_val = atoi(yytext); return INT_VAL; }
{STRING_LIT}        { 
                      yylval.str_val = strndup(yytext + 1, strlen(yytext) - 2); 
                      return STRING_VAL; 
                    }
{ID}                { yylval.str_val = strdup(yytext); return IDENTIFIER; }

"=="                { return EQ; }
"!="                { return NE; }
"<="                { return LE; }
">="                { return GE; }
"<"                 { return LT; }
">"                 { return GT; }
"="                 { return ASSIGN; }

"+"                 { return PLUS; }
"-"                 { return MINUS; }
"*"                 { return MULT; }
"/"                 { return DIV; }
"%"                 { return MOD; }

"("                 { return LPAREN; }
")"                 { return RPAREN; }
"{"                 { return LBRACE; }
"}"                 { return RBRACE; }
";"                 { return SEMICOLON; }
","                 { return COMMA; }

.                   { printf("Lexical Error: Unexpected character '%s'\n", yytext); }

%%
