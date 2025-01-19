%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "util.h"
#include "record.h"
#include "file_save.h"
#include "scope_stack.h"
#include "symbol_table.h"
#include "error_checker.h"

int yylex(void);
int yyerror(char *s);
char *filename = NULL;
extern int yylineno;
extern int yycolumn;
extern int get_column();
extern char *yytext;
extern FILE *yyin;

Scope* scope_stack;
SymbolTable* symbol_table;
const char *current_function_return_type;

#define FILENAME "./outputs/output.c"
#define PROGRAM_NAME "./outputs/program"

%}

%union {
	char * sValue; 
	struct record * rec;
};



%token <sValue> ID STRING_LITERAL INT FLOAT DOUBLE CHAR_LITERAL

%token TYPE_INT TYPE_VOID CONST TYPE_CHAR TYPE_STRUCT TYPE_STRING TYPE_SHORT 
       TYPE_UNSIGNED_INT TYPE_FLOAT TYPE_DOUBLE TYPE_LONG IF ELSE WHILE RETURN MAIN TYPE_BOOL
       SWITCH FOR CASE BREAK CONTINUE BLOCK_BEGIN BLOCK_END PAREN_OPEN
       PAREN_CLOSE BRACKET_OPEN BRACKET_CLOSE SEMICOLON COMMA DOT EQUALS ASSIGN
       LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL NOT_EQUAL INCREMENT DECREMENT
       PLUS MINUS MULTIPLY DIVIDE MODULO AND OR NOT EXPONENT TRUE FALSE

%type <rec> term unary_expression arithmetic_expression relational_expression 
%type <rec> boolean_expression expression arithmetic_operator relational_operator boolean_operator
%type <rec> statement_list statement type declaration initialization assignment
%type <rec> main for_statement for_initializer for_increment 
%type <rec> function_declaration argument_list argument_list_nonempty
%type <rec> function_call if_statement while_statement return_statement
%type <rec> program
%type <rec> parameter_list_nonempty
%type <rec> block_statement
%type <rec> parameter_list

%start program

%left OR AND PLUS MINUS MULTIPLY DIVIDE MODULO
%right NOT ASSIGN INCREMENT DECREMENT
%nonassoc EQUALS NOT_EQUAL LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL

%%

program: statement_list SEMICOLON {
            printf("program\n");
            char * includes = concat(
                "#include <stdio.h>\n", 
                "#include <string.h>\n", 
                "#include <math.h>\n", 
                "#include \"./include/strings.h\"\n",
                "#include \"./include/type-conversions.h\"\n");

            char * final = concat(includes, $1->code, "", "", "");
            freeRecord($1);
            //salva código em arquivo
            saveCode(final, FILENAME);

            const char *executable = PROGRAM_NAME;
            char command[256];

            //printTable(table);
            //TODO melhorar isso aqui ao pegar os imports
            snprintf(command, sizeof(command), "gcc %s ./outputs/include/strings.c ./outputs/include/type-conversions.c -lm -o %s", FILENAME, PROGRAM_NAME);
            printf("Compiling the code with the command: %s\n", command);

            int result = system(command);
            if (result == 0) {
                printf("Code compiled succesfully! Executable generated: %s\n", executable);
            } else {
                fprintf(stderr, "Error compiling the code. Verify the file '%s' for more details.\n", FILENAME);
            }

            free(final);
        }
        ;

statement_list: statement {
                $$ = createRecord($1->code,"");
                printf("statement_list: %s\n", $1->code);
                freeRecord($1);
            }
            | statement_list SEMICOLON statement {
                char * code = concat($1->code, ";\n", $3->code, "", "");
                printf("statement_list 2: %s\n", code);
                $$ = createRecord(code,"");
                freeRecord($1);
                freeRecord($3);
                free(code);
            }
            ;

type: TYPE_INT {$$ = createRecord("int","type int");}
    | TYPE_FLOAT {$$ = createRecord("float","type float");}
    | TYPE_CHAR {$$ = createRecord("char","type char");}
    | TYPE_BOOL {$$ = createRecord("short int","type bool");}
    | TYPE_STRING {$$ = createRecord("char","type string");}
    | TYPE_VOID {$$ = createRecord("void","type void");}
    | TYPE_SHORT {$$ = createRecord("short","type short");}
    | TYPE_INT BRACKET_OPEN BRACKET_CLOSE {$$ = createRecord("int[]","type int[]");}
    | TYPE_FLOAT BRACKET_OPEN BRACKET_CLOSE {$$ = createRecord("float[]","type float[]");}
    | TYPE_BOOL BRACKET_OPEN BRACKET_CLOSE {$$ = createRecord("short int[]","type bool[]");}
    | TYPE_STRING BRACKET_OPEN BRACKET_CLOSE {$$ = createRecord("string[]","type string[]");}
    ;

