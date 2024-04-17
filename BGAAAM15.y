%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    int yylex();
    extern FILE *yyin;

    void yyerror();
%}

%token PROGRAM INTEGER REAL BOOLEAN CHAR TO DOWNTO IF ELSE VAR WHILE FOR DO ARRAY BEG END READ WRITE THEN AND OR NOT INTLITERAL IDENTIFIER ADDOP MULOP RELOP ASGOP SEMICOLON COLON LBRACKET RBRACKET COMMA LPAREN RPAREN PERIOD STRING

%union{
    char *string;
    int integer;
}

%%

start: PROGRAM IDENTIFIER SEMICOLON body
body: VAR declList BEG nonEmptySrcWithIf END PERIOD
declList: 
        | decl declList
decl: vars COLON type SEMICOLON
vars: vars COMMA IDENTIFIER | IDENTIFIER
type: INTEGER | BOOLEAN | REAL | CHAR
assignment: IDENTIFIER ASGOP expression SEMICOLON
expression: expression ADDOP tExpression | tExpression
tExpression: tExpression MULOP fExpression | fExpression
fExpression: LPAREN expression RPAREN | IDENTIFIER | INTLITERAL 
printable: IDENTIFIER | STRING
range: TO | DOWNTO
cond: IDENTIFIER RELOP IDENTIFIER 
    | IDENTIFIER RELOP INTLITERAL
    | INTLITERAL RELOP IDENTIFIER
    | INTLITERAL RELOP INTLITERAL

nonEmptySrcWithIf: ruleWithIf srcWithIf 
srcWithIf: 
    | ruleWithIf srcWithIf
ruleWithIf: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN IDENTIFIER RPAREN SEMICOLON
    | ifCond
    | forLoopWithIf
    | whileLoopWithIf
    | assignment

ifCond: matched | unmatched
matched: IF cond THEN matched ELSE matched | BEG nonEmptySrcWithoutIf END
unmatched: IF cond THEN ifCond
        | IF cond THEN matched ELSE unmatched
forLoopWithIf: FOR assignment range expression DO BEG nonEmptySrcWithIf END SEMICOLON
whileLoopWithIf: WHILE LPAREN cond RPAREN DO BEG nonEmptySrcWithIf END SEMICOLON

nonEmptySrcWithoutIf: ruleWithoutIf srcWithoutIf 
srcWithoutIf: 
    | ruleWithoutIf srcWithoutIf
ruleWithoutIf: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN IDENTIFIER RPAREN SEMICOLON
    | forLoopWithoutIf
    | whileLoopWithoutIf
    | assignment

forLoopWithoutIf: FOR assignment range expression DO BEG nonEmptySrcWithoutIf END SEMICOLON
whileLoopWithoutIf: WHILE LPAREN cond RPAREN DO BEG nonEmptySrcWithoutIf END SEMICOLON


%%

void main(){
    yyin = fopen("sample2.txt", "r");
    yyparse();
    printf("Valid input\n");
}

void yyerror(char *s){
    printf("Syntax error\n");
    exit(1);
}




