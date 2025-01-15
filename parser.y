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
            char * final = concat("#include <stdio.h>\n", "#include <string.h>\n", "#include \"./include/strings.h\"\n",$1->code, "");
            freeRecord($1);
            //salva código em arquivo
            saveCode(final, FILENAME);

            const char *executable = PROGRAM_NAME;
            char command[256];

            //TODO melhorar isso aqui ao pegar os imports
            snprintf(command, sizeof(command), "gcc %s ./outputs/include/strings.c -o %s", FILENAME, PROGRAM_NAME);
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

type: TYPE_INT {$$ = createRecord("int","type int");}
    | TYPE_FLOAT {$$ = createRecord("float","type float");}
    | TYPE_CHAR {$$ = createRecord("char","type char");}
    | TYPE_BOOL {$$ = createRecord("short int","type bool");}
    | TYPE_STRING {$$ = createRecord("char","type string");}
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
                printf("main: %s\n", $1->code);
                freeRecord($1);
            }
            | if_statement {
                printf("if_statement\n");
                $$ = createRecord($1->code,"if_statement");
                freeRecord($1);
            }
            | while_statement {
                printf("while_statement\n");
                $$ = createRecord($1->code,"while_statement");
                freeRecord($1);
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
                $$ = createRecord($1->code,$1->opt1);
                printf("block_statement 0: %s\n", $1->code);
                freeRecord($1);
            }
            | function_declaration {
                $$ = createRecord($1->code,"function_declaration");
                printf("function_declaration 0: %s\n", $1->code);
                freeRecord($1);
            }
            | expression {
                $$ = createRecord($1->code,$1->opt1);
                printf("expression: %s\n", $1->code);
                printf("expression 2 (opt): %s\n", $1->opt1);
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
        $$ = createRecord("1","bool");
    }
    | FALSE {
        printf("False\n"); 
        $$ = createRecord("0","bool");
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

                if (strcmp($1->opt1, "type string") == 0) { 

                    char * code = concat($1->code, " * ", $2,"", "");

                    printf("declaration: %s\n", code);

                    $$ = createRecord(code,"");
                    free(code);
                } else {
                    char * code = concat($1->code, $2, "", "", "");
                    $$ = createRecord(code,"");
                    free(code);
                }

                freeRecord($1);
            }
            ;  

initialization: type ID ASSIGN expression {
                printf("VAR Initialization \n");

                char * code;
                char * code2;

                if (strcmp($1->opt1, "type string") == 0) { 
                    //TODO: passar da expressão o tamanho da string
                    //TODO: definir o tamanho da string pela expressão
                    //TODO: é para gerar um erro aqui caso a expressão não seja uma string

                    if(strcmp($4->opt1, "input") == 0){ //Faz a alocação para a string
                        code = concat($1->code, " * ", $2, " = (char *)malloc(100 * sizeof(char));\n", "");
                    } else {
                        code = concat($1->code, " * ", $2, " = ", "");
                    }
                    code2 = concat(code, $4->code, "", "","");

                } else {

                    if(strcmp($4->opt1, "input") == 0){ 
                        code = concat($1->code," ",$2, ";\n ", $4->code);
                    } else {
                       code = concat($1->code," ",$2, " = ", $4->code);
                    }

                    code2 = concat(code, "", "", "", "");
                    $$ = createRecord(code2,"");
                }

                if(strcmp($4->opt1, "input") == 0) {

                    char * code3;
                    if (strcmp($1->opt1, "type string") == 0){
                        code3 = concat(code2, $2, ")", "", "");
                    } else {
                        code3 = concat(code2, "&",$2, ")", "");
                    }
                    $$ = createRecord(code3,"");
                    free(code3);

                } else {
                    $$ = createRecord(code2,"");
                }

                printf("initialization: %s\n", code2);
                
                free(code);
                free(code2);
                freeRecord($1);
                freeRecord($4);
            }
            ;  

assignment: ID ASSIGN expression {
                printf("Assignment\n");

                //Coloca a variável que vai receber o valor do input
                if(strcmp($3->opt1, "input") == 0) {
                    char * code = concat($1, "=", $3->code,$1, ")");
                    free(code);

                } else {
                    char * code = concat($1, "=", $3->code, "", "");
                    $$ = createRecord(code,"");
                    free(code);
                }
                freeRecord($3);               
            }
            ;  

/* 
- Checar tipos para não permitir coisas como ++<string>
*/
unary_expression: term {
                    printf("codigo: %s\n", $1->code);
                    $$ = createRecord($1->code,$1->opt1);
                    freeRecord($1);
                }                                    
                | term INCREMENT {
                    printf("term increment: %s\n", $1->code);
                  
                    char * code = concat($1->code, "++", "", "", "");
                    printf("codigo: %s\n", code);

                    $$ = createRecord(code,$1->opt1);
                    freeRecord($1);
                    free(code);
                }
                | term DECREMENT {
                    printf("term decrement: %s\n", $1->code);

                    char * code = concat($1->code, "--", "", "", "");
                    printf("codigo: %s\n", code);

                    $$ = createRecord(code,$1->opt1);
                    freeRecord($1);
                    free(code);
                }
                ;

