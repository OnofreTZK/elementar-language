#ifndef UTIL_H
#define UTIL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *concat(char * s1, char * s2, char * s3, char * s4, char * s5);
char *generateLabel(const char *prefix);
char *getPrintType(char * variableType);
char *replace(char *str, char *old_str, char *new_str);
char *getTypeValue(char * type);
char *getSecondElement(const char* str);
int isIdentifier(const char *str);
char *getTypeCast(char * type);
int isListType(char* type);

#endif
