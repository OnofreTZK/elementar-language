#include <stdio.h>
#include <types.h>
#include <scope_stack.h>

void push(char* scope, Scope* stack) {	
	Scope node;
  node.current = scope;

	if(!stack) {
		node.next = NULL;
		stack = &node;
	} else {
		node.next = stack;		
	}
}
