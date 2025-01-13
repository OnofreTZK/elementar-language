#include <stdio.h>
#include <stdlib.h>

void saveCode(const char *code, const char *filename) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        fprintf(stderr, "Erro ao abrir o arquivo '%s' para escrita.\n", filename);
        exit(1);
    }

    fprintf(file, "%s\n", code);
    fclose(file);
    printf("Código salvo em '%s'.\n", filename);
}