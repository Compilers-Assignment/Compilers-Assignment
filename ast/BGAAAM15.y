%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    int yylex();
    extern FILE *yyin;
    void yyerror();
    typedef struct treeNode treeNode;
    typedef struct linkedList linkedList;

    int pushes = 0;
    int pops = 0;

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
        printf("---------------------------------------------------\n");
        printf("Creating node\n");
        printf("Non terminal: %s\n", nonTerminal);
        printf("Terminal: %s\n", terminal);
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
        printf("---------------------------------------------------\n");
        printf("Adding child\n");
        printf("Parent non terminal: %s\n", parent->nonTerminal);
        printf("Parent terminal: %s\n", parent->terminal);
        printf("Child non terminal: %s\n", child->nonTerminal);
        printf("Child terminal: %s\n", child->terminal);
        if(parent->children == NULL){
            printf("Creating list\n");
            parent->children = createList(child);
        }
        else{
            printf("Adding to list\n");
            addToLinkedList(parent->children, child);
        }
        child->parent = parent;
        return;
    }
 
    typedef struct
    {
        linkedList *top;
    } stack;

    stack *createStack()
    {
        printf("---------------------------------------------------\n");
        printf("Creating stack\n");
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
        printf("---------------------------------------------------\n");
        printf("Checking if stack is empty\n");
        return s->top == NULL;
    }
    void push(stack *s, treeNode *node)
    {
        printf("---------------------------------------------------\n");
        printf("Pushing to stack\n");
        printf("Non terminal: %s\n", node->nonTerminal);
        printf("Terminal: %s\n", node->terminal);
        linkedList *newNode = (linkedList *)malloc(sizeof(linkedList));
        if (newNode == NULL)
        {
            printf("Memory allocation failed.\n");
            exit(1);
        }
        newNode->node = node;
        newNode->next = s->top;
        s->top = newNode;
        pushes++;
        printf("%d %d\n", pushes, pops);
    }
    treeNode *pop(stack *s)
    {
        printf("---------------------------------------------------\n");
        printf("Popping from stack\n");
        if (isEmpty(s))
        {
            printf("Stack underflow.\n");
            exit(1);
            return NULL;
        }
        linkedList *temp = s->top;
        treeNode *poppedNode = temp->node;
        s->top = temp->next;
        printf("Popped node\n");
        printf("Non terminal: %s\n", poppedNode->nonTerminal);
        printf("Terminal: %s\n", poppedNode->terminal);
        pops++;
        printf("%d %d\n", pushes, pops);
        return poppedNode;
    }

    stack *parseStack;
%}

%token PROGRAM INTEGER REAL BOOLEAN CHAR TO DOWNTO IF ELSE VAR WHILE FOR DO ARRAY BEG END READ WRITE THEN AND OR NOT INTLITERAL IDENTIFIER ADDOP MULOP RELOP ASGOP SEMICOLON COLON LBRACKET RBRACKET COMMA LPAREN RPAREN PERIOD STRING OF CHAR_LIT

%union{
    char *string;
    int integer;
}

%%

start: PROGRAM IDENTIFIER SEMICOLON body {
    treeNode *bodyNode = pop(parseStack);

    treeNode *node = createNode("start", NULL);

    addChild(node, createNode("PROGRAM", "PROGRAM"));
    addChild(node, createNode("IDENTIFIER", $<string>2));
    addChild(node, createNode("SEMICOLON", ";"));
    addChild(node, bodyNode);

    push(parseStack, node);
}

body: VAR declList BEG src END PERIOD {
    treeNode *srcNode = pop(parseStack);
    treeNode *declListNode = pop(parseStack);

    treeNode *node = createNode("body", NULL);

    addChild(node, createNode("VAR", "VAR"));
    addChild(node, declListNode);
    addChild(node, createNode("BEG", "BEGIN"));
    addChild(node, srcNode);
    addChild(node, createNode("END", "END"));
    addChild(node, createNode("PERIOD", "."));

    push(parseStack, node);
}

