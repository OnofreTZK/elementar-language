#include "../include/error_checker.h"
#include <stdio.h>
#include "../y.tab.h"
#include "../include/util.h"
#include <string.h>

extern SymbolTable *symbol_table;
extern Scope *scope_stack;
extern char *filename; // Nome do arquivo sendo analisado

// Função auxiliar para relatar erros usando yyerror
void report_error(const char *msg, int line, int column) {
    if (!msg || !filename) {
        fprintf(stderr, "Erro interno: Mensagem ou nome do arquivo é nulo.\n");
        exit(1);
    }

    // Formata a mensagem completa para ser passada ao yyerror
    char full_msg[512];
    snprintf(full_msg, sizeof(full_msg), "%s-%d:%d: %s", filename, line, column, msg);

    // Chama yyerror para imprimir o erro
    yyerror(full_msg);
}


// Adiciona um símbolo ao escopo atual
void add_symbol_to_scope(const char *name, const char *type, int line, int column) {
    const char *current_scope = top(scope_stack);
    if (is_symbol_in_scope(name)) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Variável '%s' redeclarada no escopo '%s'.", name, current_scope);
        report_error(msg, line, column);
        return;
    }
    setKeyValue(&symbol_table, (char *)current_scope, (char *)name, type);
}

// Verifica se um símbolo está no escopo atual
int is_symbol_in_scope(const char *name) {
    const char *current_scope = top(scope_stack);
    return getValue(symbol_table, (char *)current_scope, (char *)name) != NULL;
}

// Obtém o tipo de um símbolo no escopo atual
const char *get_symbol_type_in_scope(const char *name) {
    const char *current_scope = top(scope_stack);
    return (const char *)getValue(symbol_table, (char *)current_scope, (char *)name);
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
        snprintf(msg, sizeof(msg), "Variável '%s' não declarada.", lhs);
        report_error(msg, line, column);
        return;
    }

    // Compatibilidade de tipos, incluindo literais
    if ((strcmp(lhs_type, "int") == 0 && (strcmp(rhs_type, "int") == 0 || strcmp(rhs_type, "literal_int") == 0)) ||
        (strcmp(lhs_type, "float") == 0 && 
         (strcmp(rhs_type, "float") == 0 || strcmp(rhs_type, "double") == 0 || strcmp(rhs_type, "literal_float") == 0)) ||
        (strcmp(lhs_type, "double") == 0 && 
         (strcmp(rhs_type, "float") == 0 || strcmp(rhs_type, "double") == 0 || strcmp(rhs_type, "literal_float") == 0)) ||
        (strcmp(lhs_type, "char") == 0 && (strcmp(rhs_type, "char") == 0 || strcmp(rhs_type, "literal_char") == 0)) ||
        (strcmp(lhs_type, "string") == 0 && strcmp(rhs_type, "literal_string") == 0)) {
        return; // Compatível
    }

    // Reporta incompatibilidade de tipos
    char msg[256];
    snprintf(msg, sizeof(msg), "Tipos incompatíveis na atribuição: '%s' e '%s'.", lhs_type, rhs_type);
    report_error(msg, line, column);
}



// Verifica se uma variável está sendo redeclarada
void check_variable_redeclaration(const char *name, int line, int column) {
    if (is_symbol_in_scope(name)) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Variável '%s' já declarada no escopo atual.", name);
        report_error(msg, line, column);
    }
}

void check_undefined_variable(const char *name, int line, int column) {
    if (!scope_stack) {
        report_error("Pilha de escopos não inicializada.", line, column);
        exit(1);
    }

    if (!symbol_table) {
        report_error("Tabela de símbolos não inicializada.", line, column);
        exit(1);
    }

    const char *current_scope = top(scope_stack);

    if (!current_scope) {
        report_error("Escopo atual não encontrado.", line, column);
        exit(1);
    }

    // Verifica se a variável existe na tabela de símbolos
    if (!getValue(symbol_table, (char *)current_scope, (char *)name)) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Variável '%s' não declarada.", name);
        report_error(msg, line, column);
    }
}

// Verifica incrementos e decrementos
void check_increment(const char *type, int line, int column) {
    if (strcmp(type, "int") != 0) {
        char msg[256];
        snprintf(msg, sizeof(msg), "Incremento só é permitido para variáveis do tipo 'int'.");
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

// Gerenciamento de escopos
void enter_scope(const char *scope_name) {
    push((char *)scope_name, &scope_stack);
}

void exit_scope() {
    pop(&scope_stack);
}
