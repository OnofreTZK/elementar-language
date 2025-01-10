#include <stdio.h>
#include <string.h>
#include <types.h>
#include <scope_stack.h>

Scope* create_scope_stack() {
  Scope* scope = malloc(sizeof(Scope)); 

  scope->next = NULL;

  return scope;
}

void push(char* scope, Scope** stack) {	
	Scope* node = malloc(sizeof(Scope));
	node->current = malloc(sizeof(strlen(scope)));

	strcpy(node->current, scope);
	
	node->next = *stack;		
	
	*stack = node;
}

char * pop(Scope** stack) {
	char* value;

	if (!(*stack)->next) {
		return NULL;
	} else {
		Scope* temp = *stack;

		char* value = temp->current;

		free(temp);

		*stack = (*stack)->next;

		return value;
	}
} 