boolean_operator: OR {
                    printf("OR\n");
                    $$ = createRecord("||","operator");
                }
                | AND {
                    printf("AND\n");
                    $$ = createRecord("&&","operator");
                }
                ;

relational_operator: EQUALS {
                        printf("EQUALS\n");
                        $$ = createRecord("==","operator");
                    }
                    | NOT_EQUAL {
                        printf("NOT_EQUAL\n");
                        $$ = createRecord("!=","operator");
                   }
                    | LESS_THAN {
                        printf("LESS_THAN\n");
                        $$ = createRecord("<","operator");
                   }
                    | LESS_EQUAL {
                        printf("LESS_EQUAL\n");
                        $$ = createRecord("<=","operator");
                   }
                    | GREATER_THAN {
                        printf("GREATER_THAN\n");
                        $$ = createRecord(">","operator");
                   }
                    | GREATER_EQUAL {
                        printf("GREATER_EQUAL\n");
                        $$ = createRecord(">=","operator");
                   }
                   ;

arithmetic_operator: PLUS {
                    printf("PLUS\n");
                    $$ = createRecord("+","operator");
                }
                | MINUS{
                    printf("MINUS\n");
                    $$ = createRecord("-","operator");
                }
                | MULTIPLY {
                    printf("MULTIPLY\n");
                    $$ = createRecord("*","operator");
                }
                | DIVIDE {
                    printf("DIVIDE\n");
                    $$ = createRecord("/","operator");
                }
                | MODULO {
                    printf("MODULO\n");
                    $$ = createRecord("%","operator");
                }
                | EXPONENT {
                    printf("EXPONENT\n");
                    $$ = createRecord("^","exponent");
                }
                ;

statement: declaration {
                $$ = createRecord($1->code,"declaration");
                printf("declaration: %s\n", $1->code);
                freeRecord($1);
            }
            | initialization {
                $$ = createRecord($1->code,"");
                printf("initialization: %s\n", $1->code);
                freeRecord($1);
            }
            | assignment {
                $$ = createRecord($1->code,$1->code);
                printf("assignment: %s\n", $1->code);
                printf("dado aqui no declaration: %s\n", $1->opt1);
                freeRecord($1);
            }
            | main {
                $$ = createRecord($1->code,"main");
                //printf("main: %s\n", $1->code);
                freeRecord($1);
            }
            | if_statement {
                //printf("if_statement\n");
                $$ = createRecord($1->code,"if_statement");
                freeRecord($1);
            }
            | while_statement {
                //printf("while_statement\n");
                $$ = createRecord($1->code,"while_statement");
                freeRecord($1);
            }
            | for_statement {
                //printf("for_statement\n");
                $$ = createRecord($1->code,"for_statement");
                freeRecord($1);
            }
            | return_statement {
                $$ = createRecord($1->code,"");
                //printf("return_statement: %s\n", $1->code);
                freeRecord($1);
            }
            | block_statement {
                $$ = createRecord($1->code,$1->opt1);
                //printf("block_statement 0: %s\n", $1->code);
                freeRecord($1);
            }
            | function_declaration {
                $$ = createRecord($1->code,"function_declaration");
                //printf("function_declaration 0: %s\n", $1->code);
                freeRecord($1);
            }
            | expression {
                $$ = createRecord($1->code,$1->opt1);
                //printf("expression: %s\n", $1->code);
                //printf("expression 2 (opt): %s\n", $1->opt1);
                freeRecord($1);
            }
            | SEMICOLON {
                //printf("SEMICOLON\n");
                $$ = createRecord("","semicolon");
            }
            | BREAK {
                //printf("BREAK\n");
                $$ = createRecord("break","break");
            }
            | CONTINUE {
                //printf("BREAK\n");
                $$ = createRecord("continue","break");
            }
         ;

