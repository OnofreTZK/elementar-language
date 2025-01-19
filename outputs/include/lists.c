#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef enum {
    INT_TYPE,
    FLOAT_TYPE,
    STRING_TYPE,
    DOUBLE_TYPE,
    BOOL_TYPE,
    LIST_TYPE // Novo tipo para listas de listas
} DataType;



typedef struct {
    void **data;      // Ponteiro para armazenar os endereços dos valores
    size_t size;      // Número de elementos na lista
    size_t capacity;  // Capacidade máxima atual
    DataType type; 
} DynamicList;


DynamicList* createList(size_t initial_capacity, int type) {
    DynamicList* list = (DynamicList*)malloc(sizeof(DynamicList));
    list->data = (void**)malloc(initial_capacity * sizeof(void*));
    list->size = 0;
    list->capacity = initial_capacity;
    list->type = type;
    return list;
}

void* allocateAndCopyValue(int type, void* value) {
    if (!value) {
        fprintf(stderr, "NULL value cannot be added to the list\n");
        exit(EXIT_FAILURE);
    }

    void* new_value = NULL;
    switch (type) {
        case INT_TYPE:
            new_value = malloc(sizeof(int));
            *(int*)new_value = *(int*)value;
            break;
        case FLOAT_TYPE:
            new_value = malloc(sizeof(float));
            *(float*)new_value = *(float*)value;
            break;
        case STRING_TYPE:
            new_value = strdup((char*)value);
            break;
        case DOUBLE_TYPE:
            new_value = malloc(sizeof(double));
            *(double*)new_value = *(double*)value;
            break;
        case BOOL_TYPE:
            new_value = malloc(sizeof(short int));
            *(short int*)new_value = *(short int*)value;
            break;
        default:
            fprintf(stderr, "Invalid Type\n");
            exit(EXIT_FAILURE);
    }
    return new_value;
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

    if (list->type == LIST_TYPE) {
        list->data[list->size] = value;  // Apenas copia o ponteiro da sub-lista
    } else {
        list->data[list->size] = allocateAndCopyValue(list->type, value);
    }
    list->size++;
}

void* getFromList(DynamicList* list, size_t index) {
    if (index >= list->size) {
        fprintf(stderr, "Index out of bounds\n");
        exit(EXIT_FAILURE);
    }
    return list->data[index];
}

void freeList(DynamicList* list) {
    if (!list) return;

    for (size_t i = 0; i < list->size; i++) {
        if (list->data[i]) {
            switch (list->type) {
                case INT_TYPE:
                case FLOAT_TYPE:
                case DOUBLE_TYPE:
                case BOOL_TYPE:
                    free(list->data[i]);
                    break;
                case STRING_TYPE:
                    free((char*)list->data[i]);
                    break;
                case LIST_TYPE:
                    freeList((DynamicList*)list->data[i]); 
                    break;
                default:
                    fprintf(stderr, "Invalid Type in freeList\n");
                    break;
            }
        }
    }

    free(list->data); // Libera o array de ponteiros
    free(list);       // Libera a estrutura principal
}

void setListIndex(DynamicList* list, void* value, size_t index) {
    if (index >= list->size) {
        fprintf(stderr, "Index out of bounds\n");
        exit(EXIT_FAILURE);
    }

    // Libera o elemento existente no índice
    if (list->data[index] != NULL) {
        switch (list->type) {
            case INT_TYPE:
            case FLOAT_TYPE:
            case DOUBLE_TYPE:
            case BOOL_TYPE:
                free(list->data[index]);
                break;
            case STRING_TYPE:
                free((char*)list->data[index]);
                break;
            case LIST_TYPE:
                freeList((DynamicList*)list->data[index]); // Libera a sub-lista recursivamente
                break;
            default:
                fprintf(stderr, "Invalid Type in setListIndex\n");
                exit(EXIT_FAILURE);
        }
    }

    // Define o novo valor no índice
    if (list->type == LIST_TYPE) {
        // Apenas copia o ponteiro da sub-lista
        list->data[index] = value;
    } else {
        switch (list->type) {
            case INT_TYPE:
                list->data[index] = malloc(sizeof(int));
                *(int*)list->data[index] = *(int*)value;
                break;
            case FLOAT_TYPE:
                list->data[index] = malloc(sizeof(float));
                *(float*)list->data[index] = *(float*)value;
                break;
            case DOUBLE_TYPE:
                list->data[index] = malloc(sizeof(double));
                *(double*)list->data[index] = *(double*)value;
                break;
            case STRING_TYPE:
                list->data[index] = strdup((char*)value);
                break;
            case BOOL_TYPE:
                list->data[index] = malloc(sizeof(short int));
                *(short int*)list->data[index] = *(short int*)value;
                break;
            default:
                fprintf(stderr, "Invalid Type in setListIndex\n");
                exit(EXIT_FAILURE);
        }
    }
}
