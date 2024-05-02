%{
    #include <stdio.h>
    #include <ctype.h>
    #include <string.h>
    #include <stdlib.h>
    #include "helper.c"
    int yylex();
    extern FILE *yyin;
    void yyerror();

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

    eval_src(srcNode);
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
                    temp->startIndex = atoi($<string>5);
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
    | arith_expression COMMA printable {
        treeNode *printableNode = pop(parseStack);
        treeNode *arithExpressionNode = pop(parseStack);

        treeNode *node = createNode("printable", NULL);

        addChild(node, arithExpressionNode);
        addChild(node, createNode("COMMA", ","));
        addChild(node, printableNode);

        push(parseStack, node);
    } 
    | STRING COMMA printable {
        treeNode *printableNode = pop(parseStack);

        treeNode *node = createNode("printable", NULL);
        
        addChild(node, createNode("STRING", $<string>1));
        addChild(node, createNode("COMMA", ","));
        addChild(node, printableNode);

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

ifCond: IF bool_exp THEN BEG src END SEMICOLON {
        treeNode *srcNode = pop(parseStack);
        treeNode *boolExpNode = pop(parseStack);

        treeNode *node = createNode("ifCond", NULL);

        addChild(node, createNode("IF", "IF"));
        addChild(node, boolExpNode);
        addChild(node, createNode("THEN", "THEN"));
        addChild(node, createNode("BEG", "BEGIN"));
        addChild(node, srcNode);
        addChild(node, createNode("END", "END"));
        addChild(node, createNode("SEMICOLON", ";"));
        
        push(parseStack, node);
    }
    | IF bool_exp THEN BEG src END ELSE BEG src END SEMICOLON {
        treeNode *srcNode2 = pop(parseStack);
        treeNode *srcNode = pop(parseStack);
        treeNode *boolExpNode = pop(parseStack);

        treeNode *node = createNode("ifCond", NULL);

        addChild(node, createNode("IF", "IF"));
        addChild(node, boolExpNode);
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
    treeNode *arithExpressionNode2 = pop(parseStack);
    treeNode *rangeNode = pop(parseStack);
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

whileLoop: WHILE bool_exp DO BEG src END SEMICOLON {
    treeNode *srcNode = pop(parseStack);
    treeNode *boolExpNode = pop(parseStack);

    treeNode *node = createNode("whileLoop", NULL);

    addChild(node, createNode("WHILE", "WHILE"));
    addChild(node, boolExpNode);
    addChild(node, createNode("DO", "DO"));
    addChild(node, createNode("BEG", "BEGIN"));
    addChild(node, srcNode);
    addChild(node, createNode("END", "END"));
    addChild(node, createNode("SEMICOLON", ";"));

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
    /* freopen("log.txt", "w", stdout); */
    parseStack = createStack();
    symbolTable = createSymbolTable();
    yyin = fopen("sample.txt", "r");
    yyparse();
    printSymbolTable(symbolTable);
    fclose(yyin);
}

void yyerror(char *s){
    printf("syntax error\n");
    exit(1);
}




