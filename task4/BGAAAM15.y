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

body: VAR declList BEG src END PERIOD 

declList: decl declList
    |

decl: vars COLON type SEMICOLON 
    {
        no_of_variables=0;
    }

    | vars COLON ARRAY LBRACKET INTLITERAL PERIOD PERIOD INTLITERAL RBRACKET OF type SEMICOLON
    {
        char * type = $<string>11;
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

type: INTEGER 
    | BOOLEAN 
    | REAL 
    | CHAR

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
    | IDENTIFIER LBRACKET indexing RBRACKET ASGOP expression SEMICOLON
    {
        if (if_count == -1)
        {
            char * variable = $<string>1;
            char * expression = pop();
            char * index = pop();
            int size = findSize(variable);
            printf("t%d=%s*%d\n",temp_char++,index,size);
            printf("t%d=&%s+t%d\n",temp_char,variable,temp_char-1);
            printf("*t%d=%s\n",temp_char,expression);
        }
        else
        {
            char * variable = $<string>1;
            char * expression = pop();
            char * index = pop();
            int size = findSize(variable);
            char str[100];
            sprintf(str,"t%d=%s*%d\nt%d=&%s+t%d\nt%d=%s\n",temp_char++,index,size,temp_char,variable,temp_char-1,temp_char,expression);
            push_if(str);
        }
    }

expression: arith_expression 
    | bool_exp

arith_expression: arith_expression ADDOP tExpression 
    {
    // printf("arith_expression\n");
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

tExpression: tExpression MULOP fExpression 
    {
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
    | IDENTIFIER 
    {
        push($<string>1);
    }
    | IDENTIFIER LBRACKET indexing RBRACKET
    {
        if (if_count==-1)
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
        else
        {
            char * index = pop();
            char * variable = $<string>1;
            int size = findSize(variable);
            char str_2[50];
            printf("This is getting pushed t%d=%s*%d and t%d=&%s+t%d\n",temp_char,index,size,temp_char+1,variable,temp_char);
            sprintf(str_2,"t%d=%s*%d\nt%d=&%s+t%d\n",temp_char,index,size,temp_char+1,variable,temp_char);
            push_if(str_2);     
            char str[5];
            sprintf(str,"*t%d",temp_char+1);
            temp_char+=2;
            push(str);
        }
    }
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
    | LPAREN bool_exp RPAREN 
    | IDENTIFIER
    {
        push($<string>1);
    }

printable: STRING 
    | printable COMMA readable 
    | printable COMMA STRING 
    | arith_expression

range: TO 
    | DOWNTO

cond: arith_expression RELOP arith_expression
    {
        char * arith_2 = pop();
        char * arith_1 = pop();
        printf("t%d=%s%s%s\n",temp_char++,arith_1,$<string>2,arith_2);
        char str[5];
        sprintf(str,"t%d",temp_char-1);
        push(str);
        // }
        // else
        // {
        //     char str[50];
        //     sprintf(str,"t%d=%s%s%s\n",temp_char,arith_1,$<string>2,arith_2);
        //     push_if(str);
        //     char temp[5];
        //     sprintf(temp,"t%d",temp_char);
        //     push(temp);
        //     temp_char++;
        // }
    }

src: 
    | rule src
rule: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN readable RPAREN SEMICOLON
    |{ if_count++;} ifCond
    | forLoop
    | whileLoop
    | assignment
    | BEG src END

readable: IDENTIFIER 
    | IDENTIFIER LBRACKET indexing RBRACKET 
    /* {
        if (if_count==-1)
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
        else
        {
            char * index = pop();
            char * variable = $<string>1;
            int size = findSize(variable);
            char str_2[50];
            sprintf(str_2,"t%d=%s*%d\nt%d=&%s+t%d\n",temp_char++,index,size,temp_char,variable,temp_char-1);
            push_if(str_2);     
            char str[5];
            sprintf(str,"*t%d",temp_char);
            temp_char++;
            push(str);
        }
    } */

indexing: arith_expression

ifCond: IF conditionals THEN BEG src END SEMICOLON
    {
        if (if_count==0)
        {
            char * condition = pop();
            printf("if %s==0 goto L%d\n",condition,label_count);
            char * matched = pop_if();
            printf("%s",matched);
            printf("L%d:\n",label_count++);
            if_count--;
        }
        else
        {
            char str[100];
            char * condition = pop();
            char * matched = pop_if();
            sprintf(str,"if %s==0 goto L%d\n%sL%d:\n",condition,label_count,matched,label_count++);
            push_if(str);
            if_count--;
        }
    }
    | IF conditionals THEN BEG src END ELSE BEG 
    {
        if (if_count==-1)
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
        else
        {
            char str[100];
            char * condition = pop();
            char * matched = pop_if();
            sprintf(str,"if %s==0 goto L%d\n%sgoto L%d\nL%d:\n",condition,label_count,matched,label_count+1,label_count);
            push_if(str);
            push_label(label_count+1);
            label_count += 2;
            clear_if();
        }
    }
    src END SEMICOLON
    {
        if (if_count==-1)
        {
            char * tail = pop_if();
            printf("%s",tail);
            printf("L%d:",pop_label());
            if_count--;
        }
        else
        {
            char str[50];
            char * tail = pop_if();
            sprintf(str,"%sL%d:\n",tail,pop_label());
            if_count--;
            push_if(str);
        }
    }
    
    
forLoop: FOR IDENTIFIER ASGOP arith_expression range arith_expression 
    {
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
    }
    DO BEG src END SEMICOLON
    {
        int label = pop_label();
        printf("goto L%d\n",label);
        printf("L%d:",label+1);
    }
    
whileLoop: WHILE conditionals 
    {
        char * condition = pop();
        printf("L%d:",label_count);
        printf("if %s==0 goto L%d\n",condition,label_count+1);
        push_label(label_count);
        label_count++;
    }
    DO BEG src END SEMICOLON
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