term: STRING_LITERAL {
        //printf("STRING\n");
        $$ = createRecord($1,"string");
    }
    | INT {
        //printf("INT\n");
        $$ = createRecord($1,"int");
    }
    | FLOAT  {
        //printf("FLOAT\n");
        $$ = createRecord($1,"float");
    }
    | DOUBLE  {
        //printf("DOUBLE\n");
        $$ = createRecord($1,"double");
    }
    | TRUE {
        //printf("True\n"); 
        $$ = createRecord("1","bool");
    }
    | FALSE {
        //printf("False\n"); 
        $$ = createRecord("0","bool");
    }
    | CHAR_LITERAL {
        //printf("CHAR\n"); 
        $$ = createRecord($1,"char");
    }
    | ID  { 
        //printf("ID encontrado: %s\n", $1); 
        $$ = createRecord($1,"id");
    }
    ;                

declaration: type ID {
                printf("VAR Declaration\n");

                // Obtém o escopo atual
                char* currentScope = top(scope_stack);

                // Verifica se a variável já foi declarada no escopo atual
                add_symbol_to_scope($2, $1->code, yylineno, get_column());

                // Insere a variável na tabela de símbolos
                setKeyValue(&symbol_table, currentScope, $2, $1->code);

                // Lida com a declaração de strings e outros tipos
                if (strcmp($1->opt1, "type string") == 0) { 
                    char *code = concat($1->code, " * ", $2, "", "");
                    printf("declaration: %s\n", code);
                    $$ = createRecord(code, "");
                    free(code);
                } else {
                    char *code = concat($1->code, " ", $2, "", "");
                    $$ = createRecord(code, "");
                    free(code);
                }

                // Libera memória do record atual
                freeRecord($1);
            }
            ;

initialization: type ID ASSIGN expression {

                printf("VAR Initialization\n");

                char *currentScope = top(scope_stack);

                // Verifica se a variável já foi declarada no escopo atual
                add_symbol_to_scope($2, $1->code, yylineno, get_column());

                // Verifica compatibilidade de tipos entre o tipo da variável e o literal
                check_assignment($2, $4->opt1, yylineno, get_column());

                // Insere a variável na tabela de símbolos
                setKeyValue(&symbol_table, currentScope, $2, $1->code);

                char *code;

                if (strcmp($1->code, "string") == 0) { 
                    code = concat($1->code, " * ", $2, " = ", $4->code); // Strings precisam de alocação especial
                } else {
                    code = concat($1->code, " ", $2, " = ", $4->code); // Demais tipos
                }

                // Remove o `;\n` aqui
                $$ = createRecord(code, "");

                printf("initialization: %s\n", code);

                free(code);
                freeRecord($1);
                freeRecord($4);
            }
            ;



assignment: ID ASSIGN expression {
                printf("DEBUG: Iniciando assignment para '%s'.\n", $1);

                if (!scope_stack) {
                    report_error("Pilha de escopos não inicializada.", yylineno, get_column());
                    $$ = createRecord("", ""); // Retorna um registro vazio
                } else if (!symbol_table) {
                    report_error("Tabela de símbolos não inicializada.", yylineno, get_column());
                    $$ = createRecord("", ""); // Retorna um registro vazio
                } else {
                    char *currentScope = top(scope_stack);

                    if (!currentScope) {
                        report_error("Escopo atual não encontrado.", yylineno, get_column());
                        $$ = createRecord("", ""); // Retorna um registro vazio
                    } else {
                        printf("DEBUG: Escopo atual: '%s'. Verificando variável '%s'.\n", currentScope, $1);

                        // Verifica se a variável foi declarada antes de ser usada
                        check_undefined_variable($1, yylineno, get_column());

                        if (!getValue(symbol_table, currentScope, $1)) {
                            // Caso a variável não seja encontrada, retorna um registro vazio
                            $$ = createRecord("", "");
                        } else {
                            // Obtém o tipo da variável no escopo atual
                            char *type = getValue(symbol_table, currentScope, $1);

                            printf("DEBUG: Variável '%s' encontrada com tipo '%s'.\n", $1, type);

                            // Verifica compatibilidade de tipos
                            check_assignment($1, $3->opt1, yylineno, get_column());

                            // Gera código de atribuição
                            char *code;
                            if (strcmp($3->opt1, "input") == 0) {
                                code = concat($1, "=", $3->code, $1, ")");
                            } else {
                                code = concat($1, "=", $3->code, "", "");
                            }

                            $$ = createRecord(code, "");
                            free(code);
                        }
                    }
                }

                freeRecord($3);
            }
            ;

