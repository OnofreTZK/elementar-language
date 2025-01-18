#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

typedef struct {
	void** items;
	size_t capacity;
	size_t size;
} DynamicList;

#ifndef LISTS_H
#define LISTS_H

DynamicList* createList(size_t initial_capacity);
void addToList(DynamicList* list, void* value);
void* getFromList(DynamicList* list, size_t index);
void freeList(DynamicList* list);

#endif