declList:   {
                treeNode *node = createNode("declList", NULL);

                push(parseStack, node);
        }
        | decl declList {
            treeNode *declListNode = pop(parseStack);
            treeNode *declNode = pop(parseStack);

            treeNode *node = createNode("declList", NULL);

            addChild(node, declNode);
            addChild(node, declListNode);

            push(parseStack, node);
        }

decl: vars COLON type SEMICOLON  {
        treeNode *typeNode = pop(parseStack);
        treeNode *varsNode = pop(parseStack);

        treeNode *node = createNode("decl", NULL);

        addChild(node, varsNode);
        addChild(node, createNode("COLON", ":"));
        addChild(node, typeNode);
        addChild(node, createNode("SEMICOLON", ";"));

        push(parseStack, node);
    }
    | vars COLON ARRAY LBRACKET INTLITERAL PERIOD PERIOD INTLITERAL RBRACKET OF type SEMICOLON {
        treeNode *typeNode = pop(parseStack);    
        treeNode *varsNode = pop(parseStack);
        
        treeNode *node = createNode("decl", NULL);
        
        addChild(node, varsNode);
        addChild(node, createNode("COLON", ":"));
        addChild(node, createNode("ARRAY", "ARRAY"));
        addChild(node, createNode("LBRACKET", "["));
        addChild(node, createNode("INTLITERAL", $<string>5));
        addChild(node, createNode("PERIOD", "."));
        addChild(node, createNode("PERIOD", "."));
        addChild(node, createNode("INTLITERAL", $<string>8));
        addChild(node, createNode("RBRACKET", "]"));
        addChild(node, createNode("OF", "OF"));
        addChild(node, typeNode);
        addChild(node, createNode("SEMICOLON", ";"));

        push(parseStack, node);
    }

vars: vars COMMA IDENTIFIER {
        treeNode *varsNode = pop(parseStack);

        treeNode *node = createNode("vars", NULL);

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
    treeNode *expressionNode = pop(parseStack);

    treeNode *node = createNode("assignment", NULL);

    addChild(node, createNode("IDENTIFIER", $<string>1));
    addChild(node, createNode("ASGOP", ":="));
    addChild(node, expressionNode);
    addChild(node, createNode("SEMICOLON", ";"));

    push(parseStack, node);
    } | IDENTIFIER LBRACKET indexing RBRACKET ASGOP expression SEMICOLON {
        treeNode *expressionNode = pop(parseStack);
        treeNode *indexingNode = pop(parseStack);

        treeNode *node = createNode("assignment", NULL);

        addChild(node, createNode("IDENTIFIER", $<string>1));
        addChild(node, createNode("LBRACKET", "["));
        addChild(node, indexingNode);
        addChild(node, createNode("RBRACKET", "]"));
        addChild(node, createNode("ASGOP", ":="));
        addChild(node, expressionNode);
        addChild(node, createNode("SEMICOLON", ";"));

        push(parseStack, node);
    }

expression: arith_expression {
        treeNode *arithExpressionNode = pop(parseStack);

        treeNode *node = createNode("expression", NULL);
        
        addChild(node, arithExpressionNode);
        
        push(parseStack, node);
    }
    | bool_exp {
        treeNode *boolExpNode = pop(parseStack);

        treeNode *node = createNode("expression", NULL);
        
        addChild(node, boolExpNode);

        push(parseStack, node);
    }

arith_expression: arith_expression ADDOP tExpression {
        treeNode *tExpressionNode = pop(parseStack);
        treeNode *arithExpressionNode = pop(parseStack);

        treeNode *node = createNode("arith_expression", NULL);
        
        addChild(node, arithExpressionNode);
        addChild(node, createNode("ADDOP", $<string>2));
        addChild(node, tExpressionNode);
        
        push(parseStack, node);
    }
    | tExpression {
        treeNode *tExpressionNode = pop(parseStack);

        treeNode *node = createNode("arith_expression", NULL);
        
        addChild(node, tExpressionNode);

        push(parseStack, node);
    }

