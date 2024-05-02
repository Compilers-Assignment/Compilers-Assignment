lex BGAAAM15.l
yacc -d BGAAAM15.y -Wno
gcc lex.yy.c y.tab.c -ll
./a.out