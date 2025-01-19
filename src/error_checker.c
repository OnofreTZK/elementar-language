#include "../include/error_checker.h"
#include <stdio.h>
#include "../y.tab.h"
#include "../include/util.h"
#include <string.h>

extern SymbolTable *table;
extern Scope *stack;
extern char *filename; // Nome do arquivo sendo analisado

void report_error(const char *msg, int line, int column) {
    if (!msg || !filename) {
        fprintf(stderr, "Erro interno: Mensagem ou nome do arquivo é nulo.\n");
        return; // Evita sair do programa, mas não gera erro fatal
    }

    char full_msg[512];
    snprintf(full_msg, sizeof(full_msg), "%s-%d:%d: %s", filename, line, column, msg);
    yyerror(full_msg);
}


// Verifica a compatibilidade de tipos
int is_compatible(const char *expected, const char *actual) {
    if (!expected || !actual) {
        return 0; // Se algum tipo for nulo, não são compatíveis
    }

    // Tipos idênticos são sempre compatíveis
    if (strcmp(expected, actual) == 0) {
        return 1;
    }

    // Regras de compatibilidade específicas
    if ((strcmp(expected, "int") == 0 && (strcmp(actual, "literal_int") == 0)) ||
        (strcmp(expected, "float") == 0 && (strcmp(actual, "int") == 0 || strcmp(actual, "literal_int") == 0 || strcmp(actual, "literal_float") == 0)) ||
        (strcmp(expected, "double") == 0 && (strcmp(actual, "float") == 0 || strcmp(actual, "int") == 0 || strcmp(actual, "literal_int") == 0 || strcmp(actual, "literal_float") == 0)) ||
        (strcmp(expected, "char") == 0 && strcmp(actual, "literal_char") == 0) ||
        (strcmp(expected, "string") == 0 && strcmp(actual, "literal_string") == 0)) {
        return 1; // Compatível
    }

    // Se nenhuma regra de compatibilidade for atendida, retorna incompatível
    return 0;
}

void check_array_initialization(const char *name, const char *type, const char *initializerType, int line, int column) {
    // Verifica se o tipo do inicializador é compatível com o tipo do array
    if (!is_compatible(type, initializerType)) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Erro: Tipo do array '%s' (%s) incompatível com o inicializador (%s).", name, type, initializerType);
        report_error(msg, line, column);
    }
}


void check_array_declaration(const char *name, const char *type, int line, int column) {
    const char *currentScope = top(stack);

    if (!currentScope) {
        fprintf(stderr, "Erro interno: Escopo atual não encontrado.\n");
        exit(1);
    }

    // Verifica se o array já foi declarado no escopo atual
    if (is_symbol_in_scope(name)) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Array '%s' já foi declarado no escopo '%s'.", name, currentScope);
        report_error(msg, line, column);
        return;
    }

    // Adiciona o array à tabela de símbolos (usando cast para char*)
    setKeyValue(&table, (char*)currentScope, (char*)name, (char*)type);
}


void check_array_access(const char *name, const char *indexType, int line, int column) {
    // Verifica se o índice é do tipo inteiro
    if (strcmp(indexType, "int") != 0) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Erro: Índice de acesso ao array '%s' deve ser do tipo 'int', mas foi encontrado '%s'.", name, indexType);
        report_error(msg, line, column);
    }
}

void check_array_operation(const char *name, const char *operationType, int line, int column) {
    // Exemplo: Verifica se a operação é válida para o tipo do array
    if (strcmp(operationType, "add") == 0 && strcmp(name, "DynamicList*") != 0) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Erro: Operação 'add' não suportada para o array '%s'.", name);
        report_error(msg, line, column);
    }
}


// Adiciona um símbolo ao escopo atual
void add_symbol_to_scope(const char *name, const char *type, int line, int column) {
    // Verifica se 'name' é uma palavra-chave reservada (como 'int' ou 'float')
    const char *reserved_keywords[] = {"int", "float", "char", "string", "bool", "double", "void", NULL};
    for (int i = 0; reserved_keywords[i] != NULL; i++) {
        if (strcmp(name, reserved_keywords[i]) == 0) {
            // Não adiciona palavras-chave à tabela de símbolos
            return;
        }
    }

    const char *current_scope = top(stack);

    if (is_symbol_in_scope(name)) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Variável '%s' redeclarada no escopo '%s'.", name, current_scope);
        report_error(msg, line, column);
        return;
    }


    setKeyValue(&table, (char *)current_scope, (char *)name, type);
}

int is_symbol_in_scope(const char *name) {
    const char *current_scope = top(stack);
    printf("DEBUG: Verificando se '%s' está no escopo '%s'.\n", name, current_scope);
    return getValue(table, (char *)current_scope, (char *)name) != NULL;
}



