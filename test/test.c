#include <stdio.h>
#include "types.h"
#include "scope_stack.h"

int main() {
    Scope* scope = create_scope_stack();

    push("2", &scope);
    push("3", &scope);

    while(scope->next != NULL) {
        printf("Iteration\n");
        char* current_scope = pop(&scope);

        printf(">>> %s\n", current_scope);
    }
    
    return 0;
}