unary_expression: term {
                    $$ = createRecord($1->code, $1->opt1);
                    freeRecord($1);
                }
                | term INCREMENT {
                    printf("DEBUG: Aplicando incremento em '%s' do tipo '%s'.\n", $1->code, $1->opt1);

                    // Verifica se o tipo é compatível para incremento
                    check_increment($1->opt1, yylineno, get_column());

                    char *code = concat($1->code, "++", "", "", "");
                    printf("DEBUG: Código gerado: %s\n", code);

                    $$ = createRecord(code, $1->opt1);
                    freeRecord($1);
                    free(code);
                }
                | term DECREMENT {
                    printf("DEBUG: Aplicando decremento em '%s' do tipo '%s'.\n", $1->code, $1->opt1);

                    // Verifica se o tipo é compatível para decremento
                    check_increment($1->opt1, yylineno, get_column());

                    char *code = concat($1->code, "--", "", "", "");
                    printf("DEBUG: Código gerado: %s\n", code);

                    $$ = createRecord(code, $1->opt1);
                    freeRecord($1);
                    free(code);
                }
                ;


arithmetic_expression: unary_expression {
                        printf("unary_expression\n");

                        $$ = createRecord($1->code, $1->opt1);
                        freeRecord($1);
                    }
                    | arithmetic_expression arithmetic_operator unary_expression {

                        //TODO: não permitir divisão entre inteiros, o usuário deveria converter para float ou double antes disso
                        //TODO: não permitir operações entre tipos diferentes

                        printf("XXXXXXXXXXXXXXXXXXXXXXXx\n");
                        printf("Type of the unary expression: %s\n", $3->opt1);
                        printf("Code: %s\n", $3->code);

                        char * type;

                        if(strcmp($1->opt1, "id") == 0){
                            printf("Era um id\n");
                            char* currentScope = top(scope_stack);
                            type = getValue(symbol_table, currentScope, $3->code);
                            
                            printf("type recebido: %s\n", type);
                        } else {
                            type = $1->opt1;
                        }

                        printf("Type after checking ids expression: %s\n", type);

                      
                        if (strcmp(type, "float") == 0 && strcmp($2->code, "^") == 0) {

                            char * code = concat("powf(", $1->code, ",", $3->code, ")");
                            printf("arithmetic_expression (float pow): %s\n", code);

                            $$ = createRecord(code,"float");
                            free(code);

                        } else if (strcmp(type, "double") == 0 && strcmp($2->code, "^")  == 0) {

                            char * code = concat("pow(", $1->code, ",", $3->code, ")");
                            printf("arithmetic_expression (double pow): %s\n", code);

                            $$ = createRecord(code,$3->opt1);
                            free(code);

                        } else if(strcmp(type, "string") == 0 && strcmp($3->opt1, "string") == 0) {

                            // TODO: checar se o operador é soma. Do contrário gerar erro
                            // TODO: ver o que acontece quando algum dos lados for uma chamada de função ou id

                            char * code = concat("concat(", $1->code, ",", $3->code, ")");
                            $$ = createRecord(code,"string");
                            free(code);

                        } else if(strcmp(type, "float") == 0 && strcmp($3->opt1, "float") == 0) {

                            char * code = concat("(float)", $1->code, $2->code, $3->code, "");
                            $$ = createRecord(code,"float");
                            free(code);

                        } else if(strcmp(type, "double") == 0 && strcmp($3->opt1, "double") == 0) {

                            char * code = concat("(double)", $1->code, $2->code, $3->code, "");
                            $$ = createRecord(code,"double");
                            free(code);
                        } else {

                           
                            char * code = concat($1->code, $2->code, $3->code, "", "");
                            printf("arithmetic_expression 42: %s\n", code);

                            $$ = createRecord(code,$3->opt1);
                            free(code);

                        }

                        // Checar se é soma de 2 strings. Se for, usar strcat

                        freeRecord($1);
                        freeRecord($2);
                        freeRecord($3);
                       
                    }
                    ;


relational_expression: arithmetic_expression {
                      
                        $$ = createRecord($1->code,$1->opt1);
                        printf("arithmetic_expression: %s\n", $1->code);
                        freeRecord($1);
                    }
                    | relational_expression relational_operator arithmetic_expression {
                        char * code = concat($1->code, $2->code, $3->code, "", "");
                        printf("relational_expression: %s\n", code);
                        $$ = createRecord(code,$3->opt1);
                        freeRecord($1);
                        freeRecord($2);
                        freeRecord($3);
                        free(code);
                    }
                    ;

