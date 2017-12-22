#ifndef _ESH_H_
#define _ESH_H_

/*
 * Calls _concat_ with the appropriate first and last arguments (NULL) so that
 * the end of the argument list can be determined. Yes, if one of the variadic
 * arguments is NULL the remaining arguments won't be processed, but alas this
 * is C, so we can only do so much.
 */
#define concat(...) _concat_(NULL, __VA_ARGS__, NULL)

/*
 * If (expr) evaluates to 0, execute (then).
 */
#define assert(expr, then)  \
  do {                      \
    if (!(expr)) { then; }  \
  } while (0 /* CONSTCOND */)

char *_concat_(char *, ...);
char *cdupcat(char *, const char *);
char *dupcat(char *, char *);
char *int2str(int);

#endif
