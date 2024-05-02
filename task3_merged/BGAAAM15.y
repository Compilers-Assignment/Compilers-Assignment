%{
#include <stdio.h>

#include <string.h>

#include <stdlib.h>

#include <stdbool.h>

#include <ctype.h>

char **varNames = NULL; // Pointer to an array of string pointers
char **varTypes = NULL;
char **varValues = NULL;
int varCount = 0; // Number of variables currently stored
int typeCount = 0;
char safe[] = "NULL";
int varCapacity = 0; // Current capacity of the array
extern int yylineno;
int yylex();
void yyerror();
extern FILE *yyin;

void ensureCapacity(int minCapacity)
{
    if (minCapacity > varCapacity)
    {
        int newCapacity = varCapacity == 0 ? 4 : varCapacity * 2;
        if (newCapacity < minCapacity)
        {
            newCapacity = minCapacity;
        }
        char **newVarNames = realloc(varNames, newCapacity * sizeof(char *));
        char **newVarTypes = realloc(varTypes, newCapacity * sizeof(char *));
        char **newVarValues = realloc(varValues, newCapacity * sizeof(char *));
        // if (!newVarNames) {
        //     perror("Out of memory");
        //     exit(EXIT_FAILURE);
        // }
        varNames = newVarNames;
        varTypes = newVarTypes;
        varValues = newVarValues;
        for (int i = varCapacity; i < newCapacity; ++i)
        {
            varNames[i] = NULL; // Initialize new elements to NULL
            varTypes[i] = NULL;
            varValues[i] = strdup(safe);
        }
        varCapacity = newCapacity;
    }
}
int bracketCheck(const char *name)
{
    for (int i = 0; i < strlen(name); i++)
    {
        if (name[i] == '[')
        {
            return 1;
        }
    }
    return 0;
}

int addVariable(const char *name)
{

    for (int i = 0; i < varCount; i++)
    {
        if (strcmp(varNames[i], name) == 0 && !(bracketCheck(varNames[i])))
        {
            printf("Multiple declarations of variable: %s. ", name);
            yyerror(1);
            // perror("");
            return 0;
        }
    }

    ensureCapacity(varCount + 1);
    varNames[varCount] = strdup(name); // Duplicate the string to store it
    // if (!varNames[varCount]) {
    // perror("Out of memory");
    // exit(EXIT_FAILURE);
    // }
    varCount++;

    return 1;
}

void addVarType(const char *name)
{

    for (int i = typeCount; i < varCount; i++)
    {
        varTypes[i] = strdup(name); // Duplicate the string to store it
    }

    // if (!varNames[typeCount]) {
    // perror("Out of memory");
    // exit(EXIT_FAILURE);
    // }
    typeCount = varCount;
}

int checkVar(const char *name)
{ // this is for the undeclared variable error
    // printf("checkvar called for %s\n", name);
    bool flag = false;
    int j = -1;
    for (int i = 0; i < varCount; i++)
    {
        if (strcmp(varNames[i], name) == 0)
        {
            flag = true;
            j = i;
            break;
        }
    }

    if (!flag)
    {
        printf("undeclared variable: %s. ", name);
        yyerror(1);
    }
    return j;
}

void printVariableList()
{
    if (varNames == NULL || varCount == 0)
    {
        printf("No variables stored.\n");
        return;
    }

    printf("Current Variables List:\n");
    for (int i = 0; i < varCount; ++i)
    {
        if (varNames[i] != NULL)
        {
            printf("Variable & Type %d: %s %s %s\n", i + 1, varNames[i], varTypes[i], varValues[i]);
        }
        else
        {
            printf("Variable %d: [Unassigned]\n", i + 1);
        }
    }
}

void freeVariables()
{
    for (int i = 0; i < varCount; ++i)
    {
        free(varNames[i]);
    }
    free(varNames);
    varNames = NULL;
    varCount = 0;
    varCapacity = 0;
}

void arrayReplacement(int left, int right)
{
    int i = varCount - 1;
    while (i >= 0 && (strcmp(varTypes[i], "aint") == 0 ||
                      strcmp(varTypes[i], "abool") == 0 ||
                      strcmp(varTypes[i], "achar") == 0 ||
                      strcmp(varTypes[i], "areal") == 0))
    {
        char *baseName = varNames[i];
        char *baseType = varTypes[i] + 1; // Remove the 'a' prefix from the type

        for (int j = left; j <= right; j++)
        {
            // Allocate memory for the new variable name
            char *newVarName = malloc(strlen(baseName) + 16); // 16 for subscript and null terminator
            // if (newVarName == NULL) {
            //     perror("Out of memory");
            //     exit(EXIT_FAILURE);
            // }

            // Construct the new variable name with subscript
            sprintf(newVarName, "%s[%d]", baseName, j);

            // Add the new variable name and type to the lists
            addVariable(newVarName);
            addVarType(baseType);

            free(newVarName); // Free the temporary memory
        }

        i--;
    }
}

const char *type_to_string(char typeCode)
{
    switch (typeCode)
    {
    case 'c':
        return "character";
    case 'r':
        return "real";
    case 'b':
        return "boolean";
    case 'i':
        return "integer";
    default:
        return "unknown"; // Handle unexpected types
    }
}

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
        // printf("---------------------------------------------------\n");
        // printf("Creating node\n");
        // printf("Non terminal: %s\n", nonTerminal);
        // printf("Terminal: %s\n", terminal);
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
        // printf("---------------------------------------------------\n");
        // printf("Adding child\n");
        // printf("Parent non terminal: %s\n", parent->nonTerminal);
        // printf("Parent terminal: %s\n", parent->terminal);
        // printf("Child non terminal: %s\n", child->nonTerminal);
        // printf("Child terminal: %s\n", child->terminal);
        if(parent->children == NULL){
            // printf("Creating list\n");
            parent->children = createList(child);
        }
        else{
            // printf("Adding to list\n");
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
        // printf("---------------------------------------------------\n");
        // printf("Creating stack\n");
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
        // printf("---------------------------------------------------\n");
        // printf("Checking if stack is empty\n");
        return s->top == NULL;
    }
    void push(stack *s, treeNode *node)
    {
        // printf("---------------------------------------------------\n");
        // printf("Pushing to stack\n");
        // printf("Non terminal: %s\n", node->nonTerminal);
        // printf("3\n");
        // printf("Terminal: %s\n", node->terminal);
        // printf("1\n");
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
        // printf("%d %d\n", pushes, pops);
    }
    treeNode *pop(stack *s)
    {
        // printf("---------------------------------------------------\n");
        // printf("Popping from stack\n");
        if (isEmpty(s))
        {
            printf("Stack underflow.\n");
            exit(1);
            return NULL;
        }
        linkedList *temp = s->top;
        treeNode *poppedNode = temp->node;
        s->top = temp->next;
        // printf("Popped node\n");
        // printf("Non terminal: %s\n", poppedNode->nonTerminal);
        // printf("Terminal: %s\n", poppedNode->terminal);
        pops++;
        // printf("%d %d\n", pushes, pops);
        return poppedNode;
    }

    stack *parseStack;

%}

