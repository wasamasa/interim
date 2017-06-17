#ifndef READLINE_H
#define READLINE_H

#include <stdio.h>

#ifdef READLINE
void load_history();
void save_history();
#endif

char *read_line(char *buf, size_t size, FILE *in, const char *prompt);

#endif
