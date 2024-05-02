%{
    #include <stdio.h>
    #include <ctype.h>
    #include <string.h>
    #include <stdlib.h>
    int yylex();
    extern FILE *yyin;
    void yyerror();
    typedef struct treeNode treeNode;
    typedef struct stackLinkedList stackLinkedList;

    struct stackLinkedList{
        treeNode *node;
        stackLinkedList *next;
    };

    int lengthOfStackLinkedList(stackLinkedList *list){
        int length = 0;
        stackLinkedList *temp = list;
        while(temp != NULL){
            length++;
            temp = temp->next;
        }
        return length;
    }

    struct treeNode{
        char *nonTerminal;
        char *terminal;
        treeNode *parent;
        stackLinkedList *children;
    };

    treeNode *createNode(char *nonTerminal, char *terminal){
        treeNode *node = (treeNode *)malloc(sizeof(treeNode));
        node->nonTerminal = nonTerminal;
        node->terminal = terminal;
        node->parent = NULL;
        node->children = NULL;
        return node;
    }

    stackLinkedList *createStackLinkedList(treeNode *node){
        stackLinkedList *list = (stackLinkedList *)malloc(sizeof(stackLinkedList));
        list->node = node;
        list->next = NULL;
        return list;
    }

    void addToStackLinkedList(stackLinkedList *list, treeNode *node){
        stackLinkedList *temp = list;
        while(temp->next != NULL){
            temp = temp->next;
        }
        temp->next = createStackLinkedList(node);
    }

    void addChild(treeNode *parent, treeNode *child){
        if(parent->children == NULL){
            parent->children = createStackLinkedList(child);
        }
        else{
            addToStackLinkedList(parent->children, child);
        }
        child->parent = parent;
        return;
    }
 
    typedef struct{
        stackLinkedList *top;
    } stack;

    stack *createStack(){
        stack *newStack = (stack *)malloc(sizeof(stack));
        if (newStack == NULL)
        {
            printf("Memory allocation failed.\n");
            exit(1);
        }
        newStack->top = NULL;
        return newStack;
    }
    int isEmpty(stack *s){
        return s->top == NULL;
    }
    void push(stack *s, treeNode *node){
        stackLinkedList *newNode = (stackLinkedList *)malloc(sizeof(stackLinkedList));
        if (newNode == NULL)
        {
            printf("Memory allocation failed.\n");
            exit(1);
        }
        newNode->node = node;
        newNode->next = s->top;
        s->top = newNode;
    }
    treeNode *pop(stack *s){
        if (isEmpty(s))
        {
            printf("Stack underflow.\n");
            exit(1);
            return NULL;
        }
        stackLinkedList *temp = s->top;
        treeNode *poppedNode = temp->node;
        s->top = temp->next;
        return poppedNode;
    }

    stack *parseStack;

    typedef struct symbolTableNode symbolTableNode;

    struct symbolTableNode{
        char *name;
        char type;
        int isArray;
        int arraySize;
        float floatValue;
        int intValue;
        char charValue;
        int boolValue;
        int *intArray;
        float *floatArray;
        char *charArray;
        int *boolArray;
        symbolTableNode *next;
    };

    symbolTableNode *symbolTable;

    symbolTableNode *createSymbolTableNode(char *name, char type){
        symbolTableNode *node = (symbolTableNode *)malloc(sizeof(symbolTableNode));
        node->name = name;
        node->type = type;
        node->isArray = 0;
        node->arraySize = 0;
        node->floatValue = 0;
        node->intValue = 0;
        node->charValue = '\0';
        node->boolValue = 0;
        node->intArray = NULL;
        node->floatArray = NULL;
        node->charArray = NULL;
        node->boolArray = NULL;
        node->next = NULL;
        return node;
    }

    void addToSymbolTable(symbolTableNode *table, symbolTableNode *node){
        symbolTableNode *temp = table;
        while(temp->next != NULL){
            temp = temp->next;
        }
        temp->next = node;
    }

    symbolTableNode *searchSymbolTable(symbolTableNode *table, char *name){
        symbolTableNode *temp = table;
        while(temp != NULL){
            if(strcmp(temp->name, name) == 0){
                return temp;
            }
            temp = temp->next;
        }
        return NULL;
    }


    symbolTableNode *createSymbolTable(){
        symbolTableNode *table = (symbolTableNode *)malloc(sizeof(symbolTableNode));
        table->name = "global";
        table->type = 'g';
        table->next = NULL;
        return table;
    }

    void printSymbolTable(symbolTableNode *table){
        symbolTableNode *temp = table;
        if (temp->next == NULL)
        {
            printf("Symbol table is empty.\n");
        }
        else
        {
            printf("Symbol table:\n");
            temp = temp->next;
        }
        while(temp != NULL){
            printf("%s\t", temp->name);
            if(temp->isArray){
                printf("array of ");
                if(temp->type == 'i'){
                    printf("int\t");
                }
                else if(temp->type == 'r'){
                    printf("real\t");
                }
                else if(temp->type == 'c'){
                    printf("char\t");
                }
                else if(temp->type == 'b'){
                    printf("bool\t");
                }
            }
            else{
                if(temp->type == 'i'){
                    printf("int\t\t");
                }
                else if(temp->type == 'r'){
                    printf("real\t\t");
                }
                else if(temp->type == 'c'){
                    printf("char\t\t");
                }
                else if(temp->type == 'b'){
                    printf("bool\t\t");
                }
            }
            if (temp->isArray)
            {
                if (temp->type == 'i')
                {
                    for (int i = 0; i < temp->arraySize; i++)
                    {
                        printf("%d ", temp->intArray[i]);
                    }
                    printf("\n");
                }
                else if (temp->type == 'r')
                {
                    for (int i = 0; i < temp->arraySize; i++)
                    {
                        printf("%f ", temp->floatArray[i]);
                    }
                    printf("\n");
                }
                else if (temp->type == 'c')
                {
                    for (int i = 0; i < temp->arraySize; i++)
                    {
                        printf("%c ", temp->charArray[i]);
                    }
                    printf("\n");
                }
                else if (temp->type == 'b')
                {
                    for (int i = 0; i < temp->arraySize; i++)
                    {
                        printf("%d ", temp->boolArray[i]);
                    }
                    printf("\n");
                }
            }
            else
            {
                if (temp->type == 'i')
                {
                    printf("%d\n", temp->intValue);
                }
                else if (temp->type == 'r')
                {
                    printf("%f\n", temp->floatValue);
                }
                else if (temp->type == 'c')
                {
                    printf("%c\n", temp->charValue);
                }
                else if (temp->type == 'b')
                {
                    printf("%d\n", temp->boolValue);
                }
            }
            temp = temp->next;
        }
    }

    int eval_arith_expression(treeNode *node);

    int eval_readable(treeNode *node){
        if(lengthOfStackLinkedList(node->children) == 1){
            symbolTableNode *temp = searchSymbolTable(symbolTable, node->children->node->terminal);
            if(temp != NULL){
                if(temp->type == 'i'){
                    return temp->intValue;
                }
                else if(temp->type == 'c'){
                    return (int)temp->charValue;
                }
                else if(temp->type == 'b'){
                    return temp->boolValue;
                }
            }
        }
        else{
            symbolTableNode *temp = searchSymbolTable(symbolTable, node->children->node->terminal);
            if(temp != NULL){
                if(temp->type == 'i'){
                    return temp->intArray[eval_arith_expression(node->children->next->next->node->children->node)];
                }
                else if(temp->type == 'c'){
                    return (int)temp->charArray[eval_arith_expression(node->children->next->next->node->children->node)];
                }
                else if(temp->type == 'b'){
                    return temp->boolArray[eval_arith_expression(node->children->next->next->node->children->node)];
                }
            }

        }
    }


    int eval_fExpression(treeNode *node){
        if (lengthOfStackLinkedList(node->children) == 1)
        {
            if(strcmp(node->children->node->nonTerminal, "INTLITERAL") == 0){
                return atoi(node->children->node->terminal);
            }
            if(strcmp(node->children->node->nonTerminal, "CHAR_LIT") == 0){
                return (int)(node->children->node->terminal[1]);
            }
            if(strcmp(node->children->node->nonTerminal, "readable") == 0){
                return eval_readable(node->children->node);
            }
            
        }
        else
        {
            
        }
    }

    int eval_tExpression(treeNode *node){
        if(lengthOfStackLinkedList(node->children) == 1){
            return eval_fExpression(node->children->node);
        }
        else{

        }
    }

    int eval_arith_expression(treeNode *node){
        if(lengthOfStackLinkedList(node->children) == 1){
            return eval_tExpression(node->children->node);
        }
        else{

        }
    }

    int eval_expression(treeNode *node){
        if(lengthOfStackLinkedList(node->children) == 1){
            return eval_arith_expression(node->children->node);
        }
        else{

        }
    }
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

        char *type = typeNode->children->node->terminal;
        char *childName;
        symbolTableNode *temp;
        treeNode *tempVars = varsNode;
        while(1){
            if (lengthOfStackLinkedList(tempVars->children) == 1)
            {
                childName = tempVars->children->node->terminal;
                temp = searchSymbolTable(symbolTable, childName);
                if (temp != NULL)
                {
                    temp->type = tolower(type[0]);
                }
                break;
            }
            else
            {
                childName = tempVars->children->next->next->node->terminal;
                temp = searchSymbolTable(symbolTable, childName);
                if (temp != NULL)
                {
                    temp->type = tolower(type[0]);
                }
                tempVars = tempVars->children->node;
            }
        }
        
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

        char *type = typeNode->children->node->terminal;
        char *childName;
        symbolTableNode *temp;
        treeNode *tempVars = varsNode;
        while(1){
            if (lengthOfStackLinkedList(tempVars->children) == 1)
            {
                childName = tempVars->children->node->terminal;
                temp = searchSymbolTable(symbolTable, childName);
                if (temp != NULL)
                {
                    temp->type = tolower(type[0]);
                    temp->isArray = 1;
                    temp->arraySize = atoi($<string>8) - atoi($<string>5) + 1;
                    if (temp->type == 'i')
                    {
                        temp->intArray = (int *)malloc(temp->arraySize * sizeof(int));
                    }
                    else if (temp->type == 'r')
                    {
                        temp->floatArray = (float *)malloc(temp->arraySize * sizeof(float));
                    }
                    else if (temp->type == 'c')
                    {
                        temp->charArray = (char *)malloc(temp->arraySize * sizeof(char));
                    }
                    else if (temp->type == 'b')
                    {
                        temp->boolArray = (int *)malloc(temp->arraySize * sizeof(int));
                    }
                }
                break;
            }
            else
            {
                childName = tempVars->children->next->next->node->terminal;
                temp = searchSymbolTable(symbolTable, childName);
                if (temp != NULL)
                {
                    temp->type = tolower(type[0]);
                }
                tempVars = tempVars->children->node;
            }
        }
    }

