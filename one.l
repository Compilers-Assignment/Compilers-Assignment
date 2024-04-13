%{

#include<stdlib.h>
#include<stdio.h>
extern int yylval;
void yyerror (char const *s) { //can use this instead of the current printf return 0
 fprintf (stderr, "%s\n", s);
}
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
<prog>{keywrd}; {printf("Syntax Error %s", yytext); return 0;}
<prog>{letter}({letter}*|{number}*|_*)*; {printf("IDENTIFIER"); BEGIN prevar;} //does this count as identifier?

<prevar>var{space}* {printf("Entering var loop"); BEGIN var;} //prevar exists because we don't want program having no name and just directly starting off with variable
<prevar>[^ \n\t] {printf("Syntax Error %s", yytext); return 0;} //this is the error handling loop, returns syntax error and terminates the program the moment something wrong is detected. You'll see this exact block repeated multiple times in different classes.
<prog>[^ \n\t] {printf("Syntax Error %s", yytext); return 0;}

<var>begin{space}* BEGIN pblock;
<var>{keywrd}({space}|,) {printf("Syntax Error %s", yytext); return 0;}
<var>{letter}({letter}*|{number}*|_*)*{space} {printf("Variable");} //currently assumes that there will be spaces before the colon.
<var>{letter}({letter}*|{number}*|_*)*, {printf("Variable"); BEGIN commavar;} //The comma case has a separate regex, since the edge case (var1, var2, : type) exists, which should not be accepted, but would be if space and commas were considered

<commavar>{letter}({letter}*|{number}*|_*)*{space} {printf("Variable"); BEGIN var;} //in case no commas are present after this, we can know that this is the final variable and shift back to the variable class
<commavar>{letter}({letter}*|{number}*|_*)*, {printf("Variable");} 
<commavar>[^ \n\t] {printf("Syntax Error %s", yytext); return 0;}
<var>{space}*:{space}* {BEGIN vartype;} //colons can only be handled in the variable class and not in the commavar class, this ensures that either the first or the last variabl ONLY can have the colon after it.
<vartype>(char|integer|boolean|real); {printf("Type"); BEGIN var;}
<vartype>[^ \n\t] {printf("Syntax Error %s", yytext); return 0;}


<var>[^ \n\t] {printf("Syntax Error %s", yytext); return 0;}



[^ \n\t] {printf("Syntax Error %s", yytext); return 0;}
. {}






%%
int main()
{
yyin = fopen("sample.c", "r");
yylex();
}
