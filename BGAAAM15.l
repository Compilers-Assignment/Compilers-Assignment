%{
    #include "y.tab.h"
    int linecount = 1;
    int yylex();
%}

%option caseless

letter [A-Za-z]
number [0-9]

%%

\n {linecount++;}

\".*\" {;}

(program|integer|real|boolean|char|to|downto|if|else|var|while|for|do|array|begin|end|read|write|then) { 
    printf("%d %s keyword\n", linecount, yytext); 
    yylval.string = strdup(yytext); 
    return KEYWORD;
}

(and|or|not) {
    printf("%d %s boolean operator\n", linecount, yytext); 
    yylval.string = strdup(yytext); 
    return BOOLOP;
}

{number}* {
    printf("%d %s integer literal\n", linecount, yytext); 
    yylval.integer = atoi(yytext); 
    return INTLITERAL;
}

{letter}({letter}|{number}|_)* {
    printf("%d %s identifier\n", linecount, yytext); 
    yylval.string = strdup(yytext); 
    return IDENTIFIER;
}

("+"|"-"|"*"|"/"|"%") {
    printf("%d %s arithmetic operator\n", linecount, yytext); 
    yylval.string = strdup(yytext); 
    return ARITHOP;
}

(=|<>|<|>|<=|>=) {
    printf("%d %s relational operator\n", linecount, yytext); 
    yylval.string = strdup(yytext); 
    return RELOP;
}

:= {
    printf("%d %s assignment operator\n", linecount, yytext); 
    yylval.string = strdup(yytext); 
    return ASGOP;
}

(";"|:|[|]|,|"("|")"|".") {
    printf("%d %s punctuator\n", linecount, yytext); 
    yylval.string = strdup(yytext); 
    return PUNCTUATOR;
}

. {;}
%%
