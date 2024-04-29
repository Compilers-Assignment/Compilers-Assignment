%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    int yylex();
    extern FILE *yyin;
    void yyerror();
    typedef struct treeNode treeNode;
    typedef struct linkedList linkedList;

    struct linkedList{
        treeNode *node;
        linkedList *next;
    };
    struct treeNode{
        char *nonTerminal;
        char *terminal;
        treeNode *parent;
        linkedList *children;
    };

    treeNode *createNode(char *nonTerminal, char *terminal){
        treeNode *node = (treeNode *)malloc(sizeof(treeNode));
        node->nonTerminal = nonTerminal;
        node->terminal = terminal;
        node->parent = NULL;
        node->children = NULL;
        return node;
    }

    linkedList *createList(treeNode *node){
        linkedList *list = (linkedList *)malloc(sizeof(linkedList));
        list->node = node;
        list->next = NULL;
        return list;
    }

    void addToLinkedList(linkedList *list, treeNode *node){
        linkedList *temp = list;
        while(temp->next != NULL){
            temp = temp->next;
        }
        temp->next = createList(node);
    }

    void addChild(treeNode *parent, treeNode *child){
        if(parent->children == NULL){
            parent->children = createList(child);
        }
        else{
            addToLinkedList(parent->children, child);
        }
        child->parent = parent;
    }

        
    typedef struct
    {
        linkedList *top;
    } stack;

    stack *createStack()
    {
        stack *newStack = (stack *)malloc(sizeof(stack));
        if (newStack == NULL)
        {
            printf("Memory allocation failed.\n");
            exit(1);
        }
        newStack->top = NULL;
        return newStack;
    }
    int isEmpty(stack *s)
    {
        return s->top == NULL;
    }
    void push(stack *s, treeNode *node)
    {
        linkedList *newNode = (linkedList *)malloc(sizeof(linkedList));
        if (newNode == NULL)
        {
            printf("Memory allocation failed.\n");
            exit(1);
        }
        newNode->node = node;
        newNode->next = s->top;
        s->top = newNode;
    }
    treeNode *pop(stack *s)
    {
        if (isEmpty(s))
        {
            printf("Stack underflow.\n");
            exit(1);
        }
        linkedList *temp = s->top;
        treeNode *poppedNode = temp->node;
        s->top = temp->next;
        return poppedNode;
    }
    treeNode *peek(stack *s)
    {
        if (isEmpty(s))
        {
            printf("Stack is empty.\n");
            exit(1);
        }
        return s->top->node;
    }

    stack *parseStack = createStack();
%}

%token PROGRAM INTEGER REAL BOOLEAN CHAR TO DOWNTO IF ELSE VAR WHILE FOR DO ARRAY BEG END READ WRITE THEN AND OR NOT INTLITERAL IDENTIFIER ADDOP MULOP RELOP ASGOP SEMICOLON COLON LBRACKET RBRACKET COMMA LPAREN RPAREN PERIOD STRING OF CHAR_LIT

%union{
    char *string;
    int integer;
}

%%

start: PROGRAM IDENTIFIER SEMICOLON body {
    treeNode *node = createNode("start", NULL);
    addChild(node, createNode("PROGRAM", "PROGRAM"));
    addChild(node, createNode("IDENTIFIER", $<string>2));
    addChild(node, createNode("SEMICOLON", ";"));
    treeNode *bodyNode = pop(parseStack);
    addChild(node, bodyNode);
    push(parseStack, node);
}

body: VAR declList BEG nonEmptySrcWithIf END PERIOD {
    treeNode *node = createNode("body", NULL);
    addChild(node, createNode("VAR", "VAR"));
    treeNode *declListNode = pop(parseStack);
    addChild(node, declListNode);
    addChild(node, createNode("BEG", "BEGIN"));
    treeNode *nonEmptySrcWithIfNode = pop(parseStack);
    addChild(node, nonEmptySrcWithIfNode);
    addChild(node, createNode("END", "END"));
    addChild(node, createNode("PERIOD", "."));
    push(parseStack, node);

}

declList:   {
                treeNode *node = createNode("declList", NULL);
                push(parseStack, node);
            }
            |decl declList 
            {
                treeNode *node = createNode("declList", NULL);
                treeNode *declNode = pop(parseStack);
                addChild(node, declNode);
                treeNode *declListNode = pop(parseStack);
                addChild(node, declListNode);
                push(parseStack, node);
        
            }

