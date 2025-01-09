#ifndef scope_stack_h
#define scope_stack_h

#include <stdio.h>
#include <stdlib.h>

typedef struct {
	char * current;
  Scope * next;
} Scope;

#endif
