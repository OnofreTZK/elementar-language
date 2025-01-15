#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "types.h"
#include "scope_stack.h"

// Scope Stack tests
// ************************************************************************************************
void newScopeStackCreateAnEmptyStack(){
    Scope* scope = newScopeStack();

    assert(!scope);

    free(scope);
}

void pushInAnEmptyStackShouldWork(){
    Scope* scope = newScopeStack();

    push("1", &scope);
    
    assert(strcmp(top(scope), "1") == 0);

    free(scope);
}

void pushInANotEmptyStackShouldWork(){
    Scope* scope = newScopeStack();

    push("1", &scope);
    push("2", &scope);
    
    assert(strcmp(top(scope), "2") == 0);

    free(scope);
}

void popAnEmptyStackShouldReturnAnEmptyString(){
    Scope* scope = newScopeStack();

    assert(strcmp((pop(&scope)), "") == 0);

    free(scope);
}

void popAStackShouldReturnTheElementAtTop(){
    Scope* scope = newScopeStack();

    push("1", &scope);
    push("2", &scope);
    char* element = top(scope);

    assert(strcmp((pop(&scope)), element) == 0);

    free(scope);
}

void topWhenStackIsEmptyShouldReturnedAnEmptyString(){
    Scope* scope = newScopeStack();

    assert(strcmp((top(scope)), "") == 0);

    free(scope);
}

void scopeStackSuite(){
    newScopeStackCreateAnEmptyStack(); 
    pushInAnEmptyStackShouldWork();
    pushInANotEmptyStackShouldWork();
    popAnEmptyStackShouldReturnAnEmptyString();
    popAStackShouldReturnTheElementAtTop();
    topWhenStackIsEmptyShouldReturnedAnEmptyString();
}
// ************************************************************************************************

int main() {
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

    scopeStackSuite();
    
    return 0;
}