decl: vars COLON type SEMICOLON  {
        treeNode *node = createNode("decl", NULL);
        treeNode *varsNode = pop(parseStack);
        addChild(node, varsNode);
        addChild(node, createNode("COLON", ":"));
        addChild(node, createNode("type", $<string>3));
        addChild(node, createNode("SEMICOLON", ";"));
        push(parseStack, node);
    }
    | vars COLON ARRAY LBRACKET INTLITERAL PERIOD PERIOD INTLITERAL RBRACKET OF type SEMICOLON {
    treeNode *node = createNode("decl", NULL);
    treeNode *varsNode = pop(parseStack);
    addChild(node, varsNode);
    addChild(node, createNode("COLON", ":"));
    addChild(node, createNode("ARRAY", "ARRAY"));
    addChild(node, createNode("LBRACKET", "["));
    addChild(node, createNode("INTLITERAL", $<string>6));
    addChild(node, createNode("PERIOD", ".."));
    addChild(node, createNode("PERIOD", ".."));
    addChild(node, createNode("INTLITERAL", $<string>8));
    addChild(node, createNode("RBRACKET", "]"));
    addChild(node, createNode("OF", "OF"));
    addChild(node, createNode("type", $<string>10));
    addChild(node, createNode("SEMICOLON", ";"));
    push(parseStack, node);

    }

vars: vars COMMA IDENTIFIER {
    treeNode *node = createNode("vars", NULL);
    treeNode *varsNode = pop(parseStack);
    addChild(node, varsNode);
    addChild(node, createNode("COMMA", ","));
    addChild(node, createNode("IDENTIFIER", $<string>3));
    push(parseStack, node);
    }
    | IDENTIFIER {
        treeNode *node = createNode("vars", NULL);
        addChild(node, createNode("IDENTIFIER", $<string>1));
        push(parseStack, node);
    
    }

type: INTEGER {
    treeNode *node = createNode("type", NULL);
    addChild(node, createNode("INTEGER", "INTEGER"));
    push(parseStack, node);
    }
    | REAL {
        treeNode *node = createNode("type", NULL);
        addChild(node, createNode("REAL", "REAL"));
        push(parseStack, node);
    }
    | BOOLEAN {
        treeNode *node = createNode("type", NULL);
        addChild(node, createNode("BOOLEAN", "BOOLEAN"));
        push(parseStack, node);
    }
    | CHAR {
        treeNode *node = createNode("type", NULL);
        addChild(node, createNode("CHAR", "CHAR"));
        push(parseStack, node);
    
    }
    
assignment: IDENTIFIER ASGOP expression SEMICOLON {
    treeNode *node = createNode("assignment", NULL);
    addChild(node, createNode("IDENTIFIER", $<string>1));
    addChild(node, createNode("ASGOP", ":="));
    treeNode *expressionNode = pop(parseStack);
    addChild(node, expressionNode);
    addChild(node, createNode("SEMICOLON", ";"));
    push(parseStack, node);
}

expression: arith_expression {
    treeNode *node = createNode("expression", NULL);
    treeNode *arithExpressionNode = pop(parseStack);
    addChild(node, arithExpressionNode);
    push(parseStack, node);
}
    | bool_exp {
        treeNode *node = createNode("expression", NULL);
        treeNode *boolExpNode = pop(parseStack);
        addChild(node, boolExpNode);
        push(parseStack, node);
    }

