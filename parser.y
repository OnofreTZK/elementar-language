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
	int    iValue; 	/* integer value */
    float  fValue;  /* float value */
	char   cValue; 	/* char value */
	char * sValue;  /* string value */
}

%token <sValue> ID STRING_LITERAL
%token <iValue> INT
%token <fValue> DECIMAL
%token <cValue> CHAR_LITERAL
%token TYPE_INT TYPE_SHORT TYPE_UNSIGNED_INT TYPE_FLOAT TYPE_DOUBLE TYPE_LONG TYPE_VOID CONST
%token TYPE_CHAR TYPE_STRUCT TYPE_STRING
%token IF ELSE WHILE RETURN MAIN PRINT SWITCH FOR CASE BREAK CONTINUE TRUE FALSE
%token EQUALS ASSIGN LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL NOT_EQUAL INCREMENT DECREMENT
%token PLUS MINUS MULTIPLY DIVIDE MODULO AND OR NOT EXPONENT
%token BLOCK_BEGIN BLOCK_END PAREN_OPEN PAREN_CLOSE BRACKET_OPEN BRACKET_CLOSE SEMICOLON COMMA DOT COLON

%start program

%left PLUS MINUS
%left MULTIPLY DIVIDE
%nonassoc LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL EQUALS NOT_EQUAL

%%
program: main_function;

main_function: TYPE_VOID MAIN PAREN_OPEN PAREN_CLOSE block_statement;

block_statement: BLOCK_BEGIN statement_list BLOCK_END;

statement_list: statement
              | statement_list statement;

statement: simple_statement SEMICOLON
         | block_statement
         | if_statement
         | while_statement
         | print_statement SEMICOLON
         | continue_statement SEMICOLON;

simple_statement: declaration
                | assignment;

declaration: type ID
           | type ID ASSIGN expression;

assignment: ID ASSIGN expression;

expression: expression PLUS term
          | expression MINUS term
          | comparison_expression;

comparison_expression: term EQUALS term
                     | term LESS_THAN term
                     | term LESS_EQUAL term
                     | term GREATER_THAN term
                     | term GREATER_EQUAL term
                     | term NOT_EQUAL term;

term: term MULTIPLY factor
    | term DIVIDE factor
    | factor;

factor: PAREN_OPEN expression PAREN_CLOSE
      | ID
      | INT
      | DECIMAL;

type: TYPE_INT
    | TYPE_SHORT
    | TYPE_UNSIGNED_INT
    | TYPE_FLOAT
    | TYPE_DOUBLE
    | TYPE_LONG
    | TYPE_VOID
    | TYPE_CHAR
    | TYPE_STRUCT
    | TYPE_STRING;

if_statement: IF PAREN_OPEN expression PAREN_CLOSE block_statement
            | IF PAREN_OPEN expression PAREN_CLOSE block_statement ELSE block_statement;

while_statement: WHILE PAREN_OPEN expression PAREN_CLOSE block_statement;

print_statement: PRINT PAREN_OPEN expression PAREN_CLOSE;

continue_statement: CONTINUE;

%%
int yyerror(char *msg) {
	fprintf(stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <source file>\n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (!file) {
        printf("Error: Cannot open file %s\n", argv[1]);
        return 1;
    }

    yyin = file;
    yyparse();
    fclose(file);
    return 0;
}

