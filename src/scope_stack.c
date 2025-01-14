#include <stdio.h>
#include <string.h>
#include <types.h>
#include <scope_stack.h>

Scope* createNode(char* label, unsigned int pos){
	Scope * scope = malloc(sizeof(Scope));

	scope->label = label;
	scope->position = pos;
	scope->next = NULL;

	return scope;
}

Scope* newScopeStack() {
	Scope* scope = NULL;

	return scope;
}

void push(char* scope, Scope** stack) {	
	Scope* node; 
	
	if(!*stack){
		node = createNode(scope, 0);
	} else {
		node = createNode(scope, ((*stack)->position)+1);
	}

	node->next = *stack;
	*stack = node;	
}

char * pop(Scope** stack) {
	if (!*stack) {
		return "Out of scopes";
	} else {
		Scope* temp = *stack;

		char* value = temp->label;

		*stack = temp->next;
		
		free(temp);

		return value;
	}
} 

char* top(Scope* stack){
	return stack->label;
}

char* peek(Scope* stack, int position) {
	char* label = NULL;

	while(stack != NULL){
		if(stack->position == position){
			label = stack->label; 
			break;
		}
		stack = stack->next;
	}

	if(!label){
		return "Invalid position";
	} else {
		return label;
	}
}
