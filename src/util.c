#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static int label_counter = 0;

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

char *replace(char *str, char *old_str, char *new_str) {
    char *result;
    int i, count = 0;
    int new_len = strlen(new_str);
    int old_len = strlen(old_str);

    // Contar o número de ocorrências da string a ser substituída
    for (i = 0; str[i] != '\0'; i++) {
        if (strstr(&str[i], old_str) == &str[i]) {
            count++;
            i += old_len - 1;
        }
    }

    // Alocar memória para a nova string
    result = (char *)malloc(i + count * (new_len - old_len) + 1);
    if (result == NULL) {
        fprintf(stderr, "Erro ao alocar memória\n");
        exit(1);
    }

    i = 0;
    while (*str) {
        if (strstr(str, old_str) == str) {
            strcpy(&result[i], new_str);
            i += new_len;
            str += old_len;
        } else {
            result[i++] = *str++;
        }
    }
    result[i] = '\0';

    return result;
}

char* getTypeValue(char* type) {
  if (strcmp(type, "int[]") == 0){
    return "INT_TYPE";
  } else if (strcmp(type, "float[]") == 0){
    return "FLOAT_TYPE";
  } else if (strcmp(type, "string[]") == 0){
    return "STRING_TYPE";
  } else if (strcmp(type, "double[]") == 0){
    return "DOUBLE_TYPE";
  } else if (strcmp(type, "bool[]") == 0){
    return "BOOL_TYPE";
  } else if (strcmp(type, "list[]") == 0){
    return "LIST_TYPE"; 
  } else {
      return "";
  }
}

char* getTypeCast(char* type) {
  if (strcmp(type, "int[]") == 0){
    return "*(int*)";
  } else if (strcmp(type, "float[]") == 0){
    return "*(float*)";
  } else if (strcmp(type, "string[]") == 0){
    return "*(char*)";
  } else if (strcmp(type, "double[]") == 0){
    return "*(double*)";
  } else if (strcmp(type, "bool[]") == 0){
    return "*(short int*)";
  } else if (strcmp(type, "list[]") == 0){
    return "(DynamicList*)"; 
  } else {
    return "";
  }
}

int isListType(char* type) {
  if (strchr(type, '[') != NULL || strchr(type, ']') != NULL) {
    return 1;
  }
  return 0;
}

char* getSecondElement(const char* str) {

  char *temp_str = strdup(str); 
  char *token = strtok(temp_str, ","); 

  if (token == NULL) {
      fprintf(stderr, "Não há elementos suficientes.\n");
      free(temp_str); 
      return NULL;
  }

  token = strtok(NULL, ",");
  if (token == NULL) {
      fprintf(stderr, "Não há segundo elemento.\n");
      free(temp_str); 
      return NULL;
  }

  char *result = strdup(token); 
  free(temp_str);
  return result;
}

int isIdentifier(const char *str) {
    if (*str == '\0') {
        return 0; // String vazia não é um identificador
    }

    if (!isalpha(*str) && *str != '_') {
        return 0; // Primeiro caractere inválido
    }

    while (*str) {
        if (!isalnum(*str) && *str != '_') {
            return 0; // Caractere inválido no meio da string
        }
        str++;
    }

    return 1; // É um identificador válido
}