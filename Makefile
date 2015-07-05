SRC=src/
BIN=bin/

all:
		clear
		mkdir -p bin
		lex -o $(BIN)lex.yy.c $(SRC)lexica.l
		yacc -o $(BIN)y.tab.c -d $(SRC)sintatica.y -vd
		g++ -o $(BIN)glf $(BIN)y.tab.c -lfl
		clear
		./$(BIN)glf < $(SRC)exemplo.foca