arithmetic_expression: unary_expression {
                        printf("unary_expression\n");
                        $$ = createRecord($1->code,$1->opt1);
                        freeRecord($1);
                    }
                    | arithmetic_expression arithmetic_operator unary_expression {

                        printf("AQUIIIIIIIIIII\n");
                        printf("%s\n",$1->opt1);
                        printf("%s\n",$3->opt1);
                        
                        if(strcmp($1->opt1, "string") == 0 && strcmp($3->opt1, "string") == 0) {

                            // TODO: checar se o operador é soma. Do contrário gerar erro
                            // TODO: ver o que acontece quando algum dos lados for uma chamada de função ou id

                            char * code = concat("concat(", $1->code, ",", $3->code, ")");
                            $$ = createRecord(code,"string");
                            free(code);

                        } else {
                           
                            char * code = concat($1->code, $2->code, $3->code, "", "");
                            printf("arithmetic_expression: %s\n", code);

                            $$ = createRecord(code,"");
                            free(code);

                        }

                        // Checar se é soma de 2 strings. Se for, usar strcat

                        freeRecord($1);
                        freeRecord($2);
                        freeRecord($3);
                       
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
            $$ = createRecord($2->code, $2->opt1);
            printf("expression 1: %s\n", $2->code);
            freeRecord($2);
        }
        | boolean_expression {
            $$ = createRecord($1->code,$1->opt1);
            printf("boolean_expression 3: %s\n", $1->code);
            freeRecord($1);
        }
        | function_call {
            printf("function_call\n");
            printf("dado recebido aqui: %s\n", $1->opt1);
            $$ = createRecord($1->code,$1->opt1);
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

    // Gera rótulos únicos para o início e fim do loop
    char *label_start = generateLabel("while_start_");
    char *label_end = generateLabel("while_end_");

    printf("AAAAAAAAAAAAAAAAA");

    // Código gerado para o while
    char *code = concat(label_start, ":\nif (!(", $3->code, ")) goto ", "");

    //printf("%s\n", code);
    //printf("========================\n");

    char *code2 = concat(code, label_end, ";\n", "", "");

    //printf("%s\n", code2);
    //printf("========================\n");

    char *code3 = concat(code2, $5->code, "\ngoto ", label_start, ";\n");

    //printf("%s\n", code3);
    //printf("========================\n");

    char *code4 = concat(code3, label_end, ":\n", "", "");

    printf("%s\n", code4);
    printf("========================\n");

    // Cria o registro do código gerado
    $$ = createRecord(code4, "while_statement");

    // Liberação de memória
    free(label_start);
    free(label_end);
    freeRecord($3);
    freeRecord($5);
    free(code);
    free(code2);
    free(code3);
    free(code4);

    printf("AAAAAAAAAAAAAAAAA");
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
                    $$ = createRecord($1->code,$1->opt1);
                    freeRecord($1);
                }
                | assignment {
                    printf("for_initializer\n");
                    $$ = createRecord($1->code,$1->opt1);
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
            | assignment {
                printf("for_assignment\n");
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
                $$ = createRecord("","argument_list_empty");
            }
            | argument_list_nonempty {
                printf("argument_list\n");
                $$ = createRecord($1->code,$1->opt1);
                freeRecord($1);
            }
            ;

argument_list_nonempty: term  {
            printf("argument_list_nonempty\n");
            $$ = createRecord($1->code,$1->opt1);
            freeRecord($1);
        }
        |term COMMA argument_list_nonempty {
            char * code = concat($1->code, ",", $3->code, "", "");
            printf("argument_list_nonempty: %s\n", code);
            $$ = createRecord(code,"arguments");
            freeRecord($1);
            freeRecord($3);
            free(code);
        }

function_call: ID PAREN_OPEN argument_list PAREN_CLOSE {
        printf("function_call\n");

        if(strcmp($1, "print") == 0) { 

            char * code;
            if(strcmp($3->opt1, "string") == 0){
                code = concat("printf", "(", $3->code, "", ")");
            } else if(strcmp($3->opt1, "int") == 0){
                code = concat("printf", "(\"%d\", ", $3->code, "", ")");
            } else if(strcmp($3->opt1, "decimal") == 0){
                code = concat("printf", "(\"%f\", ", $3->code, "", ")");
            } else if(strcmp($3->opt1, "char") == 0){
                code = concat("printf", "(\"%c\", ", $3->code, "", ")");
            } else {
                //Acredito que aqui que eu printo uma variável
                //TODO: buscar na tabela de simbolos o tipo da variável para que eu possa printar de acordo
                code = concat("printf", "(", $3->code, ")", "");
            }

            printf("function_call (achei print): %s\n", code);
            $$ = createRecord(code,"print");
            free(code);

        } else if(strcmp($1, "length") == 0){
            char * code = concat("strlen", "(", $3->code, "", ")");
            printf("function_call (achei length): %s\n", code);
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
