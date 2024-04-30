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
    int if_count = -1;
    int label_stack_count = -1;
    int variable_count = 0;
    int no_of_variables = 0;
    int label_stack[100];
    void push_label(int label)
    {
        label_stack[++label_stack_count] = label;
    }
    int pop_label()
    {
        return label_stack[label_stack_count--];
    }
    struct quadruple
    {
        char operator[5];
        char operand1[10];
        char operand2[10];
        char result[10];
    } quad[25];
    char if_stack[100][100];
    struct variable
    {
        char name[10];
        char type[10];
        int size;
    } variable_array[25];
    void addVariable(char name[], char type[], int size)
    {
        strcpy(variable_array[variable_count].name, name);
        strcpy(variable_array[variable_count].type, type);
        variable_array[variable_count].size = size;
        variable_count++;    
    }
    void updateTypes(char type[], int size, int no_of_variables)
    {
        for (int i = variable_count - no_of_variables; i < variable_count; i++)
        {
            strcpy(variable_array[i].type,type);
            variable_array[i].size = size;
        }
    }
    int findSize(char name[])
    {
        for (int i = 0; i < variable_count; i++)
        {
            if (strcmp(variable_array[i].name,name)==0)
            {
                return variable_array[i].size;
            }
        }
        return -1;
    }
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
    void push_if(char *c)
    {
        if (strcmp(if_stack[if_count],"")==0)
        {
            strcpy(if_stack[if_count],c);
        }
        else
        {
            strcat(if_stack[if_count],c);
        }
    }
    char * pop_if()
    {
        char *c = if_stack[if_count];
        return c;
    }
    void clear_if()
    {
        strcpy(if_stack[if_count],"");
    }
    void push(char *c)
    {
        // printf("Pushing this %s\n",c);
        strcpy(stk[++tos].c, c);
    }
    char *pop()
    {
        // printf("Popping this %s\n",stk[tos].c);
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
body: VAR declList BEG srcWithIf END PERIOD 
declList: 
        | decl declList
decl: vars COLON type SEMICOLON {
        no_of_variables=0;
    }
    | vars COLON ARRAY LBRACKET INTLITERAL PERIOD PERIOD INTLITERAL RBRACKET OF type SEMICOLON
    {
        char * type = $<string>11;
        printf("Type is %s\n",type);
        if (strcmp(type,"integer")==0)
        {
            updateTypes("integer",4,no_of_variables);
        }
        no_of_variables = 0;
    }
vars: vars COMMA IDENTIFIER 
    {
        addVariable($<string>3,"",0);
        no_of_variables++;
    }
    | IDENTIFIER
    {
        addVariable($<string>1,"",0);
        no_of_variables++;
    }
type: INTEGER | BOOLEAN | REAL | CHAR
assignment: IDENTIFIER ASGOP expression SEMICOLON 
    {
        if (if_count == -1)
        {
            char * a = pop();
            addQuadruple(a, NULL, NULL,$<string>1);
            display_Quad();
            // push(a);
        }
        else 
        {
            char * a = pop();
            char str[50];
            sprintf(str,"%s=%s\n",$<string>1,a);
            push_if(str);
        }
    }
    |
    IDENTIFIER LBRACKET indexing RBRACKET ASGOP expression SEMICOLON
    {
        char * variable = $<string>1;
        char * expression = pop();
        char * index = pop();
        int size = findSize(variable);
        printf("t%d=%s*%d\n",temp_char++,index,size);
        printf("t%d=&%s+t%d\n",temp_char,variable,temp_char-1);
        printf("*t%d=%s\n",temp_char,expression);
    }
expression: arith_expression | bool_exp

arith_expression: arith_expression ADDOP tExpression {
    printf("arith_expression\n");
    char str[20];
    char * a = pop();
    char * b = pop();
    if (if_count == -1)
    {
        sprintf(str,"t%d",temp_char++);
        addQuadruple(b,$<string>2, a ,str);
        display_Quad();
        push(str);
    }
    else 
    {
        char temp[5];
        sprintf(temp,"t%d",temp_char);
        sprintf(str,"t%d=%s%s%s\n",temp_char++,b,$<string>2,a);
        push(temp);
        push_if(str);
    }
}  
    | tExpression

tExpression: tExpression MULOP fExpression {
    char str[5];
    sprintf(str,"t%d",temp_char++);
    char * a = pop();
    char * b = pop();
    if (if_count == -1)
    {
        addQuadruple(b,$<string>2,a,str);
        display_Quad();
    }
    else 
    {
        char temp[50];
        sprintf(temp,"t%d=%s%s%s\n",temp_char-1,b,$<string>2,a);
        push_if(temp);
    }
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
        // printf("a --> %s\n", a);
        // printf("b --> %s\n", b);
        // printf("str --> %s\n", str);
        display_Quad();
        // a = pop();
        // printf("a --> %s\n", a);
        push(str);
        // a = pop();
        // printf("a --> %s\n", a);
    }


srcWithIf: 
    | ruleWithIf srcWithIf
ruleWithIf: WRITE LPAREN printable RPAREN SEMICOLON {pop();}
    | READ LPAREN readable RPAREN SEMICOLON {pop();}
    | {if_count++;}ifCond
    | forLoopWithIf
    | whileLoopWithIf
    | assignment
    | BEG srcWithIf END

srcWithoutIf: 
    | ruleWithoutIf srcWithoutIf

ruleWithoutIf: WRITE LPAREN printable RPAREN SEMICOLON {pop();}
    | READ LPAREN readable RPAREN SEMICOLON {pop();}
    | forLoopWithIf
    | whileLoopWithIf
    | assignment
    | BEG srcWithIf END

readable: IDENTIFIER 
    {
        push($<string>1);
    }
    | IDENTIFIER LBRACKET indexing RBRACKET 
    {
        char * index = pop();
        char * variable = $<string>1;
        int size = findSize(variable);
        printf("t%d=%s*%d\n",temp_char++,index,size);
        printf("t%d=&%s+t%d\n",temp_char,variable,temp_char-1);
        char str[5];
        sprintf(str,"*t%d",temp_char);
        temp_char++;
        push(str);
    }

indexing: arith_expression

/* ifCond: matched | unmatched
matched: IF cond THEN BEG matched END ELSE BEG matched END SEMICOLON | nonEmptySrcWithoutIf
unmatched: IF cond THEN BEG ifCond END SEMICOLON
        | IF cond THEN BEG matched END ELSE BEG unmatched END SEMICOLON */
ifCond: IF conditionals THEN BEG matched END SEMICOLON
    {
        char * condition = pop();
        printf("if %s==0 goto L%d\n",condition,label_count);
        char * matched = pop_if();
        printf("%s",matched);
        printf("L%d:\n",label_count++);
        if_count--;
    }
    | IF conditionals THEN BEG matched END ELSE BEG 
    {
        char * condition = pop();
        printf("if %s==0 goto L%d\n",condition,label_count);
        char * matched = pop_if();
        printf("%s",matched);
        printf("goto L%d\n",label_count+1);
        printf("L%d:\n",label_count);
        push_label(label_count+1);
        label_count += 2;
        clear_if();
    }
    tail END SEMICOLON
    {
        char * tail = pop_if();
        printf("%s",tail);
        printf("L%d:",pop_label());
        if_count--;
    }
matched: IF conditionals THEN BEG matched END ELSE BEG 
    {
        char * condition = pop();
        printf("if %s==0 goto L%d\n",condition,label_count);
        char * matched = pop_if();
        printf("%s",matched);
        printf("goto L%d\n",label_count+1);
        printf("L%d:\n",label_count);
        push_label(label_count+1);
        label_count += 2;
        clear_if();
    }
    matched END SEMICOLON  
    {
        char * tail = pop_if();
        printf("%s",tail);
        printf("L%d:",pop_label());
        if_count--;
    }
    | srcWithoutIf
tail: IF conditionals THEN BEG tail END SEMICOLON 
    {
        char * condition = pop();
        printf("if %s==0 goto L%d\n",condition,label_count);
        char * matched = pop_if();
        printf("%s",matched);
        printf("L%d:\n",label_count++);
        if_count--;
    }
    | srcWithoutIf

forLoopWithIf: FOR IDENTIFIER ASGOP arith_expression range arith_expression {
    if (if_count == -1)
    {
        char * a = pop();
        char * b = pop();
        addQuadruple(b, NULL, NULL,$<string>2);
        display_Quad();
        
        if (strcmp($<string>5,"to")==0)
        {
            
            printf("L%d: ",label_count);
            printf("if %s>%s goto L%d\n",$<string>2,a,label_count+1);
            push_label(label_count);
            label_count += 2;
        }
        else 
        {
            printf("L%d: ",label_count);
            printf("if %s<%s goto L%d\n",$<string>2,a,label_count+1);
            push_label(label_count+1);
            label_count += 2;
        }
    }
    else // To be completed
    {
        char * a = pop();
        char str[50];
        sprintf(str,"%s=%s\n",$<string>2,a);
        push_if(str);
    }
    }DO BEG srcWithIf END SEMICOLON {
        int label = pop_label();
        printf("goto L%d\n",label);
        printf("L%d:",label+1);
    }
    
whileLoopWithIf: WHILE conditionals {
        char * condition = pop();
        printf("L%d:",label_count);
        printf("if %s==0 goto L%d\n",condition,label_count+1);
        push_label(label_count);
        label_count++;
    }
    DO BEG srcWithIf END SEMICOLON
    {
        int label = pop_label();
        printf("goto L%d\n",label);
        printf("L%d:",label+1);
    }


conditionals: bool_exp


%%

void main(){
    yyin = fopen("sample.txt", "r");
    yyparse();
    fclose(yyin);
}

void yyerror(char *s){
    printf("syntax error\n");
    exit(1);
}




