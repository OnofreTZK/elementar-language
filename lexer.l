%{
  #include "y.tab.h"

  #include <stdio.h>  
  #include <string.h>
  #include <stdlib.h>

  extern int yyerror (char *msg);
%}

%%
[\n]                    {yylineno++;}  
[ \t]+                  ;                              
"//".*                  ;
"/*"[^*]*\*+([^/*][^*]*\*+)*"/" ;
"int"                   {return(TYPE_INT);} 
"short"                 {return(TYPE_SHORT);}
"unsigned_int"          {return(TYPE_UNSIGNED_INT);}           
"float"                 {return(TYPE_FLOAT);}    
"double"                {return(TYPE_DOUBLE);}
"long"                  {return(TYPE_LONG);}
"void"                  {return(TYPE_VOID);}
"bool"                  {return(TYPE_BOOL);}
"const"                 {return(CONST);}
"char"                  {return(TYPE_CHAR);}
"struct"                {return(TYPE_STRUCT);}
"string"                {return(TYPE_STRING);}
"if"                    {return(IF);}
"else"                  {return(ELSE);}
"while"                 {return(WHILE);}
"return"                {return(RETURN);}
main                    {return(MAIN);}
"switch"                {return(SWITCH);}
"for"                   {return(FOR);}
"case"                  {return(CASE);}
"break"                 {return(BREAK);}
"continue"              {return(CONTINUE);}
"true"                  {return(TRUE);}
"false"                 {return(FALSE);}
"^"                     {return(EXPONENT);}
"{"                     {return(BLOCK_BEGIN);}         
"}"                     {return(BLOCK_END);}
"("                     {return(PAREN_OPEN);}          
")"                     {return(PAREN_CLOSE);}
"["                     {return(BRACKET_OPEN);}        
"]"                     {return(BRACKET_CLOSE);}
";"                     {return(SEMICOLON);}
","                     {return(COMMA);}
"."                     {return(DOT);}
"=?"                    {return(EQUALS);}  
"="                     {return(ASSIGN);}                          
"<"                     {return(LESS_THAN);}          
"<="                    {return(LESS_EQUAL);}
">"                     {return(GREATER_THAN);}
">="                    {return(GREATER_EQUAL);}
"!="                    {return(NOT_EQUAL);}
"++"                    {return(INCREMENT);}         
"--"                    {return(DECREMENT);}
"\+"                    {return(PLUS);}                
"-"                     {return(MINUS);}
"\*"                    {return(MULTIPLY);}
"/"                     {return(DIVIDE);}
"%"                     {return(MODULO);}
"&&"                    {return(AND);}                 
"\|\|"                  {return(OR);}
"!"                     {return(NOT);}
\"([^\"\\]|\\.)*\"      {yylval.sValue = strdup(yytext);
                         return STRING_LITERAL;} 
\'([^\\\']|\\.)\'       {yylval.sValue = strdup(yytext);
                        return CHAR_LITERAL;}  
-?[0-9]+                {yylval.sValue = strdup(yytext); 
                        return INT;}
-?[0-9]+\.[0-9]+        {yylval.sValue = strdup(yytext); 
                        return DOUBLE;}
-?[0-9]+\.[0-9]+[fF]    { yylval.sValue = strdup(yytext); 
                        return FLOAT; }
[a-zA-Z_][a-zA-Z0-9_]*  {yylval.sValue = strdup(yytext);
                         return ID;}      
.                       {yyerror("Invalid character!");} 

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif
