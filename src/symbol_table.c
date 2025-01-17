#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include "types.h"
#include "util.h"

#define INITIAL_CAPACITY 16
#define FNV_OFFSET 14695981039346656037UL
#define FNV_PRIME 1099511628211UL

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

// No proprietary code
// Source: https://benhoyt.com/writings/hash-table-in-c/
static uint64_t hash(const char* key) {
    uint64_t hash = FNV_OFFSET;
    for (const char* p = key; *p; p++) {
        hash ^= (uint64_t)(unsigned char)(*p);
        hash *= FNV_PRIME;
    }
    return hash;
}

static const char* setEntry(Symbol** entries, unsigned int capacity,
        const char* key, void* value, unsigned int* plength) {
    uint64_t keyhash = hash(key);
    unsigned int index = (unsigned int)(keyhash & (uint64_t)(capacity - 1));

    while ((*entries)[index].key != NULL) {
        if (strcmp(key, (*entries)[index].key) == 0) {
            (*entries)[index].value = value;
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
    (*entries)[index].key = strdup(key);
    (*entries)[index].value = value;
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

void setKeyValue(SymbolTable** table, char* scope, char* id, char* type) {
    char* prehash = concat(scope, id, "", "", "");

    if ((*table)->length >= (*table)->capacity / 2) {
        doubleCapacity(table);
    }

    setEntry(&(*table)->symbols, (*table)->capacity, prehash, type, &(*table)->length);
}

void* getValue(SymbolTable* table, char* scope, char* id) {
    char* prehash = concat(scope, id, "", "", "");
    uint64_t keyhash = hash(prehash);
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

unsigned int length(SymbolTable* table) {
    return table->length;
}

void printTable(SymbolTable* table){
   Symbol* ptr = table->symbols;;

   unsigned int size = length(table);

   for(unsigned int i = 0; i < size; i++){
       Symbol s = ptr[i];
       printf("KEY: %s | VALUE %s\n",s.key, s.value);
    }
}

void destroyTable(SymbolTable** table){
    for(unsigned int i = 0; i < (*table)->capacity; i++){
        free((void*)(*table)->symbols[i].key);
    }

    free((*table)->symbols);
    free(*table);
}


