#include <stdio.h>
#include "types.h"
#include "scope_stack.h"

int main() {
    Scope* scope = newScopeStack();

    push("2", &scope);
    push("3", &scope);

    char* topValue = top(scope);
    printf("Top value: %s\n", topValue);

    while(scope != NULL) {
        char* currentScope = pop(&scope);

        printf(">>> %s\n", currentScope);
    }

    Scope* scope2 = newScopeStack();

    push("1", &scope2);
    push("2", &scope2);
    push("3", &scope2);
    push("4", &scope2);

    int l = 3;

    while(l >= 0) {
        char* current = peek(scope2, l);

        printf("Current level: %d | Current label: %s\n", l, current);

        l--;
    }
    
    return 0;
}