%token PROGRAM INTEGER REAL BOOLEAN CHAR TO DOWNTO IF ELSE VAR WHILE FOR DO ARRAY BEG END READ WRITE THEN AND OR NOT INTLITERAL IDENTIFIER ADDOP MULOP RELOP ASGOP SEMICOLON COLON LBRACKET RBRACKET COMMA LPAREN RPAREN PERIOD STRING OF CHAR_LIT

%union{
      
    char type;     
    struct {
       char *name;
       char *tp;
       int value;
       char *val;
    }test;
	char *string;
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

    | vars COLON ARRAY LBRACKET INTLITERAL PERIOD PERIOD INTLITERAL RBRACKET OF arraytype SEMICOLON {
        treeNode *arraytypeNode = pop(parseStack);    
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
        addChild(node, arraytypeNode);
        addChild(node, createNode("SEMICOLON", ";"));

        push(parseStack, node);

        int left = $<test.value>5; 
        int right = $<test.value>8;
        arrayReplacement(left, right);
    }

vars: vars COMMA IDENTIFIER {
        treeNode *varsNode = pop(parseStack);

        treeNode *node = createNode("vars", NULL);

        addChild(node, varsNode);
        addChild(node, createNode("COMMA", ","));
        addChild(node, createNode("IDENTIFIER", $<string>3));

        push(parseStack, node);

        if(addVariable($<test.name>3) == 0){}
    }

    | IDENTIFIER {
        treeNode *node = createNode("vars", NULL);

        addChild(node, createNode("IDENTIFIER", $<string>1));

        push(parseStack, node);

        if(addVariable($<test.name>1) == 0){}
    }

type: INTEGER {
        treeNode *node = createNode("type", NULL);

        addChild(node, createNode("INTEGER", "INTEGER"));
        
        push(parseStack, node);

        addVarType("int");
    }
    | REAL {
        treeNode *node = createNode("type", NULL);

        addChild(node, createNode("REAL", "REAL"));

        push(parseStack, node);

        addVarType("real");
    }
    | BOOLEAN {
        treeNode *node = createNode("type", NULL);

        addChild(node, createNode("BOOLEAN", "BOOLEAN"));

        push(parseStack, node);

        addVarType("bool");
    }
    | CHAR {
        treeNode *node = createNode("type", NULL);

        addChild(node, createNode("CHAR", "CHAR"));

        push(parseStack, node);

        addVarType("char");
    }

arraytype: INTEGER {
        treeNode *node = createNode("arraytype", NULL);

        addChild(node, createNode("INTEGER", "INTEGER"));
        
        push(parseStack, node);

        addVarType("aint");
    }
    | REAL {
        treeNode *node = createNode("arraytype", NULL);

        addChild(node, createNode("REAL", "REAL"));

        push(parseStack, node);

        addVarType("areal");
    }
    | BOOLEAN {
        treeNode *node = createNode("arraytype", NULL);

        addChild(node, createNode("BOOLEAN", "BOOLEAN"));

        push(parseStack, node);

        addVarType("abool");
    }
    | CHAR {
        treeNode *node = createNode("arraytype", NULL);

        addChild(node, createNode("CHAR", "CHAR"));

        push(parseStack, node);

        addVarType("achar");
    }

readable: IDENTIFIER {
        treeNode *node = createNode("readable", NULL);

        addChild(node, createNode("IDENTIFIER", $<string>1));

        push(parseStack, node);

        int j = checkVar($<test.name>1); 
        if(j != -1){
            $<test.val>$ = strdup(varValues[j]); 
            if(strcmp($<test.val>$, safe) == 0) 
            {
                if($<type>1 != 'i' && $<type>1 != 'b' && $<type>1 != 'r'){
                    // printf("%c ", $<type>1);
                    printf("Array identifier used without indexing - %s. ", $<test.name>1);
                    yyerror(1);
                }
                else{
                    printf("Variable %s used before it is assigned a value. ", $<test.name>1); 
                    yyerror(1);
                }
            }else{
                $<test.val>$ = strdup(varValues[j]); 
                $<type>$ = tolower(varTypes[j][0]);
            }
        }else{
            $<test.val>$ = "NULL";
        }
    }

    | IDENTIFIER LBRACKET indexing RBRACKET {
        treeNode *indexingNode = pop(parseStack);

        treeNode *node = createNode("readable", NULL);

        addChild(node, createNode("IDENTIFIER", $<string>1));
        addChild(node, createNode("LBRACKET", "["));
        addChild(node, indexingNode);
        addChild(node, createNode("RBRACKET", "]"));

        push(parseStack, node);

        char *str = strcat($<test.name>1, "[");
	    char *str2 = strdup($<test.val>3);
		if(strcmp(str2,"NULL")){
            char *str3 = strcat(str2, "]");
            char *newStr = strcat(str, str3);
            int j = checkVar(newStr);

            if(j!=-1){
                $<test.val>$ = varValues[j];
                if(strcmp($<test.val>$, safe) == 0) 
                {
                    printf("Variable %s used before it is assigned a value. ", $<test.name>1);
                    yyerror(1);
                }
                $<test.val>$ = strdup(varValues[j]);
                $<type>$ = tolower(varTypes[j][0]);
            }else{
                $<test.val>$ = "NULL";
            }
		}
    }

assignment: IDENTIFIER ASGOP expression SEMICOLON {
    treeNode *expressionNode = pop(parseStack);

    treeNode *node = createNode("assignment", NULL);

    addChild(node, createNode("IDENTIFIER", $<string>1));
    addChild(node, createNode("ASGOP", ":="));
    addChild(node, expressionNode);
    addChild(node, createNode("SEMICOLON", ";"));

    push(parseStack, node);

    int j = checkVar($<test.name>1);
    if (j != -1)
    {
        char *type1 = varTypes[j];
        int flag = 0;
        char *type2;
        switch ($<type>3)
        {
        case 'i':
            type2 = "int";
            break;
        case 'c':
            type2 = "char";
            break;
        case 'r':
            type2 = "real";
            break;
        case 'b':
            type2 = "bool";
            break;
        default:
            flag = 1;
            break;
        }

        if (flag == 0)
        {
            if (strcmp(type1, type2) != 0)
            {
                if (strcmp(type1, "real") == 0 && strcmp(type2, "int") == 0)
                {
                    varValues[j] = strdup($<test.val>3);
                }
                else
                {
                    if (type1[0] == 'a')
                    {
                        type1 = strdup("array");
                    }
                    printf("Type mismatch. Attempted to assign %s to %s. ", type2, type1);
                    yyerror(1);
                }
            }
            else
            {
                varValues[j] = strdup($<test.val>3);
            }
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

        char *str = strcat($<test.name>1, "[");
        char *str2 = strdup($<test.val>3);
        char *str3 = strcat(str2, "]");
        char *newStr = strcat(str, str3);
        int j = checkVar(newStr);
        if (j != -1)
        {
            char *type1 = varTypes[j];
            int flag = 0;

            char *type2;
            switch ($<type>6)
            {
            case 'i':
                type2 = "int";
                break;
            case 'c':
                type2 = "char";
                break;
            case 'r':
                type2 = "real";
                break;
            case 'b':
                type2 = "bool";
                break;
            default:
                flag = 1;
                break;
            }

            if (flag == 0)
            {
                if (strcmp(type1, type2) != 0)
                {
                    if (strcmp(type1, "real") == 0 && strcmp(type2, "int") == 0)
                    {
                        if ($<type>3 == 'i')
                        {
                            varValues[j] = strdup($<test.val>6);
                        }
                    }
                    else
                    {
                        printf("Type mismatch. Attempted to assign %s to %s. ", type2, type1);
                        yyerror(1);
                    }
                }
                else
                {
                    if ($<type>3 == 'i')
                    {
                        varValues[j] = strdup($<test.val>6);
                    }
                }
            }
        }
}

expression: arith_expression {
        treeNode *arithExpressionNode = pop(parseStack);

        treeNode *node = createNode("expression", NULL);
        
        addChild(node, arithExpressionNode);
        
        push(parseStack, node);

        $<test.val>$ = strdup($<test.val>1);
	    $<type>$ = $<type>1;
    }

    | bool_exp {
        treeNode *boolExpNode = pop(parseStack);

        treeNode *node = createNode("expression", NULL);
        
        addChild(node, boolExpNode);

        push(parseStack, node);

        $<test.val>$ = strdup($<test.val>1); 
        $<test.value>$ = $<test.value>1; 
        $<type>$ = $<type>1;
    }

arith_expression: arith_expression ADDOP tExpression {
        treeNode *tExpressionNode = pop(parseStack);
        treeNode *arithExpressionNode = pop(parseStack);

        treeNode *node = createNode("arith_expression", NULL);
        
        addChild(node, arithExpressionNode);
        addChild(node, createNode("ADDOP", $<string>2));
        addChild(node, tExpressionNode);
        
        push(parseStack, node);

        int flag=0;
        if (($<type>1 == 'i' && $<type>3 == 'r') || ($<type>1 == 'r' && $<type>3 == 'i'))
        {
        }
        else if ($<type>1 != $<type>3)
        {
            if (!(strcmp(type_to_string($<type>1), "unknown") == 0 || strcmp(type_to_string($<type>3), "unknown") == 0))
            {
                flag = 1;
                printf("Conflicting (%s) and (%s) used in RHS, at line number %d\n", type_to_string($<type>1), type_to_string($<type>3), yylineno);
            }
        }
        if(flag==0){
            if ($<type>1 != $<type>3)
            {
                $<type>$ = 'r';
            }
            else
            {
                $<type>$ = $<type>3;
            }
            char tempchar[25] = "NULL";
            int f = 0;
            if ($<type>$ == 'r')
            {
                float tempval;
                if (!strcmp($<string>2, "+"))
                {
                    if (strcmp($<test.val>1, "NULL") && strcmp($<test.val>3, "NULL"))
                    {
                        tempval = atof($<test.val>1) + atof($<test.val>3);
                    }
                    else
                    {
                        f = 1;
                    }
                }
                else if (!strcmp($<string>2, "-"))
                {
                    if (strcmp($<test.val>1, "NULL") && strcmp($<test.val>3, "NULL"))
                        tempval = atof($<test.val>1) - atof($<test.val>3);
                    else
                        f = 1;
                }
                if (f == 0)
                    sprintf(tempchar, "%f", tempval);
            }
            else
            {
                int tempval;
                if (!strcmp($<string>2, "+"))
                {
                    tempval = atoi($<test.val>1) + atoi($<test.val>3);
                }
                else if (!strcmp($<string>2, "-"))
                {
                    tempval = atoi($<test.val>1) - atoi($<test.val>3);
                }
                sprintf(tempchar, "%d", tempval);
            }
            $<test.val>$ = strdup(tempchar);
        }
    }

    | tExpression {
        treeNode *tExpressionNode = pop(parseStack);

        treeNode *node = createNode("arith_expression", NULL);
        
        addChild(node, tExpressionNode);

        push(parseStack, node);

        $<test.val>$ = strdup($<test.val>1); 
        $<test.value>$ = $<test.value>1; 
        $<type>$ = $<type>1;
    }

tExpression: tExpression MULOP fExpression {
        treeNode *fExpressionNode = pop(parseStack);
        treeNode *tExpressionNode = pop(parseStack);

        treeNode *node = createNode("tExpression", NULL);
        
        addChild(node, tExpressionNode);
        addChild(node, createNode("MULOP", $<string>2));
        addChild(node, fExpressionNode);
        
        push(parseStack, node);

        int flag = 0;
        if (($<type>1 == 'i' && $<type>3 == 'r') || ($<type>1 == 'r' && $<type>3 == 'i'))
        {
        }
        else if ($<type>1 != $<type>3)
        {
            if (!(strcmp(type_to_string($<type>1), "unknown") == 0 || strcmp(type_to_string($<type>3), "unknown") == 0))
            {
                printf("Conflicting (%s) and (%s) used in RHS, at line number %d\n", type_to_string($<type>1), type_to_string($<type>3), yylineno);
                flag = 1;
            }
        }
        // int tempint = atoi($<test.val>1) * atoi($<test.val>3);
        // char tempchar[25];
        // sprintf(tempchar, "%d", tempint);
        if(flag == 0){
            if ($<type>1 != $<type>3)
            {
                $<type>$ = 'r';
            }
            else
            {
                if (!strcmp($<string>2, "/"))
                {
                    $<type>$ = 'r';
                }
                else
                {
                    $<type>$ = $<type>3;
                }
            }
            if ($<type>$ == 'r' && !strcmp($<string>2, "%"))
            {
                printf("Use of real datatype with %% operator. Line number: %d", yylineno);
            }
            char tempchar[25] = "NULL";
            int f = 0;
            if (!strcmp($<string>2, "/"))
            {
                if ($<type>$ == 'r')
                {
                    float tempvar;

                    if (strcmp($<test.val>1, "NULL") && strcmp($<test.val>3, "NULL"))
                    {
                        tempvar = atof($<test.val>1) / atof($<test.val>3);
                        sprintf(tempchar, "%f", tempvar);
                    }
                    else
                    {
                        f = 1;
                    }
                }
                else
                {
                    int tempvar;

                    tempvar = atoi($<test.val>1) / atoi($<test.val>3);
                    sprintf(tempchar, "%d", tempvar);
                }
            }
            else if (!strcmp($<string>2, "*"))
            {
                if ($<type>$ == 'r')
                {
                    float tempvar;
                    if (strcmp($<test.val>1, "NULL") && strcmp($<test.val>3, "NULL"))
                    {
                        tempvar = atof($<test.val>1) * atof($<test.val>3);
                        sprintf(tempchar, "%f", tempvar);
                    }
                }
                else
                {
                    int tempvar;

                    tempvar = atoi($<test.val>1) * atoi($<test.val>3);
                    sprintf(tempchar, "%d", tempvar);
                }
            }
            else
            {
                int tempvar;

                tempvar = atoi($<test.val>1) % atoi($<test.val>3);
                sprintf(tempchar, "%d", tempvar);
            }

            $<test.val>$ = strdup(tempchar);
            //$<test.value>$ = $<test.value>1 * $<test.value>3;
        }
}

    | fExpression {
        treeNode *fExpressionNode = pop(parseStack);

        treeNode *node = createNode("tExpression", NULL);
        
        addChild(node, fExpressionNode);

        push(parseStack, node);

        $<test.val>$ = strdup($<test.val>1); 
        $<test.value>$ = $<test.value>1; 
        $<type>$ = $<type>1;
    }

fExpression: LPAREN arith_expression RPAREN {
        treeNode *arithExpressionNode = pop(parseStack);

        treeNode *node = createNode("fExpression", NULL);

        addChild(node, createNode("LPAREN", "("));
        addChild(node, arithExpressionNode);
        addChild(node, createNode("RPAREN", ")"));

        push(parseStack, node);

        $<test.val>$ = strdup($<test.val>2); 
        $<test.value>$ = $<test.value>2; 
        $<type>$ = $<type>2;
    }

    | readable {
        treeNode *readableNode = pop(parseStack);

        treeNode *node = createNode("fExpression", NULL);
        
        addChild(node, readableNode);

        push(parseStack, node);

        $<test.val>$ = strdup($<test.val>1); 
        $<test.value>$ = $<test.value>1; 
        $<type>$ = $<type>1;
    } 

    | INTLITERAL {
        treeNode *node = createNode("fExpression", NULL);
        // printf("ERROR HERERE!!!!!\n");
        addChild(node, createNode("INTLITERAL", $<string>1));

        push(parseStack, node);

        $<test.val>$ = strdup($<test.val>1); 
        $<test.value>$ = $<test.value>1; 
        $<type>$ = 'i';
    }

    | CHAR_LIT {
        treeNode *node = createNode("fExpression", NULL);

        addChild(node, createNode("CHAR_LIT", $<string>1));

        push(parseStack, node);

        $<test.val>$ = strdup($<test.val>1); 
        $<type>$ = 'c';
    }

bool_exp: term {
        treeNode *termNode = pop(parseStack);

        treeNode *node = createNode("bool_exp", NULL);
        
        addChild(node, termNode);
        
        push(parseStack, node);

        $<type>$ = $<type>1;
    }

    | bool_exp OR term {
        treeNode *termNode = pop(parseStack);
        treeNode *boolExpNode = pop(parseStack);

        treeNode *node = createNode("bool_exp", NULL);
        
        addChild(node, boolExpNode);
        addChild(node, createNode("OR", "OR"));
        addChild(node, termNode);

        push(parseStack, node);

        if ($<type>1 != $<type>3)
        {
            if (!(strcmp(type_to_string($<type>1), "unknown") == 0 || strcmp(type_to_string($<type>3), "unknown") == 0))
            {
                printf("Conflicting (%s) and (%s) used in RHS, at line number %d\n", type_to_string($<type>1), type_to_string($<type>3), yylineno);
            }
        }
        $<type>$ = $<type>3;
    }

term: factor {
        treeNode *factorNode = pop(parseStack);

        treeNode *node = createNode("term", NULL);

        addChild(node, factorNode);

        push(parseStack, node);

        $<type>$ = $<type>1;
    }

    | term AND factor {
        treeNode *factorNode = pop(parseStack);
        treeNode *termNode = pop(parseStack);

        treeNode *node = createNode("term", NULL);
        
        addChild(node, termNode);
        addChild(node, createNode("AND", "AND"));
        addChild(node, factorNode);

        push(parseStack, node);

        if ($<type>1 != $<type>3)
        {
            if (!(strcmp(type_to_string($<type>1), "unknown") == 0 || strcmp(type_to_string($<type>3), "unknown") == 0))
            {
                printf("Conflicting (%s) and (%s) used in RHS, at line number %d\n", type_to_string($<type>1), type_to_string($<type>3), yylineno);
            }
        }
        $<type>$ = $<type>3;
    }

factor: cond {
        treeNode *condNode = pop(parseStack);

        treeNode *node = createNode("factor", NULL);
        
        addChild(node, condNode);

        push(parseStack, node);

        $<type>$ = $<type>1; 
        $<test.val>$ = strdup($<test.val>1);
    }

    | NOT factor {
        treeNode *factorNode = pop(parseStack);

        treeNode *node = createNode("factor", NULL);

        addChild(node, createNode("NOT", "NOT"));
        addChild(node, factorNode);

        push(parseStack, node);

        $<type>$ = $<type>2; 
	    if(strcmp($<test.val>2, "1") == 0){
			$<test.val>$ = strdup("0");
		}
		else{
			$<test.val>$ = strdup("1");
		}
    }

    | LPAREN bool_exp RPAREN {
        treeNode *boolExpNode = pop(parseStack);

        treeNode *node = createNode("factor", NULL);

        addChild(node, createNode("LPAREN", "("));
        addChild(node, boolExpNode);
        addChild(node, createNode("RPAREN", ")"));

        push(parseStack, node);

        $<type>$ = $<type>2; 
        $<test.val>$ = strdup($<test.val>2);
    }

    | IDENTIFIER {
        treeNode *node = createNode("factor", NULL);

        addChild(node, createNode("IDENTIFIER", $<string>1));

        push(parseStack, node);

        int j = checkVar($<test.name>1); 
	    if(j!=-1){
	        if(tolower(varTypes[j][0]) == 'b'){
		        $<type>$ = tolower(varTypes[j][0]);
	            $<test.val>$ = strdup($<test.val>1);
			}				
	        else{
		        printf("Non-boolean value assigned to boolean expression. ");
		        yyerror(1);
	        }
		}	
    }

printable: STRING {
        treeNode *node = createNode("printable", NULL);

        addChild(node, createNode("STRING", $<string>1));

        push(parseStack, node);
    }
    | printable COMMA arith_expression {
        treeNode *arithExpressionNode = pop(parseStack);
        treeNode *printableNode = pop(parseStack);

        treeNode *node = createNode("printable", NULL);

        addChild(node, printableNode);
        addChild(node, createNode("COMMA", ","));
        addChild(node, arithExpressionNode);

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

    if ($<type>1 != $<type>3) {
		if(($<type>1 == 'r' && $<type>3 == 'i') || ($<type>3 == 'r' && $<type>1 == 'i')){
			
		}
		else if(!(strcmp(type_to_string($<type>1), "unknown")==0 || strcmp(type_to_string($<type>3), "unknown")==0)){
            printf("Conflicting (%s) and (%s) used in RHS, at line number %d\n",  type_to_string($<type>1), type_to_string($<type>3), yylineno);
        }
    }
	if(strcmp($<test.val>1, "NULL") && strcmp($<test.val>1, "NULL")){
		if(strcmp($<string>2, "=")){
			if(strcmp($<test.val>1, $<test.val>3) == 0){
				$<test.val>$ = strdup("1");
			}
			else{
				$<test.val>$ = strdup("0");
			}
		}

	    if(strcmp($<string>2, "<>")){
			if(strcmp($<test.val>1, $<test.val>3) != 0){
				$<test.val>$ = strdup("1");
			}
			else{
				$<test.val>$ = strdup("0");
			}
		}

	    if(strcmp($<string>2, "<")){
			if(atof($<test.val>1) < atof($<test.val>3)){
				$<test.val>$ = strdup("1");
			}
			else{
				$<test.val>$ = strdup("0");
			}
		}

	    if(strcmp($<string>2, ">")){
			if(atof($<test.val>1) > atof($<test.val>3)){
				$<test.val>$ = strdup("1");
			}
			else{
				$<test.val>$ = strdup("0");
			}
		}

	    if(strcmp($<string>2, "<=")){
			if(atof($<test.val>1) <= atof($<test.val>3)){
				$<test.val>$ = strdup("1");
			}
			else{
				$<test.val>$ = strdup("0");
			}
		}

		if(strcmp($<string>2, ">=")){
			if(atof($<test.val>1) >= atof($<test.val>3)){
				$<test.val>$ = strdup("1");
			}
			else{
				$<test.val>$ = strdup("0");
			}
		}
    } 

    $<type>$ = 'b';
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



indexing: arith_expression {
        treeNode *arithExpressionNode = pop(parseStack);

        treeNode *node = createNode("indexing", NULL);

        addChild(node, arithExpressionNode);

        push(parseStack, node);

        $<test.val>$ = strdup($<test.val>1); 
    	if(strcmp($<test.val>$, "NULL")){
            if($<type>1 != 'i')
            {
                printf("Array index not integer."); 
                yyerror(1);
            }else{
                $<type>$ = $<type>1;
            }
	    }
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

    // if ($<type>4 != $<type>6) {
	// 	if(!(strcmp(type_to_string($<type>4), "unknown")==0 || strcmp(type_to_string($<type>6), "unknown")==0)){
    //         printf("Conflicting (%s) and (%s) used in RHS, at line number %d\n", 
    //         type_to_string($<type>4), type_to_string($<type>6), yylineno);
	// 	}
	// } //if the arithops are not of the same type	
	int j = checkVar($<test.name>2); 
    if(j != -1){
        char *type1 = varTypes[j];
        if(strcmp(type1, "int") == 0){
            //char *type2;
            // switch ($<type>4) {
            //     case 'i':
            //         type2 = "int";
            //         break;
            //     case 'c':
            //         type2 = "char";
            //         break;
            //     case 'r':
            //         type2 = "real";
            //         break;
            //     case 'b':
            //         type2 = "bool";
            //         break;
            //     default:
            //         type2 = "unknown";
            //         printf("Error: Unknown type '%c'\n", $<type>4);
                    
            //         break;
            // }
            // if (strcmp(type1, type2) != 0) {
            //     printf("Type mismatch. Attempted to assign %s to %s. ", type2, type1);
            // }
            if($<type>4 != 'i' || $<type>6 != 'i')
                printf("Loop range values must be integer type. Line number %d.\n", yylineno);
                
        }else{
                        // printf("sadfdsfdsf%c, ", $<type>2);

            printf("Loop variable must be integer type. Line number %d.\n", yylineno);
            
        }
    }
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

    $<type>$ = $<type>1;
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

void yyerror(int code) {
    if (code != 1) {
        printf("syntax error\n");
        printf("line number %d. \n", yylineno);
    }
    else{

    	printf("Line number %d.\n", yylineno);
    }
    //exit(1);
}

/* void main(){
    freopen("log.txt", "w", stdout);
    parseStack = createStack();
    yyin = fopen("sample.txt", "r");
    yyparse();
    /* printf("valid input\n"); */
    /* printTree(parseStack->top->node);
    fclose(yyin);
} */ 

int main(int argc, char *argv[]){
    char* filename;
    filename=argv[1];
    printf("\n");
    parseStack = createStack();
    yyin=fopen(filename, "r");
    yyparse();
    printVariableList();
    /* printTree(parseStack->top->node); */
    return 0;
}