arith_expression: arith_expression ADDOP tExpression {
    treeNode *node = createNode("arith_expression", NULL);
    treeNode *arithExpressionNode = pop(parseStack);
    addChild(node, arithExpressionNode);
    addChild(node, createNode("ADDOP", $<string>2));
    treeNode *tExpressionNode = pop(parseStack);
    addChild(node, tExpressionNode);
    push(parseStack, node);
}
    | tExpression {
        treeNode *node = createNode("arith_expression", NULL);
        treeNode *tExpressionNode = pop(parseStack);
        addChild(node, tExpressionNode);
        push(parseStack, node);
    
}
tExpression: tExpression MULOP fExpression {
    treeNode *node = createNode("tExpression", NULL);
    treeNode *tExpressionNode = pop(parseStack);
    addChild(node, tExpressionNode);
    addChild(node, createNode("MULOP", $<string>2));
    treeNode *fExpressionNode = pop(parseStack);
    addChild(node, fExpressionNode);
    push(parseStack, node);
}
    | fExpression {
        treeNode *node = createNode("tExpression", NULL);
        treeNode *fExpressionNode = pop(parseStack);
        addChild(node, fExpressionNode);
        push(parseStack, node);
    

}
fExpression: LPAREN arith_expression RPAREN {
    treeNode *node = createNode("fExpression", NULL);
    addChild(node, createNode("LPAREN", "("));
    treeNode *arithExpressionNode = pop(parseStack);
    addChild(node, arithExpressionNode);
    addChild(node, createNode("RPAREN", ")"));
    push(parseStack, node);
} | readable {
    treeNode *node = createNode("fExpression", NULL);
    treeNode *readableNode = pop(parseStack);
    addChild(node, readableNode);
    push(parseStack, node);
} | INTLITERAL {
    treeNode *node = createNode("fExpression", NULL);
    addChild(node, createNode("INTLITERAL", $<string>1));
    push(parseStack, node);
} |  CHAR_LIT {
    treeNode *node = createNode("fExpression", NULL);
    addChild(node, createNode("CHAR_LIT", $<string>1));
    push(parseStack, node);

}

bool_exp: term {
    treeNode *node = createNode("bool_exp", NULL);
    treeNode *termNode = pop(parseStack);
    addChild(node, termNode);
    push(parseStack, node);
}
    | bool_exp OR term {
        treeNode *node = createNode("bool_exp", NULL);
        treeNode *boolExpNode = pop(parseStack);
        addChild(node, boolExpNode);
        addChild(node, createNode("OR", "OR"));
        treeNode *termNode = pop(parseStack);
        addChild(node, termNode);
        push(parseStack, node);
    }
term: factor {
    treeNode *node = createNode("term", NULL);
    treeNode *factorNode = pop(parseStack);
    addChild(node, factorNode);
    push(parseStack, node);
}
    | term AND factor {
        treeNode *node = createNode("term", NULL);
        treeNode *termNode = pop(parseStack);
        addChild(node, termNode);
        addChild(node, createNode("AND", "AND"));
        treeNode *factorNode = pop(parseStack);
        addChild(node, factorNode);
        push(parseStack, node);
    }

factor: cond {
    treeNode *node = createNode("factor", NULL);
    treeNode *condNode = pop(parseStack);
    addChild(node, condNode);
    push(parseStack, node);
}
    | NOT factor {
        treeNode *node = createNode("factor", NULL);
        addChild(node, createNode("NOT", "NOT"));
        treeNode *factorNode = pop(parseStack);
        addChild(node, factorNode);
        push(parseStack, node);
    }
    | LPAREN bool_exp RPAREN {
        treeNode *node = createNode("factor", NULL);
        addChild(node, createNode("LPAREN", "("));
        treeNode *boolExpNode = pop(parseStack);
        addChild(node, boolExpNode);
        addChild(node, createNode("RPAREN", ")"));
        push(parseStack, node);
    }
    | IDENTIFIER {
        treeNode *node = createNode("factor", NULL);
        addChild(node, createNode("IDENTIFIER", $<string>1));
        push(parseStack, node);
    }

printable: STRING {
    treeNode *node = createNode("printable", NULL);
    addChild(node, createNode("STRING", $<string>1));
    push(parseStack, node);
}
 | printable COMMA readable {
    treeNode *node = createNode("printable", NULL);
    treeNode *printableNode = pop(parseStack);
    addChild(node, printableNode);
    addChild(node, createNode("COMMA", ","));
    treeNode *readableNode = pop(parseStack);
    addChild(node, readableNode);
    push(parseStack, node);
 } | printable COMMA STRING {
    treeNode *node = createNode("printable", NULL);
    treeNode *printableNode = pop(parseStack);
    addChild(node, printableNode);
    addChild(node, createNode("COMMA", ","));
    addChild(node, createNode("STRING", $<string>3));
    push(parseStack, node);
 
 } | arith_expression {
    treeNode *node = createNode("printable", NULL);
    treeNode *arithExpressionNode = pop(parseStack);
    addChild(node, arithExpressionNode);
    push(parseStack, node);
 
 }
