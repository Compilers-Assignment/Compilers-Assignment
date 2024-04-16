lex t1.l
yacc -d yacc.y
cc lex.yy.c y.tab.h -ll
./a.out