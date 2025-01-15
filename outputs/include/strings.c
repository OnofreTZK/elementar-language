#include <string.h>
#include <stdio.h>
#include <stdlib.h>

char * concat(const char *str1, const char *str2) {
    // Calcula o tamanho total da string concatenada
    size_t len1 = strlen(str1);
    size_t len2 = strlen(str2);
    size_t totalLen = len1 + len2 + 1; // +1 para o terminador nulo

    // Aloca memória para a nova string
    char *result = (char *)malloc(totalLen * sizeof(char));
    if (result == NULL) {
        fprintf(stderr, "Erro ao alocar memória.\n");
        exit(1);
    }

    // Concatena as strings na memória alocada
    strcpy(result, str1);  // Copia str1 para result
    strcat(result, str2);  // Adiciona str2 a result

    return result; // Retorna o ponteiro para a nova string
}