range: TO {
    treeNode *node = createNode("range", NULL);
    addChild(node, createNode("TO", "TO"));
    push(parseStack, node);
}
    | DOWNTO {
        treeNode *node = createNode("range", NULL);
        addChild(node, createNode("DOWNTO", "DOWNTO"));
        push(parseStack, node);
    
}

cond: arith_expression RELOP arith_expression {
    treeNode *node = createNode("cond", NULL);
    treeNode *arithExpressionNode1 = pop(parseStack);
    addChild(node, arithExpressionNode1);
    addChild(node, createNode("RELOP", $<string>2));
    treeNode *arithExpressionNode2 = pop(parseStack);
    addChild(node, arithExpressionNode2);
    push(parseStack, node);
}

nonEmptySrcWithIf:  {
        treeNode *node = createNode("nonEmptySrcWithIf", NULL);
        push(parseStack, node);
}
    | ruleWithIf srcWithIf {
        treeNode *node = createNode("nonEmptySrcWithIf", NULL);
        treeNode *ruleWithIfNode = pop(parseStack);
        addChild(node, ruleWithIfNode);
        treeNode *srcWithIfNode = pop(parseStack);
        addChild(node, srcWithIfNode);
        push(parseStack, node);
    }
srcWithIf: {
    treeNode *node = createNode("srcWithIf", NULL);
    push(parseStack, node);
}
    | ruleWithIf srcWithIf {
        treeNode *node = createNode("srcWithIf", NULL);
        treeNode *ruleWithIfNode = pop(parseStack);
        addChild(node, ruleWithIfNode);
        treeNode *srcWithIfNode = pop(parseStack);
        addChild(node, srcWithIfNode);
        push(parseStack, node);
}

ruleWithIf: WRITE LPAREN printable RPAREN SEMICOLON {
    treeNode *node = createNode("ruleWithIf", NULL);
    addChild(node, createNode("WRITE", "WRITE"));
    addChild(node, createNode("LPAREN", "("));
    treeNode *printableNode = pop(parseStack);
    addChild(node, printableNode);
    addChild(node, createNode("RPAREN", ")"));
    addChild(node, createNode("SEMICOLON", ";"));
    push(parseStack, node);
}
    | READ LPAREN readable RPAREN SEMICOLON {
        treeNode *node = createNode("ruleWithIf", NULL);
        addChild(node, createNode("READ", "READ"));
        addChild(node, createNode("LPAREN", "("));
        treeNode *readableNode = pop(parseStack);
        addChild(node, readableNode);
        addChild(node, createNode("RPAREN", ")"));
        addChild(node, createNode("SEMICOLON", ";"));
        push(parseStack, node);
    }
    | ifCond {
        treeNode *node = createNode("ruleWithIf", NULL);
        treeNode *ifCondNode = pop(parseStack);
        addChild(node, ifCondNode);
        push(parseStack, node);
    }
    | forLoopWithIf {
        treeNode *node = createNode("ruleWithIf", NULL);
        treeNode *forLoopWithIfNode = pop(parseStack);
        addChild(node, forLoopWithIfNode);
        push(parseStack, node);
    }
    | whileLoopWithIf {
        treeNode *node = createNode("ruleWithIf", NULL);
        treeNode *whileLoopWithIfNode = pop(parseStack);
        addChild(node, whileLoopWithIfNode);
        push(parseStack, node);
    }
    | assignment {
        treeNode *node = createNode("ruleWithIf", NULL);
        treeNode *assignmentNode = pop(parseStack);
        addChild(node, assignmentNode);
        push(parseStack, node);
    }
    | BEG nonEmptySrcWithIf END {
        treeNode *node = createNode("ruleWithIf", NULL);
        addChild(node, createNode("BEG", "BEGIN"));
        treeNode *nonEmptySrcWithIfNode = pop(parseStack);
        addChild(node, nonEmptySrcWithIfNode);
        addChild(node, createNode("END", "END"));
        push(parseStack, node);
    }

nonsrcWithIf: 
    | nonIf nonsrcWithIf {
        treeNode *node = createNode("nonsrcWithIf", NULL);
        treeNode *nonIfNode = pop(parseStack);
        addChild(node, nonIfNode);
        treeNode *nonsrcWithIfNode = pop(parseStack);
        addChild(node, nonsrcWithIfNode);
        push(parseStack, node);
    
    }

