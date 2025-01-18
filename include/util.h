#ifndef util_h 
#define util_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

char *concat(char *s1, char *s2, char *s3, char *s4, char *s5);

char *generateLabel(const char *prefix);

char *getPrintType(char *variableType);

int is_compatible(const char *type1, const char *type2);

uint64_t generateHash(const char*);

char** stringToParameterList(char*);

#endif
