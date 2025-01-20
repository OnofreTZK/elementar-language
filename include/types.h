#ifndef types_h
#define types_h

typedef struct _Scope {
	char * label;
  unsigned int position;
  struct _Scope * next;
} Scope ;

typedef struct _Symbol {
  const char* key;
  char* value;
} Symbol ;

typedef struct _SymbolTable {
  Symbol* symbols;
  unsigned int capacity;
  unsigned int length;
} SymbolTable ;

typedef struct _Function {
  const char* key;
  char** parameters;
  char* type;
} Function ;

typedef struct _FunctionTable {
  Function* functions;
  unsigned int capacity;
  unsigned int length;
} FunctionTable ;

typedef struct _UserDefinedStruct {
  const char* key;
  char* name;
  char** attributes;
  char** attributesTypes;
} UserDefinedStruct ;

typedef struct _UserDefinedTypesTable {
  UserDefinedStruct* structs;
  unsigned int capacity;
  unsigned int length;
} UserDefinedTypesTable ;

#endif
