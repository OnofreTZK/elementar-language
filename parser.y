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


%type <sValue> term
%type <sValue> unary_expression


%start program

%left OR AND PLUS MINUS MULTIPLY DIVIDE MODULO
%right NOT ASSIGN INCREMENT DECREMENT
%nonassoc EQUALS NOT_EQUAL LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL

%%
program: statement_list SEMICOLON;

statement_list: statement
              | statement_list SEMICOLON statement
              ;

type: TYPE_INT {printf("INT\n");}
    | TYPE_FLOAT {printf("FLOAT\n");}
    | TYPE_CHAR {printf("CHAR\n");}
    | TYPE_BOOL {printf("BOOL\n");}
    | TYPE_STRING {printf("STRING\n");}
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
         | expression
         | SEMICOLON
         ;

term: STRING_LITERAL
    | INT {printf("INT\n");}
    | DECIMAL  {printf("DECIMAL\n");}
    | TRUE {printf("True\n");}
    | FALSE {printf("False\n");}
    | CHAR_LITERAL {printf("CHAR_LITERAL\n");}
    | ID  { printf("ID encontrado: %s\n", $1); $$ = $1;}
    ;                

declaration: type ID                             {printf("VAR Declaration\n");}
            ;  

initialization: type ID ASSIGN expression         {printf("VAR Initialization\n");}
            ;  

assignment: ID ASSIGN expression                  {printf("VAR Assignment\n");}
            ;  

unary_expression: term                                      {printf("term\n");}
                | term INCREMENT {
                    printf("term increment: %s\n", $1);
                    $$ = cat($1, "++", "", "", "");
                }
                | term DECREMENT 
                | INCREMENT unary_expression
                | DECREMENT unary_expression
                ;

arithmetic_expression: unary_expression                      {printf("unary_expression\n");}
                     | arithmetic_expression arithmetic_operator unary_expression
                     ;

relational_expression: arithmetic_expression                  {printf("arithmetic_expression\n");}
                     | relational_expression relational_operator arithmetic_expression
                     ;

boolean_expression: relational_expression                       {printf("relational_expression\n");}
                  | boolean_expression boolean_operator relational_expression {printf("boolean_expression boolean_operator relational_expression\n");}
                  | NOT boolean_expression                       {printf("NOTA boolean_expression\n");}
                  ;

expression: PAREN_OPEN expression PAREN_CLOSE   {printf("(expression)\n");}
          | boolean_expression                  {printf("boolean expression\n");}
          | function_call                       {printf("function_call\n");}
          ;

main: type MAIN PAREN_OPEN PAREN_CLOSE block_statement   {printf("Main function\n");}
        ;


for_statement: FOR PAREN_OPEN for_initializer SEMICOLON expression SEMICOLON for_increment PAREN_CLOSE block_statement {printf("for_statement\n");}
        ;

for_initializer: /* epsilon */      
               | initialization      {printf("initialization\n");}
               | assignment          {printf("assignment\n");}
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

char * cat(char * s1, char * s2, char * s3, char * s4, char * s5){
  int tam;
  char * output;

  tam = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5)+ 1;
  output = (char *) malloc(sizeof(char) * tam);
  
  if (!output){
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }
  
  sprintf(output, "%s%s%s%s%s", s1, s2, s3, s4, s5);
  
  return output;
}