boolean_expression: relational_expression {
                        $$ = createRecord($1->code, $1->opt1);
                        printf("relational_expression: %s\n", $1->code);
                        freeRecord($1);
                    }
                    | boolean_expression boolean_operator relational_expression {
                        char * code = concat($1->code, $2->code, $3->code, "", "");
                        printf("boolean_expression 1: %s\n", code);
                        $$ = createRecord(code,$3->opt1);
                        freeRecord($1);
                        freeRecord($2);
                        freeRecord($3);
                        free(code);
                    }
                    | NOT boolean_expression {
                        char * code = concat("!", $2->code, "", "", "");
                        printf("boolean_expression 2: %s\n", code);
                        $$ = createRecord(code,$2->opt1);
                        freeRecord($2);
                        free(code);
                    }
                    ;

expression: PAREN_OPEN expression PAREN_CLOSE {
            $$ = createRecord($2->code, $2->opt1);
            //printf("expression 1: %s\n", $2->code);
            freeRecord($2);
        }
        | boolean_expression {
            $$ = createRecord($1->code,$1->opt1);
            //printf("boolean_expression 3: %s\n", $1->code);
            freeRecord($1);
        }
        | function_call {
            //printf("function_call\n");
            //printf("dado recebido aqui: %s\n", $1->opt1);
            $$ = createRecord($1->code,$1->opt1);
            freeRecord($1);
        }
        ;

main: type MAIN PAREN_OPEN PAREN_CLOSE block_statement {
            printf("main\n");
            push("main", &scope_stack);

            char * code = concat($1->code, " main", "(int argc, char *argv[])\n", $5->code, "");
            $$ = createRecord(code,"");
            freeRecord($1);
            freeRecord($5);
            free(code);
        }
        ;

if_statement: IF PAREN_OPEN expression PAREN_CLOSE block_statement {
            printf("if_statement\n");

            char *label_if = generateLabel("if_block");
            char *label_end = generateLabel("end_if");

            char * code = concat("if (", $3->code, ") goto ", label_if, ";\n");
            char * code2 = concat(code, "goto ", label_end, ";\n", "");
            char * code3 = concat(code2, label_if, ":\n", $5->code, "\n");
            char * code4 = concat(code3, label_end, ":", "", "");

            $$ = createRecord(code4, "if_statement");

            free(label_if);
            free(label_end);
            freeRecord($3);
            freeRecord($5);
            free(code);
            free(code2);
            free(code3);
            free(code4);
        }
        | IF PAREN_OPEN expression PAREN_CLOSE block_statement ELSE block_statement {
            printf("if_else_statement\n");

            char *label_if = generateLabel("if_block");
            char *label_else = generateLabel("else_block");
            char *label_end = generateLabel("end_if_else");

            // Código gerado para o if-else
            char * code = concat("if (", $3->code, ") goto ", label_if, ";\n");
            char * code2 = concat(code, "goto ", label_else, ";\n", "");
            char * code3 = concat(code2, label_if, ":\n", $5->code, "\ngoto ");
            char * code4 = concat(code3, label_end, ";\n", label_else, ":\n");
            char * code5 = concat(code4,  $7->code, "\n", label_end, ":");

            $$ = createRecord(code5, "if_else_statement");

            // Liberação de memória
            free(label_if);
            free(label_else);
            free(label_end);
            freeRecord($3);
            freeRecord($5);
            freeRecord($7);
            free(code);
            free(code2);
            free(code3);
            free(code4);
            free(code5);
        }
        ;

while_statement: WHILE PAREN_OPEN expression PAREN_CLOSE block_statement {
    printf("while_statement\n");

    char *label_start = generateLabel("while_start_");
    char *label_end = generateLabel("while_end_");

    char *block_code = $5->code;
    char *treated_block_code = strdup(replace(block_code, "continue", concat("goto ", label_start, ";\n", "", "")));
    char *treated_block_code2 = strdup(replace(treated_block_code, "break", concat("goto ", label_end, ";\n", "", "")));

    char *code = concat(label_start, ":\nif (!(", $3->code, ")) goto ", "");
    char *code2 = concat(code, label_end, ";\n", "", "");
    char *code3 = concat(code2, treated_block_code2, "\ngoto ", label_start, ";\n");
    char *code4 = concat(code3, label_end, ":\n", "", "");

    printf("while_statement: %s\n", code4);

    $$ = createRecord(code4, "while_statement");

    free(label_start);
    free(label_end);
    freeRecord($3);
    freeRecord($5);
    free(code);
    free(code2);
    free(code3);
    free(code4);
    free(treated_block_code);
    free(treated_block_code2);
}
;


