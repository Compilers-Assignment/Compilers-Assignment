%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    int yylex();
    extern FILE *yyin;
    int temp_ctr = 0;
    void yyerror();
    int count = 0;
    int qind = 0;
    int tos = -1;
    int label_count = 0;
    int temp_char = 0;
    struct quadruple
    {
        char operator[5];
        char operand1[10];
        char operand2[10];
        char result[10];
    } quad[25];
    struct stack
    {
        char c[10];
    } stk[25];
    void addQuadruple(char op1[], char op[], char op2[], char result[])
    {
        if (op!=NULL)
        strcpy(quad[qind].operator, op);
        else strcpy(quad[qind].operator,"");
        if (op1!=NULL) strcpy(quad[qind].operand1, op1);
        else strcpy(quad[qind].operand1,"");
        if (op2!=NULL)
        strcpy(quad[qind].operand2, op2);
        else strcpy(quad[qind].operand2,"");
        strcpy(quad[qind].result, result);
        qind++;
    }
    void display_Quad()
    {
        printf("%s", quad[qind - 1].result);
        printf(" = ");
        printf("%s", quad[qind - 1].operand1);
        printf("%s", quad[qind - 1].operator);
        printf("%s\n", quad[qind - 1].operand2);
    }
    void push(char *c)
    {
        strcpy(stk[++tos].c, c);
    }
    char *pop()
    {
        char *c = stk[tos].c;
        tos = tos - 1;
        // printf("%s\n",c);
        return c;
    }
%}

%token PROGRAM INTEGER REAL BOOLEAN CHAR TO DOWNTO IF ELSE VAR WHILE FOR DO ARRAY BEG END READ WRITE THEN AND OR NOT INTLITERAL IDENTIFIER ADDOP MULOP RELOP ASGOP SEMICOLON COLON LBRACKET RBRACKET COMMA LPAREN RPAREN PERIOD STRING OF CHAR_LIT

%union{
    char *string;
    int integer;
    
}

%%

start: PROGRAM IDENTIFIER SEMICOLON body 
body: VAR declList BEG nonEmptySrcWithIf END PERIOD 
declList: 
        | decl declList
decl: vars COLON type SEMICOLON | vars COLON ARRAY LBRACKET INTLITERAL PERIOD PERIOD INTLITERAL RBRACKET OF type SEMICOLON
vars: vars COMMA IDENTIFIER | IDENTIFIER
type: INTEGER | BOOLEAN | REAL | CHAR
assignment: IDENTIFIER ASGOP expression SEMICOLON 
{
    char * a = pop();
    addQuadruple(a, NULL, NULL,$<string>1);
    display_Quad();
    push(a);
}

expression: arith_expression | bool_exp

arith_expression: arith_expression ADDOP tExpression {
    printf("arith_expression\n");
    char str[5];
    sprintf(str,"t%d",temp_char++);
    char * a = pop();
    char * b = pop();
    addQuadruple(b,$<string>2, a ,str);
    display_Quad();
    push(str);
}  
    | tExpression  
tExpression: tExpression MULOP fExpression {
    char str[5];
    sprintf(str,"t%d",temp_char++);
    char * a = pop();
    char * b = pop();
    addQuadruple(b,$<string>2,a,str);
    display_Quad();
    push(str);
    } 
    | fExpression
fExpression: LPAREN arith_expression RPAREN 
    | readable 
    | INTLITERAL 
    {
        push($<string>1);
    }
    | CHAR_LIT
    {
        push($<string>1);
    }

bool_exp: term
    | bool_exp OR term
    {
        char * t0 = pop();
        char * t1 = pop();
        int new_temp = temp_char++;
        printf("t%d=1\n",new_temp);
        printf("if %s==1 goto L%d\n",t0,label_count);
        printf("if %s==1 goto L%d\n",t1,label_count);
        printf("t%d=0\n",new_temp);
        printf("L%d:",label_count++);
        char str[5];
        sprintf(str,"t%d",new_temp);
        push(str);
    }
