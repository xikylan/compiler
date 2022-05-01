all: parser
parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: scanner.l parser.tab.h
	flex scanner.l

parser: lex.yy.c parser.tab.c parser.tab.h
	gcc lex.yy.c parser.tab.c -ll -o parser

clean:
	rm -f parser.tab.c parser.tab.h parser lex.yy.c lex 




