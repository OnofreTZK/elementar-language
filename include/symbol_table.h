#ifndef symbol_table_h
#define symbol_table_h

#include <stdio.h>
#include <stdlib.h>
#include "types.h"

SymbolTable * createSymbolTable();

void setKeyValue(SymbolTable**, char*, char*, const char*);

void* getValue(SymbolTable*, char*, char*);

unsigned int length(SymbolTable*);

void printTable(SymbolTable*);

void destroyTable(SymbolTable**);

#endif
