#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef enum {
    INT_TYPE,
    FLOAT_TYPE,
    STRING_TYPE,
    DOUBLE_TYPE,
    BOOL_TYPE
} DataType;


typedef struct {
    void **data;      // Ponteiro para armazenar os endereços dos valores
    size_t size;      // Número de elementos na lista
    size_t capacity;  // Capacidade máxima atual
    DataType type; 
} DynamicList;


DynamicList* createList(size_t initial_capacity, DataType type) {
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
    list->size = 0;
    list->capacity = initial_capacity;
    list->type = type; 
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

    // Alocação de memória para o dado específico
    switch (list->type) {
        case INT_TYPE:
            list->data[list->size] = malloc(sizeof(int)); 
            *(int*)list->data[list->size] = *(int*)value; 
            break;
        case FLOAT_TYPE:
            list->data[list->size] = malloc(sizeof(float)); 
            *(float*)list->data[list->size] = *(float*)value; 
            break;
        case STRING_TYPE:
            list->data[list->size] = strdup((char*)value);
            break;
        case DOUBLE_TYPE:
            list->data[list->size] = malloc(sizeof(double)); 
            *(double*)list->data[list->size] = *(double*)value; 
            break;
         case BOOL_TYPE:
            list->data[list->size] = malloc(sizeof(short int));
            *(short int*)list->data[list->size] = *(short int*)value;
            break;
        default:
            fprintf(stderr, "Invalid Type\n");
            exit(EXIT_FAILURE);
    }

    list->size++;
}

void setListIndex(DynamicList* list, void* value, size_t index) {
    if (index >= list->size) {
        fprintf(stderr, "Index out of bounds\n");
        exit(EXIT_FAILURE);
    }

    if (list->data[index] != NULL) {
        switch (list->type) {
            case INT_TYPE:
                free((int*)list->data[index]);
                break;
            case FLOAT_TYPE:
                free((float*)list->data[index]);
                break;
            case DOUBLE_TYPE:
                free((double*)list->data[index]);
                break;
            case STRING_TYPE:
                free((char*)list->data[index]);
                break;
            case BOOL_TYPE:
                free((short int*)list->data[index]);
                break;
            default:
                fprintf(stderr, "Inválid Type.\n");
                exit(EXIT_FAILURE);
        }
    }

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
            fprintf(stderr, "Inválid Type.\n");
            exit(EXIT_FAILURE);
    }
}


void* getFromList(DynamicList* list, size_t index) {
    if (index >= list->size) {
        fprintf(stderr, "Index out of bounds\n");
        exit(EXIT_FAILURE);
    }
    return list->data[index];
}

void freeList(DynamicList* list) {

    if (list == NULL) {
        return;
    }

    size_t size = list->size;

    for (size_t i = 0; i < list->size; ++i) {
        if (list->data[i] != NULL) {
            printf("%zu\n", i);
            switch (list->type) {
               
                case INT_TYPE:
                    free((int*)list->data[i]); 
                    break;
                case FLOAT_TYPE:
                    free((float*)list->data[i]); 
                    break;
                case STRING_TYPE:
                    free((char*)list->data[i]); 
                    break;
                case DOUBLE_TYPE:
                    free((double*)list->data[i]); 
                    break;
                default:
                    fprintf(stderr, "Invalid Type.\n");
                    break;
            }
        }
    }

    free(list->data);
    free(list);
}


