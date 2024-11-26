# Elementar


Este é um analisador léxico desenvolvido com **Flex** para processar arquivos fonte da linguagem Elementar, com a extensão `.elmr`. 


## Funcionalidades

- **Reconhecimento de tokens:** identifica palavras-chave como `if`, `else`, `for`, operadores aritméticos, lógicos, e outros símbolos.
- **Detecção de literais:** analisa literais de string, caracteres e números inteiros.
- **Validação de arquivos:** verifica se o arquivo de entrada possui a extensão `.elmr`.
- **Gerenciamento de erros:** detecta caracteres inválidos e notifica o usuário.


## Estrutura do Analisador

O analisador é definido por expressões regulares que associam padrões a tokens. Os tokens reconhecidos podem categorizados em:

1. **Palavras-chave:** `int`, `void`, `if`, `else`, `while`, `for`, etc.
2. **Operadores:** `+`, `-`, `*`, `/`, `&&`, `||`, `==`, etc.
3. **Delimitadores:** `{`, `}`, `(`, `)`, `[`, `]`, `;`, `,`.
4. **Identificadores e Literais:** identificadores customizados, strings (`"..."`), caracteres (`'...'`), e números.

## Compilação e execução 

Certifique-se de ter o **Flex** instalado no computador.

Após compilar o analisador léxico, executamos com um código da linguagem para gerar os tokens.


```bash
flex lexer.l

gcc lex.yy.c -o lexer.exe

./lexer.exe ./code-examples/quicksort.elmr

```

## Exemplo

### Entrada

```c
int main() {
    int x = 10;
    if (x > 5) {
        print("Hello, World!");
    }
}
```

### Saída corrrespondente

```
TYPE_INT
MAIN
PAREN_OPEN
PAREN_CLOSE
BLOCK_BEGIN
TYPE_INT
ID(x)
ASSIGN
NUMBER(10)
SEMICOLON
IF
PAREN_OPEN
ID(x)
GREATER_THAN
NUMBER(5)
PAREN_CLOSE
BLOCK_BEGIN
PRINT
PAREN_OPEN
STRING_LITERAL("Hello, World!")
PAREN_CLOSE
SEMICOLON
BLOCK_END
BLOCK_END

```
