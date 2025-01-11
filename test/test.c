#include <stdio.h>
#include "types.h"
#include "scope_stack.h"

int main() {
    Scope* scope = createScopeStack();

    push("2", &scope);
    push("3", &scope);

    char* peekedValue = peek(scope);
    printf("Peek value: %s\n", peekedValue);

    while(scope != NULL) {
        char* currentScope = pop(&scope);

        printf(">>> %s\n", currentScope);
    }
    
    return 0;
}