tExpression: tExpression MULOP fExpression {
        treeNode *fExpressionNode = pop(parseStack);
        treeNode *tExpressionNode = pop(parseStack);

        treeNode *node = createNode("tExpression", NULL);
        
        addChild(node, tExpressionNode);
        addChild(node, createNode("MULOP", $<string>2));
        addChild(node, fExpressionNode);
        
        push(parseStack, node);
    }
    | fExpression {
        treeNode *fExpressionNode = pop(parseStack);

        treeNode *node = createNode("tExpression", NULL);
        
        addChild(node, fExpressionNode);

        push(parseStack, node);
    }

fExpression: LPAREN arith_expression RPAREN {
        treeNode *arithExpressionNode = pop(parseStack);

        treeNode *node = createNode("fExpression", NULL);

        addChild(node, createNode("LPAREN", "("));
        addChild(node, arithExpressionNode);
        addChild(node, createNode("RPAREN", ")"));

        push(parseStack, node);
    } 
    | readable {
        treeNode *readableNode = pop(parseStack);

        treeNode *node = createNode("fExpression", NULL);
        
        addChild(node, readableNode);

        push(parseStack, node);
    } 
    | INTLITERAL {
        treeNode *node = createNode("fExpression", NULL);

        addChild(node, createNode("INTLITERAL", $<string>1));

        push(parseStack, node);
    } 
    | CHAR_LIT {
        treeNode *node = createNode("fExpression", NULL);

        addChild(node, createNode("CHAR_LIT", $<string>1));

        push(parseStack, node);
    }

bool_exp: term {
        treeNode *termNode = pop(parseStack);

        treeNode *node = createNode("bool_exp", NULL);
        
        addChild(node, termNode);
        
        push(parseStack, node);
    }
    | bool_exp OR term {
        treeNode *termNode = pop(parseStack);
        treeNode *boolExpNode = pop(parseStack);

        treeNode *node = createNode("bool_exp", NULL);
        
        addChild(node, boolExpNode);
        addChild(node, createNode("OR", "OR"));
        addChild(node, termNode);

        push(parseStack, node);
    }

term: factor {
        treeNode *factorNode = pop(parseStack);

        treeNode *node = createNode("term", NULL);

        addChild(node, factorNode);

        push(parseStack, node);
    }
    | term AND factor {
        treeNode *factorNode = pop(parseStack);
        treeNode *termNode = pop(parseStack);

        treeNode *node = createNode("term", NULL);
        
        addChild(node, termNode);
        addChild(node, createNode("AND", "AND"));
        addChild(node, factorNode);

        push(parseStack, node);
    }

factor: cond {
        treeNode *condNode = pop(parseStack);

        treeNode *node = createNode("factor", NULL);
        
        addChild(node, condNode);

        push(parseStack, node);
    }
    | NOT factor {
        treeNode *factorNode = pop(parseStack);

        treeNode *node = createNode("factor", NULL);

        addChild(node, createNode("NOT", "NOT"));
        addChild(node, factorNode);

        push(parseStack, node);
    }
    | LPAREN bool_exp RPAREN {
        treeNode *boolExpNode = pop(parseStack);

        treeNode *node = createNode("factor", NULL);

        addChild(node, createNode("LPAREN", "("));
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
        treeNode *readableNode = pop(parseStack);
        treeNode *printableNode = pop(parseStack);

        treeNode *node = createNode("printable", NULL);

        addChild(node, printableNode);
        addChild(node, createNode("COMMA", ","));
        addChild(node, readableNode);

        push(parseStack, node);
    } 
    | printable COMMA STRING {
        treeNode *printableNode = pop(parseStack);

        treeNode *node = createNode("printable", NULL);
        
        addChild(node, printableNode);
        addChild(node, createNode("COMMA", ","));
        addChild(node, createNode("STRING", $<string>3));

        push(parseStack, node);
    } 
    | arith_expression {
        treeNode *arithExpressionNode = pop(parseStack);

        treeNode *node = createNode("printable", NULL);
        
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
    treeNode *arithExpressionNode2 = pop(parseStack);
    treeNode *arithExpressionNode1 = pop(parseStack);

    treeNode *node = createNode("cond", NULL);
    
    addChild(node, arithExpressionNode1);
    addChild(node, createNode("RELOP", $<string>2));
    addChild(node, arithExpressionNode2);

    push(parseStack, node);
}

