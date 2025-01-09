#include <stdio.h>
#include "types.h"
#include "scope_stack.h"

int main() {
    Scope scope;

    push("2", &scope);

    return 0;
}

