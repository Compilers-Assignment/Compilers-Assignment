%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    int yylex();

    void yyerror();

    void checkTop(char *s1, char *s2){
         if(!strcmp(s1, s2)==0){
            yyerror();
         }
    }
%}

%token KEYWORD IDENTIFIER PUNCTUATOR BOOLOP INTLITERAL RELOP ASGOP ARITHOP

%union {
    char *string;
    int integer;
}

%%

start: KEYWORD IDENTIFIER PUNCTUATOR body {
    if(
       !((strcmp($<string>1,"program") == 0) && (strcmp($<string>3,";") == 0))
    ){
        printf("Asfd");
        yyerror();
    };
}

body: KEYWORD decllist KEYWORD mainsrc KEYWORD{
    if(!((strcmp($<string>1, "var") == 0) && (strcmp($<string>2, "begin") == 0) && (strcmp($<string>3, "end") == 0))){
        yyerror();
    };
}

decllist: 
    | decl decllist {}

decl: vars PUNCTUATOR {checkTop($<string>1, ":");} type PUNCTUATOR {checkTop($<string>1, ";");}

vars:  vars PUNCTUATOR IDENTIFIER
    | IDENTIFIER
    

type: KEYWORD

mainsrc: {}
%%

void main(){
    printf("hello world\n");
    yyparse();
}

void yyerror(){
    printf("Syntax error\n");
}




