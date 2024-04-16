yacc -d yacc.y
lex t1.l
cc lex.yy.c y.tab.c -ll
./a.out