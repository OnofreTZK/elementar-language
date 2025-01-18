#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include "types.h"
#include "util.h"

#define INITIAL_CAPACITY 16

FunctionTable * createFunctionTable(){
    FunctionTable* table = malloc(sizeof(FunctionTable));
    if(!table){
        return NULL;
    }

    table->capacity = INITIAL_CAPACITY;
    table->length = 0;
    table->functions = calloc(INITIAL_CAPACITY, sizeof(Function));

    return table;
}

static const char* setEntry(Function** entries, unsigned int capacity,
        const char* key, char** params ,const char* value, unsigned int* plength) {
    uint64_t keyhash = generateHash(key);
    unsigned int index = (unsigned int)(keyhash & (uint64_t)(capacity - 1));

    while ((*entries)[index].key != NULL) {
        if (strcmp(key, (*entries)[index].key) == 0) {
            (*entries)[index].parameters = params;
            (*entries)[index].type = strdup(value);
            return (*entries)[index].key;
        }

        index++;
        if (index >= capacity) {
            index = 0;
        }
    }

    if (plength != NULL) {
        key = strdup(key);
        if (key == NULL) {
            return NULL;
        }
        (*plength)++;
    }
    (*entries)[index].key = key;
    (*entries)[index].parameters = params;
    (*entries)[index].type = strdup(value);
    return key;
}

static bool doubleCapacity(FunctionTable** table) {
    unsigned int newCapacity = (*table)->capacity * 2;
    if (newCapacity < (*table)->capacity) {
        return false; 
    }

    Function* updatedFunctions = calloc(newCapacity, sizeof(Symbol));
    if (updatedFunctions == NULL) {
        return false;
    }

    for (unsigned int i = 0; i < (*table)->capacity; i++) {
        Function entry = (*table)->functions[i];
        if (entry.key != NULL) {
            setEntry(&updatedFunctions, newCapacity, entry.key, entry.parameters, entry.type, NULL);
        }
    }

    free((*table)->functions);
    (*table)->functions = updatedFunctions;
    (*table)->capacity = newCapacity;
    return true;
}

void setKeyFunction(FunctionTable** table, char* scope, char* id, char** params, const char* type) {
    char* prehash = concat(scope, id, "", "", "");

    if ((*table)->length >= (*table)->capacity / 2) {
        doubleCapacity(table);
    }

    setEntry(&(*table)->functions, (*table)->capacity, prehash, params,type, &(*table)->length);
}

Function* getFunction(FunctionTable* table, char* scope, char* id) {
    char* prehash = concat(scope, id, "", "", "");
    uint64_t keyhash = generateHash(prehash);
    unsigned int index = (unsigned int)(keyhash & (uint64_t)(table->capacity - 1));

    while (table->functions[index].key != NULL) {
        if (strcmp(prehash, table->functions[index].key) == 0) {
            return &table->functions[index];
        }

        index++;
        if (index >= table->capacity) {
            index = 0;
        }
    }

    return NULL;
}

void printFunctionTable(FunctionTable* table){
   Function* functions = table->functions;;

   unsigned int size = table->capacity;

   for(unsigned int i = 0; i < size; i++){
       Function f = functions[i];
       printf("KEY: %s | TYPE %s | Parameters: ",f.key, f.type);
    
       char** ptr = functions[i].parameters;

       while(ptr != NULL) {
           printf("%s", *ptr);
           ptr++;
       }
    
       printf("\n");
    }
}

void destroyFunctionTable(FunctionTable** table){
    free((*table)->functions);
    free(*table);
}
