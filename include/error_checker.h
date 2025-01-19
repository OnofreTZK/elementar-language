#ifndef SEMANTIC_CHECK_H
#define SEMANTIC_CHECK_H

#include <stdio.h>
#include <string.h>
#include "symbol_table.h"
#include "scope_stack.h"
#include "../y.tab.h"

// Variáveis globais
extern const char *current_function_return_type; // Tipo de retorno da função atual

extern SymbolTable *table;               // Tabela de símbolos
extern Scope *stack;                      // Pilha de escopos


int yyerror(char *msg); // Declarar a função do parser
void report_error(const char *msg, int line, int column);
int is_compatible(const char *type1, const char *type2); // Declarar função para verificar tipos

// Funções auxiliares para a tabela de símbolos e escopos
void add_symbol_to_scope(const char *name, const char *type, int line, int column);
const char *get_symbol_type_in_scope(const char *name);
int is_symbol_in_scope(const char *name);

// Verificação de erros semânticos
void check_return_type(const char *expected, const char *actual, int line, int column);
void check_assignment(const char *lhs, const char *rhs_type, int line, int column);

void check_variable_declaration(const char *name, int line, int column);
void check_array_declaration(const char *name, const char *type, int line, int column);
void check_array_access(const char *name, const char *indexType, int line, int column);
void check_array_operation(const char *name, const char *operationType, int line, int column);
void check_array_initialization(const char *name, const char *type, const char *initializerType, int line, int column);
void check_variable_redeclaration(const char *name, int line, int column);
void check_undefined_variable(const char *name, int line, int column);
void check_increment(const char *type, int line, int column);
void check_arithmetic_operation(const char *op, const char *type1, const char *type2, int line, int column);
void check_function_call(const char *function_name, const char *expected_return_type, int line, int column);

// Gerenciamento de escopos
void enter_scope(const char *scope_name);
void exit_scope();

#endif