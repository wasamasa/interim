#include <stdio.h>
#include <stdlib.h>

#ifdef READLINE
#include <readline/readline.h>
#include <readline/history.h>
#endif

#ifdef READLINE
char *read_line(char *buf, size_t size, FILE *in, const char *prompt) {
  if (in == stdin) {
    char *result = readline(prompt);
    if (result == NULL) {
      return NULL;
    } else {
      snprintf(buf, size, "%s\n", result);
      add_history(result);
      free(result);
      return buf;
    }
  } else {
    return fgets(buf, size, in);
  }
}
#else
char *read_line(char *buf, size_t size, FILE *in, const char *prompt) {
  if (in == stdin) {
    printf("%s", prompt);
  }
  return fgets(buf, size, in);
}
#endif
