#ifndef scope_stack_h
#define scope_stack_h

#include <stdio.h>
#include <stdlib.h>
#include "types.h"

Scope* newScopeStack();

void push(char*, Scope**);

char* pop(Scope**);

char* top(Scope*);

char* peek(Scope*, int);

void destroyStack(Scope**);

#endif
