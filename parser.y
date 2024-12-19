%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;
extern FILE *yyin;
%}

%union {
	int    iValue; 	/* integer value */
  float  fValue;  /* float value */
	char   cValue; 	/* char value */
	char * sValue;  /* string value */
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

/*
%type <sValue> logic_expression logical_term logical_factor
%type <sValue> comparison_operator unary_operator assignment_operator
%type <sValue> expression first_level_expression second_level_expression third_level_expression primary_expression
%type <sValue> statement block_statement if_statement while_statement for_statement return_statement
%type <sValue> declaration assignment simple_assignment unary_assignment
%type <sValue> type value
*/

%%
/* Símbolo inicial */
program: statement_list                     {printf("programa\n");}
       ;

statement_list: statement                  {printf("statement_list\n");}
              | statement_list statement   
              ;

statement: declaration  {printf("statement\n");}
         | assignment
         | initialization  
         | if_statement
         | while_statement
         | for_statement
         | return_statement
         | block_statement
         | expression SEMICOLON
         | SEMICOLON
         | function_call
         ;

initialization: type ID ASSIGN expression SEMICOLON {printf("initialization\n");}  

block_statement: BLOCK_BEGIN statement_list BLOCK_END  {printf("block statement\n");}
               ;

if_statement: IF PAREN_OPEN logic_expression PAREN_CLOSE block_statement
            | IF PAREN_OPEN logic_expression PAREN_CLOSE block_statement ELSE block_statement
            ;

return_statement: RETURN expression SEMICOLON
                ;

logic_expression: logical_term
                | logic_expression OR logical_term
                ;

logical_term: logical_factor
            | logical_term AND logical_factor
            ;

logical_factor: comparison_expression
              | NOT logical_factor
              ;

value: STRING_LITERAL   {printf("value\n");}  
       | INT
       | DECIMAL
       | logical_value
       | CHAR_LITERAL
       | ID
       ;

logical_value: TRUE   {printf("logical value\n");}  
             | FALSE
             ;

comparison_expression: value comparison_operator value    {printf("comparison_expression\n");}  
                     ;

comparison_operator: EQUALS
                   | NOT_EQUAL
                   | LESS_THAN
                   | LESS_EQUAL
                   | GREATER_THAN
                   | GREATER_EQUAL
                   ;

while_statement: WHILE PAREN_OPEN logic_expression PAREN_CLOSE block_statement
               ;

for_statement: FOR PAREN_OPEN assignment SEMICOLON expression SEMICOLON assignment PAREN_CLOSE block_statement
             ;


parameter_list:                             {printf("parameter_list\n");}
    /* vazio */                            
  | parameter                              
  | parameter_list COMMA parameter        
  ;

parameter:                                {printf("parameter\n");}
    type ID
  ;

main_function: TYPE_INT MAIN PAREN_OPEN PAREN_CLOSE block_statement {printf("main_function\n");}


declaration: type ID SEMICOLON            {printf("declaration\n");}  
           | CONST type ID SEMICOLON
           | main_function
           | type ID PAREN_OPEN parameter_list PAREN_CLOSE block_statement
           ;

assignment: simple_assignment              {printf("assignment\n");}  
          | function_assignment
          | unary_assignment
          ;

function_assignment: ID ASSIGN function_call SEMICOLON
                  ;

simple_assignment: ID ASSIGN expression SEMICOLON {printf("simple assignment\n");}  
                 ;

unary_assignment: ID unary_operator
                | unary_operator ID
                | MULTIPLY ASSIGN
                | DIVIDE ASSIGN
                | PLUS ASSIGN
                | MINUS ASSIGN
                ;

unary_operator: INCREMENT
              | DECREMENT
              ;

type: TYPE_VOID
    | TYPE_CHAR
    | TYPE_SHORT
    | TYPE_INT
    | TYPE_BOOL
    | TYPE_LONG
    | TYPE_FLOAT
    | TYPE_DOUBLE
    | TYPE_STRING
    | TYPE_UNSIGNED_INT
    | TYPE_STRUCT
    | type BRACKET_OPEN BRACKET_CLOSE
    ;


expression: first_level_expression
          | logic_expression
          ;

argument_list: /* Nada */ 
              | value                                {printf("argument_list\n");}
              | argument_list COMMA value

function_call: ID PAREN_OPEN argument_list PAREN_CLOSE  {printf("function_call\n");}


first_level_expression: second_level_expression                                   {printf("first level expression\n");}
                      | first_level_expression PLUS second_level_expression
                      | first_level_expression MINUS second_level_expression
                      ;

second_level_expression: third_level_expression                                    {printf("second level expression\n");}
                       | second_level_expression MULTIPLY third_level_expression
                       | second_level_expression DIVIDE third_level_expression
                       | second_level_expression MODULO third_level_expression
                       ;

third_level_expression: primary_expression                                         {printf("third level expression\n");} 
                      | primary_expression EXPONENT third_level_expression
                      ;

primary_expression: value                                                          {printf("primary expression\n");} 
                  | PAREN_OPEN expression PAREN_CLOSE
                  ;
%%

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}

#define EXTENSION "elmr" 

char* get_extension(char* pointer, int len)
{
  char* substring = malloc(len + 1);
  int i = 0;
  
  while (i < len) {
    substring[i] = *pointer++;
    i++;
  }

  substring[len] = '\0';

  return substring;
}

int main(int argc, char *argv[])
{ 
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

