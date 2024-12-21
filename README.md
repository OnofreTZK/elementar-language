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

Certifique-se de ter o `flex` e o `bison` instalados no computador.

Gere o executável do compilador e execute com um código:

```bash
# Compilação
make build_compiler

# Execução
./compiler <nome_arquivo>.elmr
```

## Exemplo de entrada

```c
int main() {
    int x = 10;
    if (x > 5) {
        print("Hello, World!");
    }
}
```
