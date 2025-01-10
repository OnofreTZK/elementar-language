#include <stdio.h>
#include <string.h>
#include <types.h>
#include <scope_stack.h>

Scope* createNode(char* value){
	Scope * scope = malloc(sizeof(Scope));

	scope->current = value;
	scope->next = NULL;

	return scope;
}

Scope* createScopeStack() {
	Scope* scope = NULL;

	return scope;
}

void push(char* scope, Scope** stack) {	
	Scope* node = createNode(scope);
	
	node->next = *stack;
	*stack = node;	
}

char * pop(Scope** stack) {
	if (*stack == NULL) {
		return "Out of scopes";
	} else {
		Scope* temp = *stack;

		char* value = temp->current;

		*stack = temp->next;
		
		free(temp);

		return value;
	}
} 
