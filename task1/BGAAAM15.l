%{
    #include <stdio.h>
    int linecount = 1;
%}

%option caseless

letter [A-Za-z]
number [0-9]

%%
\/\/.* {}
\n {linecount++;}
\".*\" {;}
\'[0-9a-zA-Z]\' {printf("%d %s character literal\n", linecount, yytext);}

(program|integer|real|boolean|char|to|downto|if|else|var|while|for|do|array|begin|end|read|write|then|array|of|writeln) { 
    
    printf("%d\t%s\tkeyword\n", linecount, yytext); 
}


(and|or|not) {

    printf("%d\t%s\tkeyword\n", linecount, yytext); 

}

{number}* {
    
    printf("%d\t%s\tinteger literal\n", linecount, yytext); 

}

{letter}({letter}|{number}|_)* {

    printf("%d\t%s\tidentifier\n", linecount, yytext); 

}

("+"|"-"|"*"|"/"|"%") {

    printf("%d\t%s\tarithmetic operator\n", linecount, yytext);  
}

(=|<>|<|>|<=|>=) {

    printf("%d\t%s\trelational operator\n", linecount, yytext);

}

:= {

    printf("%d\t%s\tassignment operator\n", linecount, yytext); 

}

(";"|:|"["|"]"|,|"("|")"|".") {
    printf("%d\t%s\tpunctuator\n", linecount, yytext); 
}

. {;}
%%


void main(){
    printf("line number\tlexeme\ttoken type\n");
    yyin = fopen("sample.txt","r");
    yylex();
    fclose(yyin);
}