src: {
        treeNode *node = createNode("src", NULL);

        push(parseStack, node);
    }
    | rule src {
        treeNode *srcNode = pop(parseStack);
        treeNode *ruleNode = pop(parseStack);

        treeNode *node = createNode("src", NULL);
        
        addChild(node, ruleNode);
        addChild(node, srcNode);

        push(parseStack, node);
    }

rule: WRITE LPAREN printable RPAREN SEMICOLON {
    treeNode *printableNode = pop(parseStack);

    treeNode *node = createNode("rule", NULL);

    addChild(node, createNode("WRITE", "WRITE"));
    addChild(node, createNode("LPAREN", "("));
    addChild(node, printableNode);
    addChild(node, createNode("RPAREN", ")"));
    addChild(node, createNode("SEMICOLON", ";"));

    push(parseStack, node);
    }
    | READ LPAREN readable RPAREN SEMICOLON {
        treeNode *readableNode = pop(parseStack);

        treeNode *node = createNode("rule", NULL);

        addChild(node, createNode("READ", "READ"));
        addChild(node, createNode("LPAREN", "("));
        addChild(node, readableNode);
        addChild(node, createNode("RPAREN", ")"));
        addChild(node, createNode("SEMICOLON", ";"));

        push(parseStack, node);
    }
    | ifCond {
        treeNode *ifCondNode = pop(parseStack);

        treeNode *node = createNode("rule", NULL);
        
        addChild(node, ifCondNode);

        push(parseStack, node);
    }
    | forLoop {
        treeNode *forLoopNode = pop(parseStack);

        treeNode *node = createNode("rule", NULL);
        
        addChild(node, forLoopNode);

        push(parseStack, node);
    }
    | whileLoop {
        treeNode *whileLoopNode = pop(parseStack);

        treeNode *node = createNode("rule", NULL);
        
        addChild(node, whileLoopNode);

        push(parseStack, node);
    }
    | assignment {
        treeNode *assignmentNode = pop(parseStack);

        treeNode *node = createNode("rule", NULL);
        
        addChild(node, assignmentNode);

        push(parseStack, node);
    }
    | BEG src END {
        treeNode *srcNode = pop(parseStack);

        treeNode *node = createNode("rule", NULL);

        addChild(node, createNode("BEG", "BEGIN"));
        addChild(node, srcNode);
        addChild(node, createNode("END", "END"));

        push(parseStack, node);
    }
  
readable: IDENTIFIER {
        treeNode *node = createNode("readable", NULL);

        addChild(node, createNode("IDENTIFIER", $<string>1));

        push(parseStack, node);
    }
    | IDENTIFIER LBRACKET indexing RBRACKET {
        treeNode *indexingNode = pop(parseStack);

        treeNode *node = createNode("readable", NULL);

        addChild(node, createNode("IDENTIFIER", $<string>1));
        addChild(node, createNode("LBRACKET", "["));
        addChild(node, indexingNode);
        addChild(node, createNode("RBRACKET", "]"));

        push(parseStack, node);
    }

indexing: arith_expression {
        treeNode *arithExpressionNode = pop(parseStack);

        treeNode *node = createNode("indexing", NULL);

        addChild(node, arithExpressionNode);

        push(parseStack, node);
    }

