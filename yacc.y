%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    int yylex();
%}

%token KEYWORD IDENTIFIER PUNCTUATOR

%union {
    char *string;
    int integer;
}

%%

S: KEYWORD IDENTIFIER PUNCTUATOR {
    printf("jijijijiji");
    if(
        (strcmp($<string>1,"program") == 0) && (strcmp($<string>3,";") == 0)
    ){
    printf("%s %s\n", $<string>1, $<string>3);
    }else{
        printf("Syntax error\n");
        yyerror();
    }
    printf("hihihihihih");
}

%%

void main(){
    printf("hello world\n");
    yyparse();
    return 0;
}

void yyerror(char *s){
    printf("Syntax error\n");
}