// Obtém o tipo de um símbolo no escopo atual
const char *get_symbol_type_in_scope(const char *name) {
    const char *current_scope = top(stack);
    return (const char *)getValue(table, (char *)current_scope, (char *)name);
}

// Verifica erros de tipo em retorno de função
void check_return_type(const char *expected, const char *actual, int line, int column) {
    if (!is_compatible(expected, actual)) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Retorno esperado '%s', mas encontrado '%s'.", expected, actual);
        report_error(msg, line, column);
    }
}

void check_assignment(const char *lhs, const char *rhs_type, int line, int column) {
    const char *lhs_type = get_symbol_type_in_scope(lhs);

    // Verifica se a variável foi declarada
    if (!lhs_type) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Erro: Variável '%s' não declarada.", lhs);
        report_error(msg, line, column);
        return;
    }

    // Compatibilidade de tipos, incluindo conversões implícitas
    if ((strcmp(lhs_type, "int") == 0 && 
         (strcmp(rhs_type, "int") == 0 || strcmp(rhs_type, "literal_int") == 0)) ||
        (strcmp(lhs_type, "float") == 0 && 
         (strcmp(rhs_type, "float") == 0 || strcmp(rhs_type, "double") == 0 || strcmp(rhs_type, "literal_float") == 0 || strcmp(rhs_type, "int") == 0 || strcmp(rhs_type, "literal_int") == 0)) ||
        (strcmp(lhs_type, "double") == 0 && 
         (strcmp(rhs_type, "float") == 0 || strcmp(rhs_type, "double") == 0 || strcmp(rhs_type, "literal_float") == 0)) ||
        (strcmp(lhs_type, "char") == 0 && 
         (strcmp(rhs_type, "char") == 0 || strcmp(rhs_type, "literal_char") == 0)) ||
        (strcmp(lhs_type, "string") == 0 && 
         (strcmp(rhs_type, "string") == 0 || strcmp(rhs_type, "literal_string") == 0))) {
        return; // Compatível
    }

    // Reporta incompatibilidade de tipos
    char msg[256];
    snprintf(msg, sizeof(msg), "Erro: Tipos incompatíveis na atribuição para '%s': esperado '%s', mas encontrado '%s'.", lhs, lhs_type, rhs_type);
    report_error(msg, line, column);
}

void check_variable_declaration(const char *name, int line, int column) {
    const char *currentScope = top(stack);

    if (!currentScope) {
        fprintf(stderr, "Erro interno: Escopo atual não encontrado.\n");
        exit(1);
    }

    // Verifica se a variável já foi declarada no escopo atual
    if (is_symbol_in_scope(name)) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Variável '%s' já foi declarada no escopo '%s'.", name, currentScope);
        report_error(msg, line, column);
        exit(1); // Interrompe a execução em caso de erro crítico
    }
}

void check_undefined_variable(const char *name, int line, int column) {
    if (!stack) {
        report_error("Pilha de escopos não inicializada.", line, column);
        exit(1);
    }


    if (!table) {
        report_error("Tabela de símbolos não inicializada.", line, column);
        exit(1);
    }

    const char *current_scope = top(stack);

    if (!current_scope) {
        report_error("Escopo atual não encontrado.", line, column);
        exit(1);
    }

    // Verifica se a variável existe na tabela de símbolos
    if (!getValue(table, (char *)current_scope, (char *)name)) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Variável '%s' não declarada.", name);
        report_error(msg, line, column);
    }
}

// Verifica incrementos e decrementos
void check_increment(const char *type, int line, int column) {
    if (strcmp(type, "int") != 0 && strcmp(type, "float") != 0 && strcmp(type, "double") != 0) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Operadores '++' e '--' só são permitidos para tipos numéricos (encontrado '%s').", type);
        report_error(msg, line, column);
    }
}


// Verifica operações aritméticas
void check_arithmetic_operation(const char *op, const char *type1, const char *type2, int line, int column) {
    if (strcmp(type1, "int") != 0 || strcmp(type2, "int") != 0) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Operação '%s' só é permitida para variáveis do tipo 'int'.", op);
        report_error(msg, line, column);
    }
}

void enter_scope(const char *scope_name) {
    if (!stack) {
        fprintf(stderr, "Erro: Pilha de escopos não inicializada.\n");
        exit(1);
    }
    push((char *)scope_name, &stack);
    printf("DEBUG: Entrando no escopo '%s'.\n", scope_name);
}


void exit_scope() {
    if (!stack) {
        fprintf(stderr, "Erro: Pilha de escopos não inicializada.\n");
        exit(1);
    }
    const char *scope_name = top(stack);
    printf("DEBUG: Saindo do escopo '%s'.\n", scope_name);
    pop(&stack);
}
