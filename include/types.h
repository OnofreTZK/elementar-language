#ifndef types_h
#define types_h

typedef struct _Scope {
	char * label;
  unsigned int position;
  struct _Scope * next;
} Scope ;

#endif
