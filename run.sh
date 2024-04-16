yacc -d BGAAAM15.y
lex BGAAAM15.l
cc lex.yy.c y.tab.c -ll
./a.out