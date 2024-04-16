%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    int yylex();

    void yyerror();

    void checkTop(char *s1, char *s2){
         if(!strcmp(s1, s2)==0){
            printf("Error at %s and %s",s1,s2);
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

start: 'program'IDENTIFIER PUNCTUATOR {
    // if(
    //    !((strcmp($<string>1,"program") == 0) && (strcmp($<string>3,";") == 0))
    // ){
    //     printf("Asfd");
    //     yyerror();
    // };
} body 

body: KEYWORD {checkTop($<string>1, "var");}decllist KEYWORD {checkTop($<string>1, "begin");}mainsrc KEYWORD {checkTop($<string>1, "end");}

decllist: 
    | decl decllist {}

decl: vars ':' {printf("This is string 1 here %s\n",$<string>2);checkTop($<string>1, ":");} type PUNCTUATOR {checkTop($<string>1, ";");}

vars:  vars PUNCTUATOR IDENTIFIER
    | IDENTIFIER
    

type: KEYWORD

mainsrc: {}
%%

void main(){
    printf("hello world\n");
    yyparse();
}

void yyerror(char * s){
    printf("Syntax error\n");
}