for_statement: FOR PAREN_OPEN for_initializer SEMICOLON expression SEMICOLON for_increment PAREN_CLOSE block_statement {
    printf("for_statement\n");

    char *label_start = generateLabel("for_start");
    char *label_body = generateLabel("for_body");
    char *label_end = generateLabel("for_end");

    char *code_init = concat($3->code, ";", "\n", "", "");
    char *code_condition = concat("if (!(", $5->code, ")) goto ", label_end, ";\n");
    char *code_increment = concat($7->code, ";\n", "goto ", label_start, ";\n");
    char *code_body = concat(label_body, ":\n", $9->code, "\n", "");

    char *code = concat(code_init, label_start, ":\n", code_condition, "");
    char *code2 = concat(code, code_body, code_increment, label_end, ":\n");

    $$ = createRecord(code2, "for_statement");

    free(label_start);
    free(label_body);
    free(label_end);
    freeRecord($3);
    freeRecord($5);
    freeRecord($7);
    freeRecord($9);
    free(code);
    free(code2);
    free(code_init);
    free(code_condition);
    free(code_increment);
    free(code_body);
}
;


for_initializer: /* epsilon */  {
                    //printf("for_initializer\n");
                    $$ = createRecord("","for_initializer");
                }    
                | initialization {
                    //printf("for_initializer\n");
                    $$ = createRecord($1->code,$1->opt1);
                    freeRecord($1);
                }
                | assignment {
                    //printf("for_initializer\n");
                    $$ = createRecord($1->code,$1->opt1);
                    freeRecord($1);
                }
                ;    

for_increment: ID INCREMENT {
                //printf("for_increment\n");
                char * code = concat($1, "++", "", "", "");
                $$ = createRecord(code,"");
                free(code);
            }
            | ID DECREMENT {
                //printf("for_decrement\n");
                char * code = concat($1, "--", "", "", "");
                $$ = createRecord(code,"");
                free(code);
            }
            | assignment {
                //printf("for_assignment\n");
                $$ = createRecord($1->code,$1->opt1);
                freeRecord($1);
            }
            ;

parameter_list: /* epsilon */ {
                printf("parameter_list\n");
                $$ = createRecord("","parameter_list");
            }
            | parameter_list_nonempty {
                printf("parameter_list\n");
                $$ = createRecord($1->code,"");
                freeRecord($1);
            }
            ;

parameter_list_nonempty: type ID {
                char * code = concat($1->code, $2, "", "", "");
                printf("parameter_list_nonempty: %s\n", code);
                $$ = createRecord(code,"");
                freeRecord($1);
                free(code);
            }
            |
            type ID COMMA parameter_list_nonempty {
                char * code = concat($1->code, $2, ",", $4->code, "");
                printf("parameter_list_nonempty: %s\n", code);
                $$ = createRecord(code,"");
                freeRecord($1);
                freeRecord($4);
                free(code);
            }
            ;
             
function_declaration: type ID PAREN_OPEN parameter_list PAREN_CLOSE block_statement {
            printf("function_declaration\n");
            char * code = concat($1->code, " ", $2, "(", $4->code);
            char * code2 = concat(code, ")", $6->code, "", "");
            $$ = createRecord(code2,"");
            freeRecord($1);
            freeRecord($4);
            freeRecord($6);
            free(code);
            free(code2);
        }
        ;   



argument_list: /* epsilon */  {
                //printf("argument_list\n");
                $$ = createRecord("","argument_list_empty");
            }
            | argument_list_nonempty {
                //printf("argument_list\n");
                $$ = createRecord($1->code,$1->opt1);
                freeRecord($1);
            }
            ;

argument_list_nonempty: term  {
            //printf("argument_list_nonempty\n");
            $$ = createRecord($1->code,$1->opt1);
            freeRecord($1);
        }
        |term COMMA argument_list_nonempty {
            char * code = concat($1->code, ",", $3->code, "", "");
            //printf("argument_list_nonempty: %s\n", code);
            $$ = createRecord(code,"arguments");
            freeRecord($1);
            freeRecord($3);
            free(code);
        }

