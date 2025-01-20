#ifndef user_defined_types_table_h
#define user_defined_types_table_h

#include <stdio.h>
#include <stdlib.h>
#include "types.h"

UserDefinedTypesTable * createUserDefinedTypesTable();

void setKeyUserType(UserDefinedTypesTable**, char*, char*, const char*, char**, char**);

UserDefinedStruct* getStruct(UserDefinedTypesTable*, char*, char*);

//void printUserDefinedTypesTable(UserDefinedTypesTable*);

void destroyUserDefinedTypesTable(UserDefinedTypesTable**);

#endif
