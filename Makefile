.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

help:
	@echo "$$(tput bold)Commands:$$(tput sgr0)";echo;
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s%s\n", $$1, $$2}'

build_compiler:
	@flex lexer.l
	@bison parser.y -o y.tab.c -d -v -g
	@gcc lex.yy.c y.tab.c src/util.c src/record.c -o compiler

clear_files:
	@rm -rf lex.yy.c y.gv y.output y.tab.c y.tab.h compiler
