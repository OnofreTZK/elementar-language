#ifndef function_table_h
#define function_table_h

#include <stdio.h>
#include <stdlib.h>
#include "types.h"

FunctionTable * createFunctionTable();

void setKeyFunction(FunctionTable**, char*, char*, char**, const char*);

Function* getFunction(FunctionTable*, char*, char*);

void printFunctionTable(FunctionTable*);

void destroyFunctionTable(FunctionTable**);

#endif