vars: vars COMMA IDENTIFIER {
        treeNode *varsNode = pop(parseStack);

        treeNode *node = createNode("vars", NULL);

        addChild(node, varsNode);
        addChild(node, createNode("COMMA", ","));
        addChild(node, createNode("IDENTIFIER", $<string>3));

        push(parseStack, node);

        // symbol table
        symbolTableNode *symbolNode = createSymbolTableNode($<string>3, 'i');
        addToSymbolTable(symbolTable, symbolNode);
    }
    | IDENTIFIER {
        treeNode *node = createNode("vars", NULL);

        addChild(node, createNode("IDENTIFIER", $<string>1));

        push(parseStack, node);

        // symbol table
        symbolTableNode *symbolNode = createSymbolTableNode($<string>1, 'i');
        addToSymbolTable(symbolTable, symbolNode);
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

        // symbol table
        symbolTableNode *temp = searchSymbolTable(symbolTable, $<string>1);
        if(temp != NULL){
            if (temp->type == 'i')
            {
                temp->intValue = eval_expression(expressionNode);
            }
            else if (temp->type == 'r')
            {
                temp->floatValue = eval_expression(expressionNode);
            }
            else if (temp->type == 'c')
            {
                temp->charValue = eval_expression(expressionNode);
            }
            else if (temp->type == 'b')
            {
                temp->boolValue = eval_expression(expressionNode);
            }
        }
    }
    | IDENTIFIER LBRACKET indexing RBRACKET ASGOP expression SEMICOLON {
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

        // symbol table
        symbolTableNode *temp = searchSymbolTable(symbolTable, $<string>1);
        int index = eval_arith_expression(indexingNode->children->node);
        if(temp != NULL){
            if (temp->type == 'i')
            {
                temp->intArray[index] = eval_expression(expressionNode);
            }
            else if (temp->type == 'r')
            {
                temp->floatArray[index] = eval_expression(expressionNode);
            }
            else if (temp->type == 'c')
            {
                temp->charArray[index] = eval_expression(expressionNode);
            }
            else if (temp->type == 'b')
            {
                temp->boolValue = eval_expression(expressionNode);
            }
        }
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
    for (stackLinkedList *temp = root->children; temp != NULL; temp = temp->next){
        printTree(temp->node);
    }
    printf("]");
}

void main(){
    freopen("log.txt", "w", stdout);
    parseStack = createStack();
    symbolTable = createSymbolTable();
    yyin = fopen("sample.txt", "r");
    yyparse();
    printf("valid input\n");
    printSymbolTable(symbolTable);
    fclose(yyin);
}

void yyerror(char *s){
    printf("syntax error\n");
    exit(1);
}