term: factor
    | term AND factor
    {
        char * t0 = pop();
        char * t1 = pop();
        int new_temp = temp_char++;
        printf("t%d=0\n",new_temp);
        printf("if %s==0 goto L%d\n",t0,label_count);
        printf("if %s==0 goto L%d\n",t1,label_count);
        printf("t%d=1\n",new_temp);
        printf("L%d:",label_count++);
        char str[5];
        sprintf(str,"t%d",new_temp);
        push(str);
    }
factor: cond
    | NOT factor
    {
        char *t0 = pop();
        int new_temp = temp_char++;
        printf("t%d=1\n",new_temp);
        printf("if %s==1 goto L%d\n",t0,label_count);
        printf("t%d=0\n",new_temp);
        printf("L%d:",label_count++);
        char str[5];
        sprintf(str,"t%d",new_temp);
        push(str);
        label_count++;
    }
    | LPAREN bool_exp RPAREN | IDENTIFIER {
        push($<string>1);
    }

printable: STRING | printable COMMA readable | printable COMMA STRING | arith_expression
range: TO | DOWNTO
/* cond: readable RELOP readable 
    | readable RELOP INTLITERAL
    | INTLITERAL RELOP readable
    | INTLITERAL RELOP INTLITERAL */
cond: arith_expression RELOP arith_expression
    {
        char str[5];
        sprintf(str,"t%d",temp_char++);
        char * a = pop();
        char * b = pop();
        addQuadruple(b,$<string>2,a,str);
        display_Quad();
        push(str);
    }

nonEmptySrcWithIf: 
    | ruleWithIf srcWithIf 
srcWithIf: 
    | ruleWithIf srcWithIf
ruleWithIf: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN readable RPAREN SEMICOLON
    | ifCond
    | forLoopWithIf
    | whileLoopWithIf
    | assignment
    | BEG nonEmptySrcWithIf END

nonsrcWithIf: 
    | nonIf nonsrcWithIf

nonIf: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN readable RPAREN SEMICOLON
    | forLoopWithIf
    | whileLoopWithIf
    | assignment
    | BEG nonEmptySrcWithIf END

readable: IDENTIFIER 
    {
        push($<string>1);
    }
    | IDENTIFIER LBRACKET indexing RBRACKET 

indexing: IDENTIFIER 
    {
        push($<string>1);
    }
    | INTLITERAL
    {
        push($<string>1);
    }
/* ifCond: matched | unmatched
matched: IF cond THEN BEG matched END ELSE BEG matched END SEMICOLON | nonEmptySrcWithoutIf
unmatched: IF cond THEN BEG ifCond END SEMICOLON
        | IF cond THEN BEG matched END ELSE BEG unmatched END SEMICOLON */
ifCond: IF conditionals THEN BEG matched END SEMICOLON | IF conditionals THEN BEG matched END ELSE BEG tail END SEMICOLON
matched: IF conditionals THEN BEG matched END ELSE BEG matched END SEMICOLON | nonsrcWithIf
tail: IF conditionals THEN BEG tail END SEMICOLON | nonsrcWithIf

forLoopWithIf: FOR IDENTIFIER ASGOP arith_expression range arith_expression DO BEG nonEmptySrcWithIf END SEMICOLON
whileLoopWithIf: WHILE conditionals DO BEG nonEmptySrcWithIf END SEMICOLON

conditionals: bool_exp

/* nonEmptySrcWithoutIf: ruleWithoutIf srcWithoutIf 
srcWithoutIf: 
    | ruleWithoutIf srcWithoutIf
ruleWithoutIf: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN readable RPAREN SEMICOLON
    | forLoopWithoutIf
    | whileLoopWithoutIf
    | assignment

forLoopWithoutIf: FOR IDENTIFIER ASGOP expression range expression DO BEG nonEmptySrcWithoutIf END SEMICOLON
whileLoopWithoutIf: WHILE LPAREN cond RPAREN DO BEG nonEmptySrcWithoutIf END SEMICOLON */


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




