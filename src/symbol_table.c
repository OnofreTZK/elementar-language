#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include "util.h"
#include "types.h"

#define INITIAL_CAPACITY 16

SymbolTable * createSymbolTable(){
    SymbolTable* table = malloc(sizeof(SymbolTable));
    if(!table){
        return NULL;
    }

    table->capacity = INITIAL_CAPACITY;
    table->length = 0;
    table->symbols = calloc(INITIAL_CAPACITY, sizeof(Symbol));

    return table;
}

static const char* setEntry(Symbol** entries, unsigned int capacity,
        const char* key, const char* value, unsigned int* plength) {
    uint64_t keyhash = generateHash(key);
    unsigned int index = (unsigned int)(keyhash & (uint64_t)(capacity - 1));

    while ((*entries)[index].key != NULL) {
        if (strcmp(key, (*entries)[index].key) == 0) {
            (*entries)[index].value = strdup(value);
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
    (*entries)[index].value = strdup(value);
    return key;
}

static bool doubleCapacity(SymbolTable** table) {
    unsigned int newCapacity = (*table)->capacity * 2;
    if (newCapacity < (*table)->capacity) {
        return false; 
    }

    Symbol* newSymbols = calloc(newCapacity, sizeof(Symbol));
    if (newSymbols == NULL) {
        return false;
    }

    for (unsigned int i = 0; i < (*table)->capacity; i++) {
        Symbol entry = (*table)->symbols[i];
        if (entry.key != NULL) {
            setEntry(&newSymbols, newCapacity, entry.key, entry.value, NULL);
        }
    }

    free((*table)->symbols);
    (*table)->symbols = newSymbols;
    (*table)->capacity = newCapacity;
    return true;
}

void setKeyValue(SymbolTable** table, char* scope, char* id, const char* type) {
    char* prehash = concat(scope, id, "", "", "");

    if ((*table)->length >= (*table)->capacity / 2) {
        doubleCapacity(table);
    }

    setEntry(&(*table)->symbols, (*table)->capacity, prehash, type, &(*table)->length);
}

void* getValue(SymbolTable* table, char* scope, char* id) {
    char* prehash = concat(scope, id, "", "", "");
    uint64_t keyhash = generateHash(prehash);
    unsigned int index = (unsigned int)(keyhash & (uint64_t)(table->capacity - 1));


    while (table->symbols[index].key != NULL) {
        if (strcmp(prehash, table->symbols[index].key) == 0) {
            return table->symbols[index].value;
        }

        index++;
        if (index >= table->capacity) {
            index = 0;
        }
    }

    return NULL;
}

void printSymbolTable(SymbolTable* table){
   Symbol* ptr = table->symbols;;

   unsigned int size = table->capacity;

   for(unsigned int i = 0; i < size; i++){
       Symbol s = ptr[i];
       printf("KEY: %s | VALUE %s\n",s.key, s.value);
    }
}

void destroySymbolTable(SymbolTable** table){
    for(unsigned int i = 0; i < (*table)->capacity; i++){
        free((void*)(*table)->symbols[i].key);
    }

    free((*table)->symbols);
    free(*table);
}


