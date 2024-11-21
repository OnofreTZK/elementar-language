%{
  #include <stdio.h>  
  #include <string.h>
%}

%%
[ \t\n]+                ;                               
"int"                   {printf("TYPE_INT\n");}            
"void"                  {printf("TYPE_VOID\n");}
"null"                  {printf("NULL\n");}
"if"                    {printf("IF\n");}
"else"                  {printf("ELSE\n");}
"while"                 {printf("WHILE\n");}
"return"                {printf("RETURN\n");}
"main"                  {printf("MAIN\n");}
"length"                {printf("LENGTH\n");}              
"print"                 {printf("PRINT\n");}
"["                     {printf("BRACKET_OPEN\n");}        
"]"                     {printf("BRACKET_CLOSE\n");}
"{"                     {printf("BLOCK_BEGIN\n");}         
"}"                     {printf("BLOCK_END\n");}
"("                     {printf("PAREN_OPEN\n");}          
")"                     {printf("PAREN_CLOSE\n");}
"\\["                   {printf("LIST_START\n");}           
"\\]"                   {printf("LIST_END\n");}
","                     {printf("COMMA\n");}               
";"                     {printf("SEMICOLON\n");}
"\."                    {printf("COLON\n");}         
"="                     {printf("ASSIGN\n");}              
"=?"                    {printf("EQUALS\n");}              
"<"                     {printf("LESS_THAN\n");}          
"<="                    {printf("LESS_EQUAL\n");}
">"                     {printf("GREATER_THAN\n");}
">="                    {printf("GREATER_EQUAL\n");}
"=="                    {printf("EQUALITY\n");}            
"!="                    {printf("NOT_EQUAL\n");}
"\+"                    {printf("PLUS\n");}                
"-"                     {printf("MINUS\n");}
"\*"                    {printf("MULTIPLY\n");}
"/"                     {printf("DIVIDE\n");}
"%"                     {printf("MODULO\n");}
"&&"                    {printf("AND\n");}                 
"\|\|"                  {printf("OR\n");}
"!"                     {printf("NOT\n");}
"int\\[\\]"             {printf("TYPE_INT_ARRAY\n");} 
"-?[0-9]+(\.[0-9]+)?"   {printf("FLOAT(%s)\n", yytext);}
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
  char* substring = malloc(len + 1);;
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
  // This value will be changed once we add the yacc file input
  if (argc != 2) {
    printf("Wrong execution! Please provide a source code file and nothing more.\n");
    return 1;
  }

  char* input_file = argv[1]; 

  char* ext_pointer = strrchr(input_file, '.');
  
  int ext_len = strlen(input_file) - (ext_pointer - input_file + 1);

  char* ext = get_extension(ext_pointer+1, ext_len);

  if (strcmp(ext, EXTENSION) != 0) { 
    printf("Invalid source file!\n");
    free(ext);
    return 1;
  }

  free(ext);

  yyin = fopen(input_file, "r");

  yylex();  

  fclose(yyin);

  return 0;
}
