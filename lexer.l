%{
  #include "y.tab.h"
  #include <stdio.h>  
  #include <string.h>
  #include <stdlib.h>

  extern int yyerror(char *msg);

  int yycolumn = 1; // Rastreia a coluna atual
  int token_length = 0; // Tamanho do token atual
    extern char *filename;
%}

%%

[\n]                    { yylineno++; yycolumn = 1; }  
[ \t]+                  { yycolumn += yyleng; }                              
"//".*                  { /* Comentário de linha ignorado */ }
"/*"[^*]*\*+([^/*][^*]*\*+)*"/" { /* Comentário de bloco ignorado */ }
"int"                   { yycolumn += yyleng; return(TYPE_INT); } 
"short"                 { yycolumn += yyleng; return(TYPE_SHORT); }
"unsigned_int"          { yycolumn += yyleng; return(TYPE_UNSIGNED_INT); }           
"float"                 { yycolumn += yyleng; return(TYPE_FLOAT); }    
"double"                { yycolumn += yyleng; return(TYPE_DOUBLE); }
"long"                  { yycolumn += yyleng; return(TYPE_LONG); }
"void"                  { yycolumn += yyleng; return(TYPE_VOID); }
"bool"                  { yycolumn += yyleng; return(TYPE_BOOL); }
"const"                 { yycolumn += yyleng; return(CONST); }
"char"                  { yycolumn += yyleng; return(TYPE_CHAR); }
"struct"                { yycolumn += yyleng; return(TYPE_STRUCT); }
"string"                { yycolumn += yyleng; return(TYPE_STRING); }
"if"                    { yycolumn += yyleng; return(IF); }
"else"                  { yycolumn += yyleng; return(ELSE); }
"while"                 { yycolumn += yyleng; return(WHILE); }
"return"                { yycolumn += yyleng; return(RETURN); }
main                    { yycolumn += yyleng; return(MAIN); }
"switch"                { yycolumn += yyleng; return(SWITCH); }
"for"                   { yycolumn += yyleng; return(FOR); }
"case"                  { yycolumn += yyleng; return(CASE); }
"break"                 { yycolumn += yyleng; return(BREAK); }
"continue"              { yycolumn += yyleng; return(CONTINUE); }
"true"                  { yycolumn += yyleng; return(TRUE); }
"false"                 { yycolumn += yyleng; return(FALSE); }
"^"                     { yycolumn += yyleng; return(EXPONENT); }
"{"                     { yycolumn += yyleng; return(BLOCK_BEGIN); }         
"}"                     { yycolumn += yyleng; return(BLOCK_END); }
"("                     { yycolumn += yyleng; return(PAREN_OPEN); }          
")"                     { yycolumn += yyleng; return(PAREN_CLOSE); }
"["                     { yycolumn += yyleng; return(BRACKET_OPEN); }        
"]"                     { yycolumn += yyleng; return(BRACKET_CLOSE); }
";"                     { yycolumn += yyleng; return(SEMICOLON); }
","                     { yycolumn += yyleng; return(COMMA); }
"."                     { yycolumn += yyleng; return(DOT); }
"=?"                    { yycolumn += yyleng; return(EQUALS); }  
"="                     { yycolumn += yyleng; return(ASSIGN); }                          
"<"                     { yycolumn += yyleng; return(LESS_THAN); }          
"<="                    { yycolumn += yyleng; return(LESS_EQUAL); }
">"                     { yycolumn += yyleng; return(GREATER_THAN); }
">="                    { yycolumn += yyleng; return(GREATER_EQUAL); }
"!="                    { yycolumn += yyleng; return(NOT_EQUAL); }
"++"                    { yycolumn += yyleng; return(INCREMENT); }         
"--"                    { yycolumn += yyleng; return(DECREMENT); }
"\+"                    { yycolumn += yyleng; return(PLUS); }                
"-"                     { yycolumn += yyleng; return(MINUS); }
"\*"                    { yycolumn += yyleng; return(MULTIPLY); }
"/"                     { yycolumn += yyleng; return(DIVIDE); }
"%"                     { yycolumn += yyleng; return(MODULO); }
"&&"                    { yycolumn += yyleng; return(AND); }                 
"\|\|"                  { yycolumn += yyleng; return(OR); }
"!"                     { yycolumn += yyleng; return(NOT); }
\"([^\"\\]|\\.)*\"      { yylval.sValue = strdup(yytext);
                          yycolumn += yyleng; return STRING_LITERAL; } 
\'([^\\\']|\\.)\'       { yylval.sValue = strdup(yytext);
                          yycolumn += yyleng; return CHAR_LITERAL; }  
-?[0-9]+                { yylval.sValue = strdup(yytext); 
                          yycolumn += yyleng; return INT; }
-?[0-9]+\.[0-9]+        { yylval.sValue = strdup(yytext); 
                          yycolumn += yyleng; return DOUBLE; }
-?[0-9]+\.[0-9]+[fF]    { yylval.sValue = strdup(yytext); 
                          yycolumn += yyleng; return FLOAT; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.sValue = strdup(yytext);
                          yycolumn += yyleng; return ID; }      
.                       { 
                          fprintf(stderr, "%s-%d:%d: Erro: caractere inválido '%s'\n", 
                                  filename, yylineno, yycolumn, yytext); 
                          yycolumn += yyleng; 
                          return -1; 
                        }

%%

#ifndef yywrap
int yywrap (void) { return 1; }
#endif

int get_column() {
    return yycolumn;
}

