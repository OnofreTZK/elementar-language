#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

char* replace(char *str, char *old_str, char *new_str) {
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

