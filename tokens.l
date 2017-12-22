%{
#include <string.h>

#include "parser.tab.h"
%}

%%
                        /* whitespace */
\n                      yylval.str = strdup(yytext); yylineno++; return SP;
[ \t]+                  yylval.str = strdup(yytext); return SP;

                        /* indicators */
\$                      return DOLLAR;
\{                      return LBRACE;
\}                      return RBRACE;
\(                      return LPAREN;
\)                      return RPAREN;
`                       return TIC;

                        /* escaped indicators */
\\[\$\{\}\(\)`]         yylval.str = strdup(&yytext[1]); return STR;

                        /* strings */
[a-zA-Z][a-zA-Z0-9]*    yylval.str = strdup(yytext); return IDENT;
[^\n\$\{\}\(\) ]+       yylval.str = strdup(yytext); return STR;
                        /* NOTE: IDENT can be confused with STR, so any rule
                         *       that accepts STR should also accept IDENT SP
                         */
%%
