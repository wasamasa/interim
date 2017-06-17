#ifndef READLINE_H
#define READLINE_H

#include <stdio.h>

char *read_line(char *buf, size_t size, FILE *in, const char *prompt);

#endif
