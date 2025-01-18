#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

typedef struct {
    void **data;      // Ponteiro para armazenar os endereços dos valores
    size_t size;      // Número de elementos na lista
    size_t capacity;  // Capacidade máxima atual
} DynamicList;


DynamicList* createList(size_t initial_capacity) {
    DynamicList* list = (DynamicList*)malloc(sizeof(DynamicList));
    if (!list) {
        perror("Failed to allocate memory for list");
        exit(EXIT_FAILURE);
    }
    list->data = (void**)malloc(initial_capacity * sizeof(void*));
    if (!list->data) {
        perror("Failed to allocate memory for list data");
        free(list);
        exit(EXIT_FAILURE);
    }

    // Inicializa todos os elementos com NULL
    for (size_t i = 0; i < initial_capacity; i++) {
        list->data[i] = NULL;
    }

    list->size = 0;
    list->capacity = initial_capacity;
    return list;
}

void addToList(DynamicList* list, void* value) {
    if (list->size == list->capacity) {
        size_t new_capacity = list->capacity * 2;
        void** new_data = (void**)realloc(list->data, new_capacity * sizeof(void*));
        if (!new_data) {
            perror("Failed to reallocate memory for list");
            exit(EXIT_FAILURE);
        }
        list->data = new_data;
        list->capacity = new_capacity;
    }
    list->data[list->size] = value;
    list->size++;
}

void setAtIndex(DynamicList* list, void* value, size_t index) {
    if (index >= list->size) {
        fprintf(stderr, "Index out of bounds\n");
        exit(EXIT_FAILURE);
    }

    list->data[index] = value;
}


void* getFromList(DynamicList* list, size_t index) {
    if (index >= list->size) {
        fprintf(stderr, "Index out of bounds\n");
        exit(EXIT_FAILURE);
    }
    return list->data[index];
}

void freeList(DynamicList* list, void (*freeValue)(void*)) {
    for (size_t i = 0; i < list->size; i++) {
        if (list->data[i] != NULL) {
            freeValue(list->data[i]); // Libera o valor individual usando a função fornecida
        }
    }
    free(list->data); // Libera o array de ponteiros
    free(list);       // Libera a estrutura
}