function_call: ID PAREN_OPEN argument_list PAREN_CLOSE {
        printf("function_call\n");
        
        if(strcmp($1, "print") == 0) { 

            char* currentScope = top(scope_stack);
            
            char* type = getValue(symbol_table, currentScope, $3->code);

            //TODO: se variável não existir, retornar um erro!

            //printTable(table);

            printf("THE CURRENT SCOPE IS %s\n", currentScope);
            printf("THE TYPE IS: %s\n", type);

            char * code;

            if(strcmp($3->opt1, "id") == 0){
                char * printType = getPrintType(type);
                char * code0 = concat("printf", "(", "\"",printType,"\"");
                code = concat(code0, ",", $3->code, ")", "");
                free(code0);
            } else {
                char * printType = getPrintType($3->opt1);
                char * code0 = concat("printf", "(", "\"",printType,"\"");
                code = concat(code0, ",", $3->code, ")", "");
                free(code0);
            }

            //printf("function_call (achei print): %s\n", code);
            $$ = createRecord(code,"print");
            free(code);

        } else if(strcmp($1, "length") == 0){
            char * code = concat("strlen", "(", $3->code, "", ")");
            //printf("function_call (achei length): %s\n", code);
            $$ = createRecord(code,"length");

        } else if(strcmp($1, "readString") == 0){
            char * code = concat("scanf(\"%s\", ", "","","","");
            $$ = createRecord(code,"input");

        } else if(strcmp($1, "readInt") == 0){
            char * code = concat("scanf(\"%d\", ", "","","","");
            $$ = createRecord(code,"input");

        } else if(strcmp($1, "readFloat") == 0){
            char * code = concat("scanf(\"%f\", ", "","","","");
            $$ = createRecord(code,"input");

        } else if(strcmp($1, "readChar") == 0){
            char * code = concat("scanf(\" %c\", ", "","","","");
            $$ = createRecord(code,"input");

        } else {
            char * code = concat($1, "(", $3->code, ")", ""); 
            $$ = createRecord(code,"");
            free(code);
        }

        freeRecord($3);
    }
    ;


block_statement: BLOCK_BEGIN statement_list SEMICOLON BLOCK_END {
       
        char * code = concat("{\n", $2->code, ";", "\n}", "");
        //printf("block_statement: %s\n", code);
        $$ = createRecord(code,"");
        freeRecord($2);
    }
    ;

return_statement: RETURN expression {
        //printf("return_statement\n");
        char * code = concat("return ", $2->code, "", "", ";");
        $$ = createRecord(code,"");
        freeRecord($2);
        free(code);
    }
    ;

%%

int yyerror(char *msg) {
    fprintf(stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
    return 0;
}

#define EXTENSION "elmr"

char* get_extension(char* pointer, int len) {
    char* substring = malloc(len + 1);
    int i = 0;

    while (i < len) {
        substring[i] = *pointer++;
        i++;
    }

    substring[len] = '\0';
    return substring;
}

int main(int argc, char *argv[]) { 

    scope_stack = createScopeStack();
    symbol_table = createSymbolTable();

    // Verifica se o número de argumentos está correto
    if (argc != 2) {
        printf("Usage: %s <source file>\n", argv[0]);
        return 1;
    }

    // Nome do arquivo de entrada
    char* input_file = argv[1]; 
    char* ext_pointer = strrchr(input_file, '.');

    // Verifica se o arquivo possui extensão válida
    if (!ext_pointer) {
        printf("Invalid source file!\n");
        return 1;
    }

    int ext_len = strlen(input_file) - (ext_pointer - input_file + 1);
    char* ext = get_extension(ext_pointer + 1, ext_len);

    if (strcmp(ext, EXTENSION) != 0) { 
        printf("Invalid source file extension! Expected .%s\n", EXTENSION);
        free(ext);
        return 1;
    }

    free(ext);

    // Abre o arquivo de entrada
    yyin = fopen(input_file, "r");
    if (!yyin) {
        printf("Error: Cannot open file %s\n", input_file);
        return 1;
    }

    // Declara e inicializa a variável global filename
    extern char *filename;
    filename = input_file; // Usa o nome do arquivo fornecido como argumento

    // Inicia o escopo global
    push("global", &scope_stack);

    // Inicia o parsing
    yyparse();  

    // Libera recursos
    destroyStack(&scope_stack);
    destroyTable(&symbol_table);

    fclose(yyin);
    return 0;
}

