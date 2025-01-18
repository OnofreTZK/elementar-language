#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

typedef enum {
    INT_TYPE,
    FLOAT_TYPE,
    STRING_TYPE,
    DOUBLE_TYPE,
    BOOL_TYPE
} DataType;

typedef struct {
	void** items;
	size_t capacity;
	size_t size;
    DataType type;
} DynamicList;

#ifndef LISTS_H
#define LISTS_H

DynamicList* createList(size_t initial_capacity, DataType type);
void addToList(DynamicList* list, void* value);
void* getFromList(DynamicList* list, size_t index);
void freeList(DynamicList* list);

#endif