nonIf: WRITE LPAREN printable RPAREN SEMICOLON {
    treeNode *node = createNode("nonIf", NULL);
    addChild(node, createNode("WRITE", "WRITE"));
    addChild(node, createNode("LPAREN", "("));
    treeNode *printableNode = pop(parseStack);
    addChild(node, printableNode);
    addChild(node, createNode("RPAREN", ")"));
    addChild(node, createNode("SEMICOLON", ";"));
    push(parseStack, node);
}
    | READ LPAREN readable RPAREN SEMICOLON {
        treeNode *node = createNode("nonIf", NULL);
        addChild(node, createNode("READ", "READ"));
        addChild(node, createNode("LPAREN", "("));
        treeNode *readableNode = pop(parseStack);
        addChild(node, readableNode);
        addChild(node, createNode("RPAREN", ")"));
        addChild(node, createNode("SEMICOLON", ";"));
        push(parseStack, node);
    }
    | forLoopWithIf {
        treeNode *node = createNode("nonIf", NULL);
        treeNode *forLoopWithIfNode = pop(parseStack);
        addChild(node, forLoopWithIfNode);
        push(parseStack, node);
    }
    | whileLoopWithIf {
        treeNode *node = createNode("nonIf", NULL);
        treeNode *whileLoopWithIfNode = pop(parseStack);
        addChild(node, whileLoopWithIfNode);
        push(parseStack, node);
    }
    | assignment {
        treeNode *node = createNode("nonIf", NULL);
        treeNode *assignmentNode = pop(parseStack);
        addChild(node, assignmentNode);
        push(parseStack, node);
    }
    | BEG nonEmptySrcWithIf END {
        treeNode *node = createNode("nonIf", NULL);
        addChild(node, createNode("BEG", "BEGIN"));
        treeNode *nonEmptySrcWithIfNode = pop(parseStack);
        addChild(node, nonEmptySrcWithIfNode);
        addChild(node, createNode("END", "END"));
        push(parseStack, node);
    }

readable: IDENTIFIER {
    treeNode *node = createNode("readable", NULL);
    addChild(node, createNode("IDENTIFIER", $<string>1));
    push(parseStack, node);
}
    | IDENTIFIER LBRACKET indexing RBRACKET {
        treeNode *node = createNode("readable", NULL);
        addChild(node, createNode("IDENTIFIER", $<string>1));
        addChild(node, createNode("LBRACKET", "["));
        addChild(node, createNode("indexing", $<string>3));
        addChild(node, createNode("RBRACKET", "]"));
        push(parseStack, node);
    }

indexing: IDENTIFIER {
    treeNode *node = createNode("indexing", NULL);
    addChild(node, createNode("IDENTIFIER", $<string>1));
    push(parseStack, node);
}
    | INTLITERAL {
        treeNode *node = createNode("indexing", NULL);
        addChild(node, createNode("INTLITERAL", $<string>1));
        push(parseStack, node);
    }

ifCond: IF conditionals THEN BEG matched END SEMICOLON {
    treeNode *node = createNode("ifCond", NULL);
    addChild(node, createNode("IF", "IF"));
    treeNode *conditionalsNode = pop(parseStack);
    addChild(node, conditionalsNode);
    addChild(node, createNode("THEN", "THEN"));
    addChild(node, createNode("BEG", "BEGIN"));
    treeNode *matchedNode = pop(parseStack);
    addChild(node, matchedNode);
    addChild(node, createNode("END", "END"));
    addChild(node, createNode("SEMICOLON", ";"));
    push(parseStack, node);
}
    | IF conditionals THEN BEG matched END ELSE BEG tail END SEMICOLON {
        treeNode *node = createNode("ifCond", NULL);
        addChild(node, createNode("IF", "IF"));
        treeNode *conditionalsNode = pop(parseStack);
        addChild(node, conditionalsNode);
        addChild(node, createNode("THEN", "THEN"));
        addChild(node, createNode("BEG", "BEGIN"));
        treeNode *matchedNode = pop(parseStack);
        addChild(node, matchedNode);
        addChild(node, createNode("END", "END"));
        addChild(node, createNode("ELSE", "ELSE"));
        addChild(node, createNode("BEG", "BEGIN"));
        treeNode *tailNode = pop(parseStack);
        addChild(node, tailNode);
        addChild(node, createNode("END", "END"));
        addChild(node, createNode("SEMICOLON", ";"));
        push(parseStack, node);
    }
