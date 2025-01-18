#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define FNV_OFFSET 14695981039346656037UL
#define FNV_PRIME 1099511628211UL

static int label_counter = 0;

int is_compatible(const char *type1, const char *type2) {
    return strcmp(type1, type2) == 0; // Verifica se os tipos são iguais
}


char * concat(char * s1, char * s2, char * s3, char * s4, char * s5){
  int tam;
  char * output;

  tam = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5)+ 1;
  output = (char *) malloc(sizeof(char) * tam);
  
  if (!output){
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }
  
  sprintf(output, "%s%s%s%s%s", s1, s2, s3, s4, s5);
  
  return output;
}


char * generateLabel(const char *prefix) {
  char *label = malloc(32); 
  if (label == NULL) {
    fprintf(stderr, "Erro ao alocar memória para label.\n");
    exit(1);
  }
  snprintf(label, 32, "%s_%d", prefix, label_counter++); 
  return label;
}

char * getPrintType(char * variableType){
  if (strcmp(variableType, "int") == 0){
    return "%d";
  } else if (strcmp(variableType, "float") == 0){
    return "%f";
  } else if (strcmp(variableType, "char") == 0){
    return "%c";
  } else if (strcmp(variableType, "string") == 0){
    return "%s";
  } else if (strcmp(variableType, "double") == 0){
    return "%lf";
  } else {
    return "";
  }
}

// No proprietary code
// Source: https://benhoyt.com/writings/hash-table-in-c/
uint64_t generateHash(const char* key) {
    uint64_t hash = FNV_OFFSET;
    for (const char* p = key; *p; p++) {
        hash ^= (uint64_t)(unsigned char)(*p);
        hash *= FNV_PRIME;
    }
    return hash;
}


char** stringToParameterList(char* paramList) {
    size_t maxTypes = 100;
    char** types = malloc(maxTypes * sizeof(char*));
    if (!types) {
        perror("malloc failed");
        return NULL;
    }

    size_t typeCount = 0;

    char* inputCopy = strdup(paramList);
    if (!inputCopy) {
        perror("strdup failed");
        free(types);
        return NULL;
    }

    char* token = strtok(inputCopy, ",");
    while (token) {
        while (*token == ' ') token++; // Remove leading spaces
        char* end = token + strlen(token) - 1;
        while (end > token && (*end == ' ' || *end == '\n' || *end == '\r')) {
            *end = '\0'; // Remove trailing spaces
            end--;
        }

        char* spacePos = strchr(token, ' ');
        if (spacePos) {
            *spacePos = '\0'; // Null-terminate to separate type from id
        }

        types[typeCount++] = strdup(token);
        if (typeCount >= maxTypes) {
            maxTypes *= 2;
            types = realloc(types, maxTypes * sizeof(char*));
            if (!types) {
                perror("realloc failed");
                free(inputCopy);
                return NULL;
            }
        }

        token = strtok(NULL, ",");
    }

    types[typeCount] = NULL;

    free(inputCopy);
    return types;
}


