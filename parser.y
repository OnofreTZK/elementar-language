%{
#define YYDEBUG 1
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
PLUS MINUS MULTIPLY DIVIDE MODULO AND OR NOT EXPONENT TRUE FALSE DEFAULT COLON

%start program

%precedence OR
%precedence AND
%precedence EQUALS NOT_EQUAL LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL
%precedence PLUS MINUS
%precedence MULTIPLY DIVIDE MODULO
%right NOT

%%
/* Grammar rules */
program: statement_list;

statement_list: statement
              | statement_list statement;

statement: if_statement
         | while_statement
         | for_statement
         | return_statement
         | block_statement
         | switch_statement
         | expression SEMICOLON
         | SEMICOLON
         | initialization
         
         | declaration;

initialization: type ID ASSIGN expression SEMICOLON;

block_statement: BLOCK_BEGIN statement_list BLOCK_END
               | BLOCK_BEGIN BLOCK_END;

if_statement: IF PAREN_OPEN expression PAREN_CLOSE block_statement
            | IF PAREN_OPEN expression PAREN_CLOSE block_statement ELSE block_statement;

return_statement: RETURN expression SEMICOLON;

switch_statement: SWITCH PAREN_OPEN expression PAREN_CLOSE BLOCK_BEGIN case_list default_clause BLOCK_END;

case_list: case_clause
         | case_list case_clause;

case_clause: CASE term COLON statement_list BREAK SEMICOLON;

default_clause: DEFAULT COLON statement_list
              | /* empty */;

expression: simple_expression
          | simple_expression boolean_operator expression
          | NOT expression;

simple_expression: term
                 | function_call;

term: STRING_LITERAL
    | INT
    | DECIMAL
    | TRUE
    | FALSE
    | CHAR_LITERAL
    | ID;

boolean_operator: EQUALS
                | NOT_EQUAL
                | LESS_THAN
                | LESS_EQUAL
                | GREATER_THAN
                | GREATER_EQUAL
                | AND
                | OR;

while_statement: WHILE PAREN_OPEN expression PAREN_CLOSE block_statement;

for_statement: FOR PAREN_OPEN assignment SEMICOLON expression SEMICOLON assignment PAREN_CLOSE block_statement;

parameter_list: 
              | parameter_list_opt;

parameter_list_opt: parameter
                  | parameter COMMA parameter_list_opt;

parameter: type ID;

main_function: TYPE_INT MAIN PAREN_OPEN PAREN_CLOSE block_statement;

declaration: type ID SEMICOLON
           | CONST type ID SEMICOLON
           | main_function
           | type ID PAREN_OPEN parameter_list PAREN_CLOSE block_statement;

assignment: ID assignment_operator expression SEMICOLON
	   | type ID ASSIGN expression SEMICOLON;

assignment_operator: ASSIGN
                   | MULTIPLY ASSIGN
                   | DIVIDE ASSIGN
                   | PLUS ASSIGN
                   | MINUS ASSIGN;

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
    | type BRACKET_OPEN BRACKET_CLOSE;

function_call: ID PAREN_OPEN parameter_list PAREN_CLOSE;
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

