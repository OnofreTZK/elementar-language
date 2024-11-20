%{
  #include <stdio.h>  
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

int main(int arcg, char *argv[])
{ 

  yyin = fopen(argv[1], "r");

  yylex();  

  fclose(yyin);

  return 0;
}