matched: IF conditionals THEN BEG matched END ELSE BEG matched END SEMICOLON {
    treeNode *node = createNode("matched", NULL);
    addChild(node, createNode("IF", "IF"));
    treeNode *conditionalsNode = pop(parseStack);
    addChild(node, conditionalsNode);
    addChild(node, createNode("THEN", "THEN"));
    addChild(node, createNode("BEG", "BEGIN"));
    treeNode *matchedNode1 = pop(parseStack);
    addChild(node, matchedNode1);
    addChild(node, createNode("END", "END"));
    addChild(node, createNode("ELSE", "ELSE"));
    addChild(node, createNode("BEG", "BEGIN"));
    treeNode *matchedNode2 = pop(parseStack);
    addChild(node, matchedNode2);
    addChild(node, createNode("END", "END"));
    addChild(node, createNode("SEMICOLON", ";"));
    push(parseStack, node);
} | nonsrcWithIf {
    treeNode *node = createNode("matched", NULL);
    treeNode *nonsrcWithIfNode = pop(parseStack);
    addChild(node, nonsrcWithIfNode);
    push(parseStack, node);

}
tail: IF conditionals THEN BEG tail END SEMICOLON {
    treeNode *node = createNode("tail", NULL);
    addChild(node, createNode("IF", "IF"));
    treeNode *conditionalsNode = pop(parseStack);
    addChild(node, conditionalsNode);
    addChild(node, createNode("THEN", "THEN"));
    addChild(node, createNode("BEG", "BEGIN"));
    treeNode *tailNode = pop(parseStack);
    addChild(node, tailNode);
    addChild(node, createNode("END", "END"));
    addChild(node, createNode("SEMICOLON", ";"));
    push(parseStack, node);
} | nonsrcWithIf {
    treeNode *node = createNode("tail", NULL);
    treeNode *nonsrcWithIfNode = pop(parseStack);
    addChild(node, nonsrcWithIfNode);
    push(parseStack, node);

}

forLoopWithIf: FOR IDENTIFIER ASGOP arith_expression range arith_expression DO BEG nonEmptySrcWithIf END SEMICOLON {
    treeNode *node = createNode("forLoopWithIf", NULL);
    addChild(node, createNode("FOR", "FOR"));
    addChild(node, createNode("IDENTIFIER", $<string>2));
    addChild(node, createNode("ASGOP", ":="));
    treeNode *arithExpressionNode1 = pop(parseStack);
    addChild(node, arithExpressionNode1);
    addChild(node, createNode("range", $<string>5));
    treeNode *arithExpressionNode2 = pop(parseStack);
    addChild(node, arithExpressionNode2);
    addChild(node, createNode("DO", "DO"));
    addChild(node, createNode("BEG", "BEGIN"));
    treeNode *nonEmptySrcWithIfNode = pop(parseStack);
    addChild(node, nonEmptySrcWithIfNode);
    addChild(node, createNode("END", "END"));
    addChild(node, createNode("SEMICOLON", ";"));
    push(parseStack, node);

}
whileLoopWithIf: WHILE conditionals DO BEG nonEmptySrcWithIf END SEMICOLON {
    treeNode *node = createNode("whileLoopWithIf", NULL);
    addChild(node, createNode("WHILE", "WHILE"));
    treeNode *conditionalsNode = pop(parseStack);
    addChild(node, conditionalsNode);
    addChild(node, createNode("DO", "DO"));
    addChild(node, createNode("BEG", "BEGIN"));
    treeNode *nonEmptySrcWithIfNode = pop(parseStack);
    addChild(node, nonEmptySrcWithIfNode);
    addChild(node, createNode("END", "END"));
    addChild(node, createNode("SEMICOLON", ";"));
    push(parseStack, node);

}

conditionals: bool_exp {
    treeNode *node = createNode("conditionals", NULL);
    treeNode *boolExpNode = pop(parseStack);
    addChild(node, boolExpNode);
    push(parseStack, node);
}


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




