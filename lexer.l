%{
  #include <stdio.h>  
  #include <string.h>
  #include <stdlib.h>
%}

%%

[ \t\n]+                ;                              
"//".*                  ;
"/*"[^*]*\*+([^/*][^*]*\*+)*"/" ;
"int"                   {printf("TYPE_INT\n");}            
"void"                  {printf("TYPE_VOID\n");}
"const"                 {printf("CONST\n");}
"char"                  {printf("TYPE_CHAR\n");}
"struct"                {printf("STRUCT\n");}
"string"                {printf("TYPE_STRING\n");}
"if"                    {printf("IF\n");}
"else"                  {printf("ELSE\n");}
"while"                 {printf("WHILE\n");}
"return"                {printf("RETURN\n");}
"main"                  {printf("MAIN\n");}
"print"                 {printf("PRINT\n");}
"switch"                {printf("SWITCH\n");}
"for"                   {printf("FOR\n");}
"case"                  {printf("CASE\n");}
"break"                 {printf("BREAK\n");}
"continue"              {printf("CONTINUE\n");}
"{"                     {printf("BLOCK_BEGIN\n");}         
"}"                     {printf("BLOCK_END\n");}
"("                     {printf("PAREN_OPEN\n");}          
")"                     {printf("PAREN_CLOSE\n");}
"["                     {printf("BRACKET_OPEN\n");}        
"]"                     {printf("BRACKET_CLOSE\n");}
";"                     {printf("SEMICOLON\n");}
","                     {printf("COMMA\n");}
"."                     {printf("DOT\n");}
":"                     {printf("COLON\n");}  
"=?"                    {printf("EQUALS\n");}  
"="                     {printf("ASSIGN\n");}                          
"<"                     {printf("LESS_THAN\n");}          
"<="                    {printf("LESS_EQUAL\n");}
">"                     {printf("GREATER_THAN\n");}
">="                    {printf("GREATER_EQUAL\n");}
"!="                    {printf("NOT_EQUAL\n");}
"\+\+"                  {printf("INCREMENT\n");}         
"--"                    {printf("DECREMENT\n");}
"\+"                    {printf("PLUS\n");}                
"-"                     {printf("MINUS\n");}
"\*"                    {printf("MULTIPLY\n");}
"/"                     {printf("DIVIDE\n");}
"%"                     {printf("MODULO\n");}
"&&"                    {printf("AND\n");}                 
"\|\|"                  {printf("OR\n");}
"!"                     {printf("NOT\n");}
\"([^\"\\]|\\.)*\"      {printf("STRING_LITERAL(%s)\n", yytext);}
\'([^\\\']|\\.)\'       {printf("CHAR_LITERAL(%s)\n", yytext);}   
[0-9]+                  {printf("NUMBER(%s)\n", yytext);}      
[a-zA-Z_][a-zA-Z0-9_]*  {printf("ID(%s)\n", yytext);}      
.                       {printf("Invalid character: %s\n", yytext);} 

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif

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

  yylex();  

  fclose(yyin);

  return 0;
}

