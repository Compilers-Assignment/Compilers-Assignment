yacc -d BGAAAM15.y -Wno
lex BGAAAM15.l
cc lex.yy.c y.tab.c -ll
./a.out sample.txt