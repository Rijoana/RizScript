CC = gcc
LEX = flex
YACC = bison

TARGET = rizscript
SRC_DIR = src

all: $(TARGET)

$(TARGET): $(SRC_DIR)/lex.yy.c $(SRC_DIR)/parser.tab.c
	$(CC) $(SRC_DIR)/parser.tab.c $(SRC_DIR)/lex.yy.c -o $(TARGET) -lfl

$(SRC_DIR)/parser.tab.c $(SRC_DIR)/parser.tab.h: $(SRC_DIR)/parser.y
	$(YACC) -d $(SRC_DIR)/parser.y -o $(SRC_DIR)/parser.tab.c

$(SRC_DIR)/lex.yy.c: $(SRC_DIR)/lexer.l $(SRC_DIR)/parser.tab.h
	$(LEX) -o $(SRC_DIR)/lex.yy.c $(SRC_DIR)/lexer.l

clean:
	rm -f $(TARGET) $(SRC_DIR)/lex.yy.c $(SRC_DIR)/parser.tab.c $(SRC_DIR)/parser.tab.h

.PHONY: all clean