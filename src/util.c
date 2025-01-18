#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

