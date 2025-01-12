%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./src/util.h"
#include "./src/record.h"

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char *yytext;
extern FILE *yyin;

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
%type <rec> main for_statement for_initializer for_increment parameter_list
%type <rec> parameter_list_nonempty function_declaration argument_list argument_list_nonempty
%type <rec> function_call block_statement if_statement while_statement return_statement


%start program

%left OR AND PLUS MINUS MULTIPLY DIVIDE MODULO
%right NOT ASSIGN INCREMENT DECREMENT
%nonassoc EQUALS NOT_EQUAL LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL

%%
program: statement_list SEMICOLON;

statement_list: statement
              | statement_list SEMICOLON statement
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

statement: declaration
         | initialization
         | assignment
         | main
         | if_statement
         | while_statement
         | for_statement
         | return_statement
         | block_statement
         | function_declaration
         | expression
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
                char * code = concat($1->code, $2, "=", $4->code, "");
                $$ = createRecord($2,"");
                freeRecord($1);
                freeRecord($4);
                free(code);
            }
            ;  

assignment: ID ASSIGN expression {
                //printf("Assignment\n");
                //char * code = concat($1, "=", $3->code, "", "");
                //$$ = createRecord(code,"");
                //freeRecord($1);
                //freeRecord($3);
                //free(code);
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
                        printf("arithmetic_expression\n");
                        $$ = createRecord($1->code,"");
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
                        //printf("relational_expression\n");
                        //$$ = createRecord($1->code,"");
                        //freeRecord($1);
                    }
                    | boolean_expression boolean_operator relational_expression {
                        //char * code = concat($1->code, $2->code, $3->code, "", "");
                        //printf("boolean_expression: %s\n", code);
                        //$$ = createRecord(code,"");
                        //freeRecord($1);
                        //freeRecord($2);
                        //freeRecord($3);
                        //free(code);
                    }
                    | NOT boolean_expression {
                        //char * code = concat("!", $1->code, "", "", "");
                        //printf("boolean_expression: %s\n", code);
                        //$$ = createRecord(code,"");
                        //freeRecord($1);
                        //free(code);
                    }
                    ;

expression: PAREN_OPEN expression PAREN_CLOSE {
            //printf("expression\n");
            //$$ = createRecord($2->code,"");
            //freeRecord($2);
        }
        | boolean_expression {
            //printf("boolean_expression\n");
            //$$ = createRecord($1->code,"");
            //freeRecord($1);
        }
        | function_call {
            //printf("function_call\n");
            //$$ = createRecord($1->code,"");
            //freeRecord($1);
        }
        ;

main: type MAIN PAREN_OPEN PAREN_CLOSE block_statement   {printf("Main function\n");}
        ;


for_statement: FOR PAREN_OPEN for_initializer SEMICOLON expression SEMICOLON for_increment PAREN_CLOSE block_statement {printf("for_statement\n");}
        ;

for_initializer: /* epsilon */  {
                    printf("for_initializer\n");
                   
                }    
                | initialization      {printf("initialization\n");}
                | assignment          {printf("assignment\n");}
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

parameter_list: /* epsilon */
              | parameter_list_nonempty
              ;

parameter_list_nonempty: type ID
                       | type ID COMMA parameter_list_nonempty
                       ;
             
function_declaration: type ID PAREN_OPEN parameter_list PAREN_CLOSE block_statement


argument_list: /* epsilon */                                {printf("argument_list\n");}
            | argument_list_nonempty;

argument_list_nonempty: term                                {printf("argument_list_nonempty\n");}
                      |term COMMA argument_list_nonempty 


function_call: ID PAREN_OPEN argument_list PAREN_CLOSE      {printf("function_call\n");}


block_statement: BLOCK_BEGIN statement_list SEMICOLON BLOCK_END;
                

if_statement: IF PAREN_OPEN expression PAREN_CLOSE block_statement
            | IF PAREN_OPEN expression PAREN_CLOSE block_statement ELSE block_statement
            ;

while_statement: WHILE PAREN_OPEN expression PAREN_CLOSE block_statement;

return_statement: RETURN expression;

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
