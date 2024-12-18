%{
  #include "y.tab.h"
  #include <stdio.h>  
  #include <string.h>
  #include <stdlib.h>

  extern int yyerror (char *msg);
%}

%%

[ \t\n]+                ;                              
"//".*                  ;                              // Single-line comments
"/*"[^*]*\*+([^/*][^*]*\*+)*"/" ;                     // Multi-line comments

"int"                   { printf("Token: TYPE_INT\n"); return(TYPE_INT);} 
"short"                 { printf("Token: TYPE_SHORT\n"); return(TYPE_SHORT);}
"unsigned_int"          { printf("Token: TYPE_UNSIGNED_INT\n"); return(TYPE_UNSIGNED_INT);}           
"float"                 { printf("Token: TYPE_FLOAT\n"); return(TYPE_FLOAT);}    
"double"                { printf("Token: TYPE_DOUBLE\n"); return(TYPE_DOUBLE);}
"long"                  { printf("Token: TYPE_LONG\n"); return(TYPE_LONG);}
"void"                  { printf("Token: TYPE_VOID\n"); return(TYPE_VOID);}
"const"                 { printf("Token: CONST\n"); return(CONST);}
"char"                  { printf("Token: TYPE_CHAR\n"); return(TYPE_CHAR);}
"struct"                { printf("Token: TYPE_STRUCT\n"); return(TYPE_STRUCT);}
"string"                { printf("Token: TYPE_STRING\n"); return(TYPE_STRING);}
"if"                    { printf("Token: IF\n"); return(IF);}
"else"                  { printf("Token: ELSE\n"); return(ELSE);}
"while"                 { printf("Token: WHILE\n"); return(WHILE);}
"return"                { printf("Token: RETURN\n"); return(RETURN);}
"main"                  { printf("Token: MAIN\n"); return(MAIN);}
"print"                 { printf("Token: PRINT\n"); return(PRINT);}
"switch"                { printf("Token: SWITCH\n"); return(SWITCH);}
"for"                   { printf("Token: FOR\n"); return(FOR);}
"case"                  { printf("Token: CASE\n"); return(CASE);}
"break"                 { printf("Token: BREAK\n"); return(BREAK);}
"continue"              { printf("Token: CONTINUE\n"); return(CONTINUE);}
"true"                  { printf("Token: TRUE\n"); return(TRUE);}
"false"                 { printf("Token: FALSE\n"); return(FALSE);}
"=?"                    { printf("Token: EQUALS\n"); return(EQUALS);}  
"<="                    { printf("Token: LESS_EQUAL\n"); return(LESS_EQUAL);}
">="                    { printf("Token: GREATER_EQUAL\n"); return(GREATER_EQUAL);}
"!="                    { printf("Token: NOT_EQUAL\n"); return(NOT_EQUAL);}
"&&"                    { printf("Token: AND\n"); return(AND);}                 
"\|\|"                  { printf("Token: OR\n"); return(OR);}
"="                     { printf("Token: ASSIGN\n"); return(ASSIGN);}                          
"<"                     { printf("Token: LESS_THAN\n"); return(LESS_THAN);}          
">"                     { printf("Token: GREATER_THAN\n"); return(GREATER_THAN);}
"\+"                    { printf("Token: PLUS\n"); return(PLUS);}                
"-"                     { printf("Token: MINUS\n"); return(MINUS);}
"\*"                    { printf("Token: MULTIPLY\n"); return(MULTIPLY);}
"/"                     { printf("Token: DIVIDE\n"); return(DIVIDE);}
"%"                     { printf("Token: MODULO\n"); return(MODULO);}
"!"                     { printf("Token: NOT\n"); return(NOT);}
"\^"                    { printf("Token: EXPONENT\n"); return(EXPONENT);}
"{"                     { printf("Token: BLOCK_BEGIN\n"); return(BLOCK_BEGIN);}         
"}"                     { printf("Token: BLOCK_END\n"); return(BLOCK_END);}
"("                     { printf("Token: PAREN_OPEN\n"); return(PAREN_OPEN);}          
")"                     { printf("Token: PAREN_CLOSE\n"); return(PAREN_CLOSE);}
"["                     { printf("Token: BRACKET_OPEN\n"); return(BRACKET_OPEN);}        
"]"                     { printf("Token: BRACKET_CLOSE\n"); return(BRACKET_CLOSE);}
";"                     { printf("Token: SEMICOLON\n"); return(SEMICOLON);}
","                     { printf("Token: COMMA\n"); return(COMMA);}
"."                     { printf("Token: DOT\n"); return(DOT);}
":"                     { printf("Token: COLON\n"); return(COLON);}
\"([^\"\\]|\\.)*\"      { yylval.sValue = strdup(yytext);
                          printf("Token: STRING_LITERAL\n"); return STRING_LITERAL;} 
\'([^\\\']|\\.)\'       { yylval.cValue = yytext[1];
                          printf("Token: CHAR_LITERAL\n"); return CHAR_LITERAL;}  
-?[0-9]+\.[0-9]+        { yylval.fValue = atof(yytext); 
                          printf("Token: DECIMAL\n"); return DECIMAL;}
-?[0-9]+                { yylval.iValue = atoi(yytext); 
                          printf("Token: INT\n"); return INT;}
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.sValue = strdup(yytext);
                          printf("Token: ID (%s)\n", yytext); return ID;}
.                       { printf("Invalid character: %s\n", yytext); yyerror("Invalid character!");} 

%%

#ifndef yywrap
   int yywrap (void) { return 1; }
#endif

