%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./src/util.h"
#include "./src/record.h"
#include "./src/file_save.h"

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char *yytext;
extern FILE *yyin;

#define FILENAME "./outputs/output.c"
#define PROGRAM_NAME "./outputs/program"

%}

%union {
	char * sValue; 
	struct record * rec;
 };


%token <sValue> ID STRING_LITERAL INT DECIMAL CHAR_LITERAL

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

//Salvar programa em arquivo aqui
program: statement_list SEMICOLON {
            printf("program\n");
            char * final = concat("#include <stdio.h>\n", $1->code, "", "", "");
            freeRecord($1);
            //salva código em arquivo
            saveCode(final, FILENAME);

            const char *executable = PROGRAM_NAME;
            char command[256];
            snprintf(command, sizeof(command), "gcc -o %s %s", executable, FILENAME);
            printf("Compilando o código com o comando: %s\n", command);

            int result = system(command);
            if (result == 0) {
                printf("Código compilado com sucesso! Executável gerado: %s\n", executable);
            } else {
                fprintf(stderr, "Erro ao compilar o código. Verifique o arquivo '%s' para detalhes.\n", FILENAME);
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

type: TYPE_INT {$$ = createRecord("int","type");}
    | TYPE_FLOAT {$$ = createRecord("float","type");}
    | TYPE_CHAR {$$ = createRecord("char","type");}
    | TYPE_BOOL {$$ = createRecord("bool","type");}
    | TYPE_STRING {$$ = createRecord("string","type");}
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
                        $$ = createRecord("=?","operator");
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
                $$ = createRecord($1->code,"");
                printf("assignment: %s\n", $1->code);
                freeRecord($1);
            }
            | main {
                $$ = createRecord($1->code,"main");
                printf("main: %s\n", $1->code);
                freeRecord($1);
            }
            | if_statement {
                printf("if_statement\n");
                $$ = createRecord("TODO","if_statement");
            }
            | while_statement {
                printf("while_statement\n");
                $$ = createRecord("TODO","while_statement");
            }
            | for_statement {
                printf("for_statement\n");
                $$ = createRecord("TODO","for_statement");
            }
            | return_statement {
                $$ = createRecord($1->code,"");
                printf("return_statement: %s\n", $1->code);
                freeRecord($1);
            }
            | block_statement {
                $$ = createRecord($1->code,"");
                printf("block_statement 0: %s\n", $1->code);
                freeRecord($1);
            }
            | function_declaration {
                $$ = createRecord($1->code,"function_declaration");
                printf("function_declaration 0: %s\n", $1->code);
                freeRecord($1);
            }
            | expression {
                $$ = createRecord($1->code,"");
                printf("expression: %s\n", $1->code);
                freeRecord($1);
            }
            | SEMICOLON {
                printf("SEMICOLON\n");
                $$ = createRecord("","semicolon");
            }
         ;

term: STRING_LITERAL {
        printf("STRING\n");
        $$ = createRecord($1,"string");
    }
    | INT {
        printf("INT\n");
        $$ = createRecord($1,"int");
    }
    | DECIMAL  {
        printf("DECIMAL\n");
        $$ = createRecord($1,"decimal");
    }
    | TRUE {
        printf("True\n"); 
        $$ = createRecord("true","bool");
    }
    | FALSE {
        printf("False\n"); 
        $$ = createRecord("false","bool");
    }
    | CHAR_LITERAL {
        printf("CHAR\n"); 
        $$ = createRecord($1,"char");
    }
    | ID  { 
        printf("ID encontrado: %s\n", $1); 
        $$ = createRecord($1,"id");
    }
    ;                

declaration: type ID {
                printf("VAR Declaration\n");
                char * code = concat($1->code, $2, "", "", "");
                $$ = createRecord(code,"");
                freeRecord($1);
                free(code);
            }
            ;  

initialization: type ID ASSIGN expression {
                printf("VAR Initialization\n");
                char * code = concat($1->code," ",$2, " = ", $4->code);
                $$ = createRecord(code,"");
                freeRecord($1);
                freeRecord($4);
                free(code);
            }
            ;  

assignment: ID ASSIGN expression {
                printf("Assignment\n");
                char * code = concat($1, "=", $3->code, "", "");
                $$ = createRecord(code,"");
                freeRecord($3);
                free(code);
            }
            ;  


/* 
- Checar tipos para não permitir coisas como ++<string>
*/
unary_expression: term {
                    printf("codigo: %s\n", $1->code);
                    $$ = createRecord($1->code,"");
                    freeRecord($1);
                }                                    
                | term INCREMENT {
                    printf("term increment: %s\n", $1->code);
                  
                    char * code = concat($1->code, "++", "", "", "");
                    printf("codigo: %s\n", code);

                    freeRecord($1);
                    $$ = createRecord(code,"");
                    free(code);
                }
                | term DECREMENT {
                    printf("term decrement: %s\n", $1->code);

                    char * code = concat($1->code, "--", "", "", "");
                    printf("codigo: %s\n", code);

                    freeRecord($1);
                    $$ = createRecord(code,"");
                    free(code);
                }
                ;

arithmetic_expression: unary_expression {
                        printf("unary_expression\n");
                        $$ = createRecord($1->code,"");
                        freeRecord($1);
                    }
                    | arithmetic_expression arithmetic_operator unary_expression {
                        char * code = concat($1->code, $2->code, $3->code, "", "");
                        printf("arithmetic_expression: %s\n", code);
                        $$ = createRecord(code,"");
                        freeRecord($1);
                        freeRecord($2);
                        freeRecord($3);
                        free(code);
                    }
                    ;

relational_expression: arithmetic_expression {
                      
                        $$ = createRecord($1->code,"");
                        printf("arithmetic_expression: %s\n", $1->code);
                        freeRecord($1);
                    }
                    | relational_expression relational_operator arithmetic_expression {
                        char * code = concat($1->code, $2->code, $3->code, "", "");
                        printf("relational_expression: %s\n", code);
                        $$ = createRecord(code,"");
                        freeRecord($1);
                        freeRecord($2);
                        freeRecord($3);
                        free(code);
                    }
                    ;

boolean_expression: relational_expression {
                        $$ = createRecord($1->code,"");
                        printf("relational_expression: %s\n", $1->code);
                        freeRecord($1);
                    }
                    | boolean_expression boolean_operator relational_expression {
                        char * code = concat($1->code, $2->code, $3->code, "", "");
                        printf("boolean_expression 1: %s\n", code);
                        $$ = createRecord(code,"");
                        freeRecord($1);
                        freeRecord($2);
                        freeRecord($3);
                        free(code);
                    }
                    | NOT boolean_expression {
                        char * code = concat("!", $2->code, "", "", "");
                        printf("boolean_expression 2: %s\n", code);
                        $$ = createRecord(code,"");
                        freeRecord($2);
                        free(code);
                    }
                    ;

expression: PAREN_OPEN expression PAREN_CLOSE {
            $$ = createRecord($2->code,"");
            printf("expression 1: %s\n", $2->code);
            freeRecord($2);
        }
        | boolean_expression {
            $$ = createRecord($1->code,"");
            printf("boolean_expression 3: %s\n", $1->code);
            freeRecord($1);
        }
        | function_call {
            printf("function_call\n");
            $$ = createRecord($1->code,"");
            freeRecord($1);
        }
        ;

main: type MAIN PAREN_OPEN PAREN_CLOSE block_statement {
            printf("main\n");
            char * code = concat($1->code, " main", "(int argc, char *argv[])\n", $5->code, "");
            $$ = createRecord(code,"");
            freeRecord($1);
            freeRecord($5);
            free(code);
        }
        ;


// Utilizar goto?
if_statement: IF PAREN_OPEN expression PAREN_CLOSE block_statement {
                printf("if_statement\n");
              
            }
            | IF PAREN_OPEN expression PAREN_CLOSE block_statement ELSE block_statement {
                 printf("if_else_statement\n");
            }
            ;

// Utilizar goto para implementar o while
while_statement: WHILE PAREN_OPEN expression PAREN_CLOSE block_statement {
                    printf("while_statement\n");

                }
                ;


for_statement: FOR PAREN_OPEN for_initializer SEMICOLON expression SEMICOLON for_increment PAREN_CLOSE block_statement {printf("for_statement\n");}
        ;

for_initializer: /* epsilon */  {
                    printf("for_initializer\n");
                    $$ = createRecord("","for_initializer");
                }    
                | initialization {
                    printf("for_initializer\n");
                    $$ = createRecord($1->code,"");
                    freeRecord($1);
                }
                | assignment {
                    printf("for_initializer\n");
                    $$ = createRecord($1->code,"");
                    freeRecord($1);
                }
                ;    

for_increment: ID INCREMENT {
                printf("for_increment\n");
                char * code = concat($1, "++", "", "", "");
                $$ = createRecord(code,"");
                free(code);
            }
            | ID DECREMENT {
                printf("for_decrement\n");
                char * code = concat($1, "--", "", "", "");
                $$ = createRecord(code,"");
                free(code);
            }
            | assignment
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
                //Error
                //$$ = createRecord(code,"");
                freeRecord($1);
                free(code);
            }
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
            char * code = concat($1->code, $2, "(", $4->code, ")");
            char * code2 = concat(code, $6->code, "", "", "");
            $$ = createRecord(code,"");
            freeRecord($1);
            freeRecord($4);
            freeRecord($6);
            free(code);
            free(code2);
        }
        ;   



