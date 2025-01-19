#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "types.h"
#include "scope_stack.h"
#include "symbol_table.h"
#include "function_table.h"
#include "util.h"

// Scope Stack tests
// ************************************************************************************************
void createScopeStackCreateAnEmptyStack(){
    Scope* scope = createScopeStack();

    assert(!scope);

    destroyStack(&scope);
}

void pushInAnEmptyStackShouldWork(){
    Scope* scope = createScopeStack();

    push("1", &scope);
    
    assert(strcmp(top(scope), "1") == 0);

    free(scope);
}

void pushInANotEmptyStackShouldWork(){
    Scope* scope = createScopeStack();

    push("1", &scope);
    push("2", &scope);
    
    assert(strcmp(top(scope), "2") == 0);

    free(scope);
}

void popAnEmptyStackShouldReturnAnEmptyString(){
    Scope* scope = createScopeStack();

    assert(strcmp((pop(&scope)), "") == 0);

    free(scope);
}

void popAStackShouldReturnTheElementAtTop(){
    Scope* scope = createScopeStack();

    push("1", &scope);
    push("2", &scope);
    char* element = top(scope);

    assert(strcmp((pop(&scope)), element) == 0);

    free(scope);
}

void topWhenStackIsEmptyShouldReturnedAnEmptyString(){
    Scope* scope = createScopeStack();

    assert(strcmp((top(scope)), "") == 0);

    free(scope);
}

void peekWhenEmptyStackShouldRertunAnEmptyString(){
    Scope* scope = createScopeStack();

    assert(strcmp((peek(scope, 1)), "") == 0);

    free(scope);
}

void peekShouldWorkInAnyValidPosition(){
    Scope* scope = createScopeStack();

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
    createScopeStackCreateAnEmptyStack(); 
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
    
    assert(table->length == 0);

    destroySymbolTable(&table);
}

void setASingleKeyValueShouldWork(){
    SymbolTable* table = createSymbolTable();
    char* scope = "global";
    char* id = "id";
    char* type = "int";

    setKeyValue(&table, scope, id, type);

    assert(table->length == 1);

    destroySymbolTable(&table);
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

    //printSymbolTable(table);

    assert(table->length == 20);

    destroySymbolTable(&table);
}

void getASingleKeyValueShouldWork(){
    SymbolTable* table = createSymbolTable();
    char* scope = "global";
    char* id = "id";
    char* type = "int";

    setKeyValue(&table, scope, id, type);

    assert(table->length == 1);

    char* value = getValue(table, scope, id);

    assert(strcmp(value, type) == 0);

    destroySymbolTable(&table);
}

void symbolTableSuite(){
    createSymbolTableHasNullTable();
    setASingleKeyValueShouldWork();
    setAfterMaxCapacityShouldWork();
    getASingleKeyValueShouldWork();
}
// ************************************************************************************************

// Function Table tests
// ************************************************************************************************

void createFunctionTableHasNullParameters(){
    FunctionTable* table = createFunctionTable();
    
    for(int i = 0; i < 16; i++){
        assert(table->functions[i].parameters == NULL);
    }
    
    assert(table->length == 0);

    destroyFunctionTable(&table);
}

void setASingleKeyFunctionShouldWork(){
    FunctionTable* table = createFunctionTable();
    char* scope = "global";
    char* id = "myfunction";
    char* parameters[3] = {"int", "int", "string"}; 
    char* type = "int";

    setKeyFunction(&table, scope, id, parameters, type);

    assert(table->length == 1);

    destroyFunctionTable(&table);
}

void setFuncAfterMaxCapacityShouldWork(){
    FunctionTable* table = createFunctionTable();
    char* scope = "global";
    char* parameters[3] = {"int", "int", "string"}; 
    char* type = "int";

    for(unsigned int i = 0; i < 20; i++){
        char input[20];
        sprintf(input, "myfunction%d", i);
        setKeyFunction(&table, scope, input, parameters, type);
    }

    //printTable(table);

    assert(table->length == 20);

    destroyFunctionTable(&table);
}

void getASingleKeyFunctionShouldWork(){
    FunctionTable* table = createFunctionTable();
    char* scope = "global";
    char* id = "myfunction";
    char* parameters[3] = {"int", "int", "string"}; 
    char* type = "int";

    setKeyFunction(&table, scope, id, parameters, type);

    assert(table->length == 1);

    Function* func = getFunction(table, scope, id);

    assert(strcmp(func->type, type) == 0);

    for(unsigned int i = 0; i < 3; i++){
        assert(strcmp(func->parameters[i], parameters[i]) == 0);
    }

    destroyFunctionTable(&table);
}

void getASingleKeyFunctionWithSplittedArgumentListShouldWork(){
    FunctionTable* table = createFunctionTable();
    char* scope = "global";
    char* id = "myfunction";
    char* rawParameters = "int arg1, int agr2, string arg3";
    char** parameters = stringToParameterList(rawParameters); 
    char* type = "int";

    setKeyFunction(&table, scope, id, parameters, type);

    assert(table->length == 1);

    Function* func = getFunction(table, scope, id);

    assert(strcmp(func->type, type) == 0);

    for(unsigned int i = 0; i < 3; i++){
        assert(strcmp(func->parameters[i], parameters[i]) == 0);
    }

    destroyFunctionTable(&table);
}

void functionTableSuite(){
    createFunctionTableHasNullParameters();
    setASingleKeyFunctionShouldWork();
    setFuncAfterMaxCapacityShouldWork();
    getASingleKeyFunctionShouldWork();
    getASingleKeyFunctionWithSplittedArgumentListShouldWork();
}
// ************************************************************************************************

int main() {
    scopeStackSuite();
    symbolTableSuite();
    functionTableSuite();
    
    return 0;
}
