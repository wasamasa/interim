#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#ifdef READLINE
#include <readline/readline.h>
#include <readline/history.h>
#endif

#ifdef READLINE
static const char *history_file = ".sledge_history";

void load_history() {
  int ret = read_history(history_file);
  if (ret != 0 && ret != ENOENT) {
    printf("error loading history from %s\n", history_file);
  }
}

void save_history() {
  if (write_history(history_file) != 0) {
    printf("error writing history to %s\n", history_file);
  }
}

char *read_line(char *buf, size_t size, FILE *in, const char *prompt) {
  if (in == stdin) {
    char *result = readline(prompt);
    if (result == NULL) {
      return NULL;
    } else {
      snprintf(buf, size, "%s\n", result);
      add_history(result);
      save_history();
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
