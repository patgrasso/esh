#include <stdio.h>
#include <err.h>

#include "esh.h"
#include "parser.tab.h"

extern FILE  *yyin;
extern int    yydebug;

/*
 * esh is a template program inspired by erb (from ruby), except that
 * subshell or variable expressions recognized by (ba)sh are evaluated and
 * emplaced in the file.
 *
 * The program utilizes yacc & lex in order to parse an input file. If no
 * argument is provided, stdin is used.
 *
 * If compiled with -DDEBUG, yydebug is enabled so that the state machine
 * prints its state while parsing.
 */
int
main(int argc, char *const argv[])
{
  if (argc > 1 && (yyin = fopen(argv[1], "r")) == NULL) {
    err(1, argv[1]);
  }

#ifdef DEBUG
  yydebug = 1;
#endif

  return yyparse();
}
