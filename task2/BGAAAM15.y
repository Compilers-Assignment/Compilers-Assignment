%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    int yylex();
    void yyerror();
    extern FILE *yyin;
%}

%token PROGRAM INTEGER REAL BOOLEAN CHAR TO DOWNTO IF ELSE VAR WHILE FOR DO ARRAY BEG END READ WRITE THEN AND OR NOT INTLITERAL IDENTIFIER ADDOP MULOP RELOP ASGOP SEMICOLON COLON LBRACKET RBRACKET COMMA LPAREN RPAREN PERIOD STRING OF CHAR_LIT

%union{
    char *string;
    int integer;
    
}

%%

start: PROGRAM IDENTIFIER SEMICOLON body 
body: VAR declList BEG srcWithIf END PERIOD 
declList: 
        | decl declList
decl: vars COLON type SEMICOLON 
    | vars COLON ARRAY LBRACKET INTLITERAL PERIOD PERIOD INTLITERAL RBRACKET OF type SEMICOLON

vars: vars COMMA IDENTIFIER 
    | IDENTIFIER

type: INTEGER | BOOLEAN | REAL | CHAR
assignment: IDENTIFIER ASGOP expression SEMICOLON 
    | IDENTIFIER LBRACKET indexing RBRACKET ASGOP expression SEMICOLON

expression: arith_expression | bool_exp

arith_expression: arith_expression ADDOP tExpression 
    | tExpression

tExpression: tExpression MULOP fExpression 
    | fExpression
fExpression: LPAREN arith_expression RPAREN 
    | readable 
    | INTLITERAL 
    | CHAR_LIT


bool_exp: term
    | bool_exp OR term
term: factor
    | term AND factor
factor: cond
    | NOT factor
    | LPAREN bool_exp RPAREN | IDENTIFIER

printable: STRING | printable COMMA readable | printable COMMA STRING | arith_expression
range: TO | DOWNTO

cond: arith_expression RELOP arith_expression


srcWithIf: 
    | ruleWithIf srcWithIf
ruleWithIf: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN readable RPAREN SEMICOLON
    | ifCond
    | forLoopWithIf
    | whileLoopWithIf
    | assignment
    | BEG srcWithIf END

srcWithoutIf: 
    | ruleWithoutIf srcWithoutIf

ruleWithoutIf: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN readable RPAREN SEMICOLON
    | forLoopWithIf
    | whileLoopWithIf
    | assignment
    | BEG srcWithIf END

readable: IDENTIFIER 
    | IDENTIFIER LBRACKET indexing RBRACKET 

indexing: arith_expression

ifCond: IF conditionals THEN BEG matched END SEMICOLON
    | IF conditionals THEN BEG matched END ELSE BEG 
    tail END SEMICOLON
    
matched: IF conditionals THEN BEG matched END ELSE BEG 
    matched END SEMICOLON  
    | srcWithoutIf
tail: IF conditionals THEN BEG tail END SEMICOLON 
    | srcWithoutIf

forLoopWithIf: FOR IDENTIFIER ASGOP arith_expression range arith_expression
    DO BEG srcWithIf END SEMICOLON
    
whileLoopWithIf: WHILE conditionals
    DO BEG srcWithIf END SEMICOLON

conditionals: bool_exp


%%

void main(){
    yyin = fopen("sample.txt", "r");
    yyparse();
    printf("valid input\n");
    fclose(yyin);
}

void yyerror(char *s){
    printf("syntax error\n");
    exit(1);
}




