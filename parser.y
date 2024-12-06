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
	char   cValue; 	/* char value */
	char * sValue;  /* string value */
	};

%token <sValue> ID STRING_LITERAL
%token <iValue> NUMBER
%token <cValue> CHAR_LITERAL
%token TYPE_INT TYPE_VOID CONST TYPE_CHAR STRUCT TYPE_STRING IF ELSE WHILE RETURN MAIN
PRINT SWITCH FOR CASE BREAK CONTINUE BLOCK_BEGIN BLOCK_END PAREN_OPEN
PAREN_CLOSE BRACKET_OPEN BRACKET_CLOSE SEMICOLON COMMA DOT COLON EQUALS ASSIGN
LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL NOT_EQUAL INCREMENT DECREMENT
PLUS MINUS MULTIPLY DIVIDE MODULO AND OR NOT

%start prog

%type <sValue> stm

%%
prog : stmlist {} 
	 ;

stm : ID ASSIGN ID {printf("%s <- %s \n",$1, $3);}
    ;
	
stmlist : stm						{}
		| stm	stmlist				{}
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

