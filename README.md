# Elementar

## Executar o analisador lexico

```bash
flex lexer.l

gcc lex.yy.c -o lexer.exe

./lexer.exe ./code-examples/quicksort.elmr

```