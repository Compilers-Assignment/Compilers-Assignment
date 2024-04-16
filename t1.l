%{
#include "y.tab.h"
int linecount = 1;
%}

%option caseless

letter [A-Za-z]
number [0-9]

%%
\n {linecount++;}
\".*\" {;}
(program|integer|real|boolean|char|to|downto|if|else|var|while|for|do|array|begin|end|read|write|then) { printf("%d %s keyword\n", linecount, yytext); return KEYWORD;}
(and|or|not) {printf("%d %s boolean operator\n", linecount, yytext);}
{number}* {printf("%d %s integer literal\n", linecount, yytext);}
{letter}({letter}|{number}|_)* {printf("%d %s identifier\n", linecount, yytext); return IDENTIFIER;}
("+"|"-"|"*"|"/"|"%") {printf("%d %s arithmetic operator\n", linecount, yytext);}
(=|<>|<|>|<=|>=) {printf("%d %s relational operator\n", linecount, yytext);}
:= {printf("%d %s assignment operator\n", linecount, yytext);}
(";"|:|[|]|,|"("|")"|".") {printf("%d %s punctuator\n", linecount, yytext); return PUNCTUATOR;}
. {;}
%%
