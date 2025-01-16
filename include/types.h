#ifndef types_h
#define types_h

typedef struct _Scope {
	char * label;
  unsigned int position;
  struct _Scope * next;
} Scope ;

typedef struct _Symbol {
  const char* key;
  void* value;
} Symbol ;

typedef struct _SymbolTable {
  Symbol* symbols;
  unsigned int capacity;
  unsigned int length;
} SymbolTable ;

#endif
