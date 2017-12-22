#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>

#include "esh.h"

/*
 * _concat_ takes a variable number of arguments and concatenates them all into
 * a single malloc'd string. This should not be called directly.
 *
 * _    must be NULL, otherwise the loop that iterates over the arguments will
 *      not end
 * ...  each a non-null, null-terminated char *
 */
char *
_concat_(char *_, ...)
{
  va_list   args;
  char     *curr;
  char     *result;
  size_t    len;

  va_start(args, _);
  for (len = 0; (curr = va_arg(args, char *)) != NULL; ) {
    len += strlen(curr);
  }
  va_end(args);

  result = (char *)malloc(len + 1);
  bzero(result, len + 1);

  va_start(args, _);
  while ((curr = va_arg(args, char *)) != NULL) {
    strcat(result, curr);
  }
  va_end(args);

  return result;
}

/*
 * cdupcat takes a string that was created with malloc() and another (not
 * necessarily in the heap) and concatenates them. This is done be realloc-ing
 * the first string to fit the second, then using strcat() to append the second
 * string.
 *
 * a    null-terminated string obtained from malloc, strdup, etc.
 * b    any char *
 *
 * return a + b
 */
char *
cdupcat(char *a, const char *b)
{
  char   *result;
  size_t  len_a = 0;
  size_t  len_b = 0;

  if (a != NULL) len_a = strlen(a);
  if (b != NULL) len_b = strlen(b);

  result = (char *)realloc(a, len_a + len_b + 1);
  if (a == NULL) bzero(result, len_a + len_b + 1);

  strcat(result, b);
  return result;
}

/*
 * dupcat calls cdupcat, then frees the second argument. This is useful for
 * joining two strings together while parsing, as it also frees up memory.
 *
 * see cstrdup
 */
char *
dupcat(char *a, char *b)
{
  char *result;

  result = cdupcat(a, b);
  free(b);
  return result;
}

/*
 * int2str is the opposite of atoi. It takes an integer and returns the string
 * representation (in base 10) in a freshly malloc'd string.
 */
char *
int2str(int n)
{
  int   digits;
  int   m;
  char *buff;

  for (m = n, digits = 0; m > 0; m /= 10, digits++)
    ;

  if (!(buff = (char *)malloc(digits + 1))) {
    return NULL;
  }

  if (sprintf(buff, "%.*d", digits, n) < 0) {
    perror("sprintf");
    free(buff);
    return NULL;
  }

  return buff;
}
