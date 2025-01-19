#ifndef UTIL_H
#define UTIL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Funções utilitárias
char *concat(char *s1, char *s2, char *s3, char *s4, char *s5);
char *generateLabel(const char *prefix);
char *getPrintType(char *variableType);
int is_compatible(const char *type1, const char *type2);
char* replace(char *str, char *old_str, char *new_str);

#endif
