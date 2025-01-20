#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include "types.h"
#include "util.h"

#define INITIAL_CAPACITY 16

UserDefinedTypesTable * createUserDefinedTypesTable(){
    UserDefinedTypesTable* table = malloc(sizeof(UserDefinedTypesTable));
    if(!table){
        return NULL;
    }

    table->capacity = INITIAL_CAPACITY;
    table->length = 0;
    table->structs = calloc(INITIAL_CAPACITY, sizeof(UserDefinedStruct));

    return table;
}

static const char* setEntry(UserDefinedStruct** entries, unsigned int capacity,
        const char* key, const char* value, char** attributes, char** attributesTypes, unsigned int* plength) {
    uint64_t keyhash = generateHash(key);
    unsigned int index = (unsigned int)(keyhash & (uint64_t)(capacity - 1));

    while ((*entries)[index].key != NULL) {
        if (strcmp(key, (*entries)[index].key) == 0) {
            (*entries)[index].name = strdup(value);
            (*entries)[index].attributes = attributes;
            (*entries)[index].attributesTypes = attributesTypes;
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
    (*entries)[index].name = strdup(value);
    (*entries)[index].attributes = attributes;
    (*entries)[index].attributesTypes = attributesTypes;
    return key;
}

static bool doubleCapacity(UserDefinedTypesTable** table) {
    unsigned int newCapacity = (*table)->capacity * 2;
    if (newCapacity < (*table)->capacity) {
        return false; 
    }

    UserDefinedStruct* newStructs = calloc(newCapacity, sizeof(UserDefinedStruct));
    if (newStructs == NULL) {
        return false;
    }

    for (unsigned int i = 0; i < (*table)->capacity; i++) {
        UserDefinedStruct entry = (*table)->structs[i];
        if (entry.key != NULL) {
            setEntry(&newStructs, newCapacity, entry.key, entry.name, entry.attributes, entry.attributesTypes, NULL);
        }
    }

    free((*table)->structs);
    (*table)->structs = newStructs;
    (*table)->capacity = newCapacity;
    return true;
}

void setKeyUserType(UserDefinedTypesTable** table, char* scope, char* id, const char* type, char** attributes, char** attributesTypes) {
    char* prehash = concat(scope, id, "", "", "");

    if ((*table)->length >= (*table)->capacity / 2) {
        doubleCapacity(table);
    }

    setEntry(&(*table)->structs, (*table)->capacity, prehash, type, attributes, attributesTypes, &(*table)->length);
}

UserDefinedStruct* getStruct(UserDefinedTypesTable* table, char* scope, char* id) {
    char* prehash = concat(scope, id, "", "", "");
    uint64_t keyhash = generateHash(prehash);
    unsigned int index = (unsigned int)(keyhash & (uint64_t)(table->capacity - 1));


    while (table->structs[index].key != NULL) {
        if (strcmp(prehash, table->structs[index].key) == 0) {
            return &table->structs[index];
        }

        index++;
        if (index >= table->capacity) {
            index = 0;
        }
    }

    return NULL;
}

//void printUserDefinedTypesTable(UserDefinedTypesTable* table){
//   Symbol* ptr = table->symbols;;
//
//   unsigned int size = table->capacity;
//
//   for(unsigned int i = 0; i < size; i++){
//       Symbol s = ptr[i];
//       printf("KEY: %s | VALUE %s\n",s.key, s.value);
//    }
//}

void destroyUserDefinedTypesTable(UserDefinedTypesTable** table){
    for(unsigned int i = 0; i < (*table)->capacity; i++){
        free((void*)(*table)->structs[i].key);
    }

    free((*table)->structs);
    free(*table);
}


