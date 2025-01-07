%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char *yytext;
extern FILE *yyin;
%}

%union {
    int iValue;
    float fValue;
    char cValue;
    char *sValue;
};

%token <sValue> ID STRING_LITERAL
%token <iValue> INT
%token <fValue> DECIMAL
%token <cValue> CHAR_LITERAL
%token TYPE_INT TYPE_VOID CONST TYPE_CHAR TYPE_STRUCT TYPE_STRING TYPE_SHORT 
       TYPE_UNSIGNED_INT TYPE_FLOAT TYPE_DOUBLE TYPE_LONG IF ELSE WHILE RETURN MAIN TYPE_BOOL
       SWITCH FOR CASE BREAK CONTINUE BLOCK_BEGIN BLOCK_END PAREN_OPEN
       PAREN_CLOSE BRACKET_OPEN BRACKET_CLOSE SEMICOLON COMMA DOT EQUALS ASSIGN
       LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL NOT_EQUAL INCREMENT DECREMENT
       PLUS MINUS MULTIPLY DIVIDE MODULO AND OR NOT EXPONENT TRUE FALSE

%start program

%left OR AND PLUS MINUS MULTIPLY DIVIDE MODULO
%right NOT ASSIGN INCREMENT DECREMENT
%nonassoc EQUALS NOT_EQUAL LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL

%%
program: statement_list;

statement_list: statement
              | statement_list statement
              ;

type: TYPE_INT
    | TYPE_FLOAT
    | TYPE_CHAR
    | TYPE_BOOL
    | TYPE_STRING
    ;

boolean_operator: OR
                | AND
                ;

relational_operator: EQUALS 
                   | NOT_EQUAL
                   | LESS_THAN
                   | LESS_EQUAL
                   | GREATER_THAN
                   | GREATER_EQUAL
                   ;

arithmetic_operator: PLUS 
                   | MINUS 
                   | MULTIPLY 
                   | DIVIDE 
                   | MODULO
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
         | expression SEMICOLON
         ;

term: STRING_LITERAL
    | INT
    | DECIMAL
    | TRUE
    | FALSE
    | CHAR_LITERAL
    | ID 
    ;                {printf("ID\n");}

declaration: type ID SEMICOLON;  {printf("VAR Declaration\n");}

initialization: type ID ASSIGN expression SEMICOLON;  {printf("VAR Initialization\n");}

assignment: ID ASSIGN expression SEMICOLON;  {printf("VAR Assignment\n");}

unary_expression: term              {printf("unary_expression\n");}
                | term INCREMENT //Por que term?
                | term DECREMENT 
                | INCREMENT unary_expression
                | DECREMENT unary_expression
                ;

arithmetic_expression: unary_expression         {printf("arithmetic_expression\n");}
                     | arithmetic_expression arithmetic_operator unary_expression
                     ;

relational_expression: arithmetic_expression    {printf("relational_expression\n");}
                     | relational_expression relational_operator arithmetic_expression
                     ;

boolean_expression: relational_expression       {printf("boolean_expression\n");}
                  | boolean_expression boolean_operator relational_expression
                  | NOT boolean_expression
                  ;

expression: PAREN_OPEN expression PAREN_CLOSE       {printf("expression\n");}  
          | boolean_expression                      {printf("boolean expression\n");} 
          ;

main: type MAIN PAREN_OPEN PAREN_CLOSE block_statement   {printf("Main function\n");}

for_statement: FOR PAREN_OPEN for_initializer SEMICOLON expression SEMICOLON for_increment PAREN_CLOSE block_statement;

for_initializer: /* epsilon */      {printf("for_initializer\n");}
               | initialization
               | assignment
               ;

for_increment: ID INCREMENT         {printf("for_increment\n");}
             | ID DECREMENT
             | assignment
             ;

parameter_list: /* epsilon */
              | parameter_list_nonempty
              ;

parameter_list_nonempty: type ID
                       | type ID COMMA parameter_list_nonempty
                       ;
             
function_declaration: type ID PAREN_OPEN parameter_list PAREN_CLOSE block_statement

block_statement: BLOCK_BEGIN statement_list BLOCK_END;

if_statement: IF PAREN_OPEN expression PAREN_CLOSE block_statement
            | IF PAREN_OPEN expression PAREN_CLOSE block_statement ELSE block_statement
            ;

while_statement: WHILE PAREN_OPEN expression PAREN_CLOSE block_statement;

return_statement: RETURN expression SEMICOLON;

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

