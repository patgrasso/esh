%{
#include <stdio.h>
#include <err.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include "esh.h"

int   yylex(void);
int   yywrap(void) { return 1; }

extern char  *yytext;
extern int    yylineno;

/*
 * Prints a parsing error at the token where it occurred along with the line
 * number.
 *
 * yytext, yylineno   global variables assumed to be correct (set by yacc)
 * str                error message
 */
void
yyerror(const char *str)
{
  warnx("%s: '%s' (line %d)", str, yytext, yylineno);
}

/*
 * eval_sh evaluates an expression using popen. See man popen(3) for more.
 * The output from the execution is stored in a malloc'd string and 
 */
char *
eval_sh(char *expr)
{
  FILE *shproc;
  char  buffer[1025];
  char *result;
  int   n;

  if ((shproc = popen(expr, "r")) == NULL) {
    perror(expr);
    return NULL;
  }

  for (result = NULL, n = 1; n > 0; result = cdupcat(result, buffer)) {
    n = fread(buffer, 1, 1024, shproc);
    buffer[n] = '\0';
  }

  n = strlen(result);
  if (result[n-1] == '\n') result[n-1] = '\0';

  return result;
}

char *
eval_subst(char *ident)
{
  return eval_sh(concat("echo -n ${", ident, "}"));
}

char *
eval_expr(char *expr)
{
  return eval_sh(concat("echo -n \"$(", expr, ")\""));
}
%}

%union
{
  char *str;
}

%token <str> STR SP IDENT
%token DOLLAR LBRACE RBRACE LPAREN RPAREN TIC

%type <str> subst sh_subst expr sh_expr var

%%
accept  : doc ;

doc     : doc STR     { printf("%s", $2); free($2); }
        | doc IDENT   { printf("%s", $2); free($2); }
        | doc SP      { printf("%s", $2); free($2); }
        | doc LBRACE  { printf("%s", "{"); }
        | doc RBRACE  { printf("%s", "}"); }
        | doc LPAREN  { printf("%s", "("); }
        | doc RPAREN  { printf("%s", ")"); }
        | doc expr    { printf("%s", $2); free($2); }
        | doc subst   { printf("%s", $2); free($2); }
        | doc var     { printf("%s", $2); free($2); }
        | %empty
        ;

subst   : DOLLAR LBRACE sh_subst RBRACE { $$ = $3; } ;

sh_subst: IDENT { assert($$ = eval_subst($1), YYABORT); } ;

expr    : DOLLAR LPAREN sh_expr RPAREN
          { assert($$ = eval_expr($3), YYABORT); }
        ;

sh_expr : sh_expr STR     { $$ = dupcat($1, $2); }
        | sh_expr SP      { $$ = dupcat($1, $2); }
        | sh_expr IDENT   { $$ = dupcat($1, $2); }
        | sh_expr LBRACE  { $$ = cdupcat($1, "{"); }
        | sh_expr RBRACE  { $$ = cdupcat($1, "}"); }
        | sh_expr DOLLAR  { $$ = cdupcat($1, "$"); }
        | %empty          { $$ = strdup(""); }
        | sh_expr LPAREN sh_expr RPAREN
          { $$ = dupcat($1, concat("(", $3, ")")); }
        ;

var     : DOLLAR IDENT { $$ = strdup(getenv($2)); } ;
%%
