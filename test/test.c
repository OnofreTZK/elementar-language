#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "types.h"
#include "scope_stack.h"
#include "symbol_table.h"

// Scope Stack tests
// ************************************************************************************************
void newScopeStackCreateAnEmptyStack(){
    Scope* scope = newScopeStack();

    assert(!scope);

    destroyStack(&scope);
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

void peekWhenEmptyStackShouldRertunAnEmptyString(){
    Scope* scope = newScopeStack();

    assert(strcmp((peek(scope, 1)), "") == 0);

    free(scope);
}

void peekShouldWorkInAnyValidPosition(){
    Scope* scope = newScopeStack();

    push("1", &scope);
    push("2", &scope);
    push("3", &scope);
    push("4", &scope);

    char* firstLabel = peek(scope, 0);
    char* topLabel = peek(scope, 3);
    assert(strcmp(firstLabel, "1") == 0);
    assert(strcmp(topLabel, "4") == 0);

    free(scope);
}

void scopeStackSuite(){
    newScopeStackCreateAnEmptyStack(); 
    pushInAnEmptyStackShouldWork();
    pushInANotEmptyStackShouldWork();
    popAnEmptyStackShouldReturnAnEmptyString();
    popAStackShouldReturnTheElementAtTop();
    topWhenStackIsEmptyShouldReturnedAnEmptyString();
    peekWhenEmptyStackShouldRertunAnEmptyString();
    peekShouldWorkInAnyValidPosition();
}
// ************************************************************************************************

// Symbol Table tests
// ************************************************************************************************
void createSymbolTableHasNullTable(){
    SymbolTable* table = createSymbolTable();
    
    for(int i = 0; i < 5; i++){
        assert(table->symbols[i].value == NULL);
    }
    
    assert(length(table) == 0);

    destroyTable(&table);
}

void setASingleKeyValueShouldWork(){
    SymbolTable* table = createSymbolTable();
    char* scope = "global";
    char* id = "id";
    char* type = "int";

    setKeyValue(&table, scope, id, type);

    assert(length(table) == 1);

    destroyTable(&table);
}

void setAfterMaxCapacityShouldWork(){
    SymbolTable* table = createSymbolTable();
    char* scope = "global";
    char* type = "int";

    for(unsigned int i = 0; i < 20; i++){
        char input[10];
        sprintf(input, "id%d", i);
        setKeyValue(&table, scope, input, type);
    }

    assert(length(table) == 20);

    destroyTable(&table);
}

void getASingleKeyValueShouldWork(){
    SymbolTable* table = createSymbolTable();
    char* scope = "global";
    char* id = "id";
    char* type = "int";

    setKeyValue(&table, scope, id, type);

    assert(length(table) == 1);

    char* value = getValue(&table, scope, id);

    assert(strcmp(value, type) == 0);

    destroyTable(&table);
}

void symbolTableSuite(){
    createSymbolTableHasNullTable();
    setASingleKeyValueShouldWork();
    setAfterMaxCapacityShouldWork();
    getASingleKeyValueShouldWork();
}
// ************************************************************************************************

int main() {
    scopeStackSuite();
    symbolTableSuite();
    
    return 0;
}