ifCond: IF conditionals THEN BEG src END SEMICOLON {
        treeNode *srcNode = pop(parseStack);
        treeNode *conditionalsNode = pop(parseStack);

        treeNode *node = createNode("ifCond", NULL);

        addChild(node, createNode("IF", "IF"));
        addChild(node, conditionalsNode);
        addChild(node, createNode("THEN", "THEN"));
        addChild(node, createNode("BEG", "BEGIN"));
        addChild(node, srcNode);
        addChild(node, createNode("END", "END"));
        addChild(node, createNode("SEMICOLON", ";"));
        
        push(parseStack, node);
    }
    | IF conditionals THEN BEG src END ELSE BEG src END SEMICOLON {
        treeNode *srcNode2 = pop(parseStack);
        treeNode *srcNode = pop(parseStack);
        treeNode *conditionalsNode = pop(parseStack);

        treeNode *node = createNode("ifCond", NULL);

        addChild(node, createNode("IF", "IF"));
        addChild(node, conditionalsNode);
        addChild(node, createNode("THEN", "THEN"));
        addChild(node, createNode("BEG", "BEGIN"));
        addChild(node, srcNode);
        addChild(node, createNode("END", "END"));
        addChild(node, createNode("ELSE", "ELSE"));
        addChild(node, createNode("BEG", "BEGIN"));
        addChild(node, srcNode2);
        addChild(node, createNode("END", "END"));
        addChild(node, createNode("SEMICOLON", ";"));

        push(parseStack, node);
    }

forLoop: FOR IDENTIFIER ASGOP arith_expression range arith_expression DO BEG src END SEMICOLON {
    treeNode *srcNode = pop(parseStack);
    treeNode *rangeNode = pop(parseStack);
    treeNode *arithExpressionNode2 = pop(parseStack);
    treeNode *arithExpressionNode1 = pop(parseStack);

    treeNode *node = createNode("forLoop", NULL);

    addChild(node, createNode("FOR", "FOR"));
    addChild(node, createNode("IDENTIFIER", $<string>2));
    addChild(node, createNode("ASGOP", ":="));
    addChild(node, arithExpressionNode1);
    addChild(node, rangeNode);
    addChild(node, arithExpressionNode2);
    addChild(node, createNode("DO", "DO"));
    addChild(node, createNode("BEG", "BEGIN"));
    addChild(node, srcNode);
    addChild(node, createNode("END", "END"));
    addChild(node, createNode("SEMICOLON", ";"));

    push(parseStack, node);
}

whileLoop: WHILE conditionals DO BEG src END SEMICOLON {
    treeNode *srcNode = pop(parseStack);
    treeNode *conditionalsNode = pop(parseStack);

    treeNode *node = createNode("whileLoop", NULL);

    addChild(node, createNode("WHILE", "WHILE"));
    addChild(node, conditionalsNode);
    addChild(node, createNode("DO", "DO"));
    addChild(node, createNode("BEG", "BEGIN"));
    addChild(node, srcNode);
    addChild(node, createNode("END", "END"));
    addChild(node, createNode("SEMICOLON", ";"));

    push(parseStack, node);
}

conditionals: bool_exp {
    treeNode *boolExpNode = pop(parseStack);

    treeNode *node = createNode("conditionals", NULL);
    
    addChild(node, boolExpNode);

    push(parseStack, node);
}


%%

void printTree(treeNode *root){
    printf("[");
    if(root->nonTerminal != NULL){
        printf("%s", root->nonTerminal);
    }
    if(root->terminal != NULL){
        printf(":{%s}", root->terminal);
    }
    for (linkedList *temp = root->children; temp != NULL; temp = temp->next){
        printTree(temp->node);
    }
    printf("]");
}

void main(){
    freopen("log.txt", "w", stdout);
    parseStack = createStack();
    yyin = fopen("sample.txt", "r");
    yyparse();
    printf("valid input\n");
    printTree(parseStack->top->node);
    fclose(yyin);
}

void yyerror(char *s){
    printf("syntax error\n");
    exit(1);
}




