%{

#include<stdlib.h>
#include<stdio.h>
extern int yylval;
void yyerror (char const *s) { //can use this instead of the current printf return 0
 fprintf (stderr, "%s\n", s);
}
int linecount = 1;
%}
%x prog prevar var vartype commavar pblock 
letter [A-Za-z]
number [0-9]
lower [a-z]
upper [A-Z]
space [  \t]
keywrd (program|integer|real|boolean|char|to|downto|if|else|var|while|for|do|array|and|or|not|begin|end|read|write) 
%%

program {printf("Program begins"); BEGIN prog;}
<prog>{keywrd}; {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}
<prog>{letter}({letter}*|{number}*|_*)*; {printf("IDENTIFIER"); BEGIN prevar;} //does this count as identifier?

<prevar>var{space}* {printf("Entering var loop"); BEGIN var;} //this is for variables
<prevar>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}
<prog>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}

<var>begin{space}* BEGIN pblock;
<var>{keywrd}({space}|,) {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}
<var>{letter}({letter}*|{number}*|_*)*{space} {printf("Variable");} //currently assumes that there will be spaces before the colon
<var>{letter}({letter}*|{number}*|_*)*, {printf("Variable"); BEGIN commavar;} //currently assumes that there will be spaces before the

<commavar>{letter}({letter}*|{number}*|_*)*{space} {printf("Variable"); BEGIN var;} //currently assumes that there will be spaces before the colon
<commavar>{letter}({letter}*|{number}*|_*)*, {printf("Variable");} //currently assumes that there will be spaces before the
<commavar>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}
<var>{space}*:{space}* {BEGIN vartype;} 
<vartype>(char|integer|boolean|real); {printf("Type"); BEGIN var;}
<vartype>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}


<var>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}


<prog,prevar,var,vartype,commavar,pblock>\n {linecount++;}
[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}
. {}






%%
int main()
{
yyin = fopen("sample.c", "r");
yylex();
}