argument_list: /* epsilon */  {
                printf("argument_list\n");
                $$ = createRecord("","argument_list");
            }
            | argument_list_nonempty {
                printf("argument_list\n");
                $$ = createRecord($1->code,"");
                freeRecord($1);
            }
            ;

argument_list_nonempty: term  {
            printf("argument_list_nonempty\n");
            $$ = createRecord($1->code,"");
            freeRecord($1);
        }
        |term COMMA argument_list_nonempty {
            char * code = concat($1->code, ",", $3->code, "", "");
            printf("argument_list_nonempty: %s\n", code);
            $$ = createRecord(code,"");
            freeRecord($1);
            freeRecord($3);
            free(code);
        }

function_call: ID PAREN_OPEN argument_list PAREN_CLOSE {
        printf("function_call\n");
        char * code = concat($1, "(", $3->code, ")", "");
        $$ = createRecord(code,"");
        freeRecord($3);
        free(code);
    }

block_statement: BLOCK_BEGIN statement_list SEMICOLON BLOCK_END {
       
        char * code = concat("{\n", $2->code, ";", "\n}", "");
        printf("block_statement: %s\n", code);
        $$ = createRecord(code,"");
        freeRecord($2);
    }
    ;

return_statement: RETURN expression {
        printf("return_statement\n");
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
    if (argc != 2) {
        printf("Usage: %s <source file>\n", argv[0]);
        return 1;
    }

    char* input_file = argv[1]; 
    char* ext_pointer = strrchr(input_file, '.');

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

    yyin = fopen(input_file, "r");
    if (!yyin) {
        printf("Error: Cannot open file %s\n", input_file);
        return 1;
    }

    yyparse();  

    fclose(yyin);
    return 0;
}
