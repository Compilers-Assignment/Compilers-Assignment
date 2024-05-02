#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct treeNode treeNode;
typedef struct stackLinkedList stackLinkedList;

struct stackLinkedList
{
    treeNode *node;
    stackLinkedList *next;
};

int lengthOfStackLinkedList(stackLinkedList *list)
{
    int length = 0;
    stackLinkedList *temp = list;
    while (temp != NULL)
    {
        length++;
        temp = temp->next;
    }
    return length;
}

struct treeNode
{
    char *nonTerminal;
    char *terminal;
    treeNode *parent;
    stackLinkedList *children;
};

treeNode *createNode(char *nonTerminal, char *terminal)
{
    treeNode *node = (treeNode *)malloc(sizeof(treeNode));
    node->nonTerminal = nonTerminal;
    node->terminal = terminal;
    node->parent = NULL;
    node->children = NULL;
    return node;
}

stackLinkedList *createStackLinkedList(treeNode *node)
{
    stackLinkedList *list = (stackLinkedList *)malloc(sizeof(stackLinkedList));
    list->node = node;
    list->next = NULL;
    return list;
}

void addToStackLinkedList(stackLinkedList *list, treeNode *node)
{
    stackLinkedList *temp = list;
    while (temp->next != NULL)
    {
        temp = temp->next;
    }
    temp->next = createStackLinkedList(node);
}

void addChild(treeNode *parent, treeNode *child)
{
    if (parent->children == NULL)
    {
        parent->children = createStackLinkedList(child);
    }
    else
    {
        addToStackLinkedList(parent->children, child);
    }
    child->parent = parent;
    return;
}

typedef struct
{
    stackLinkedList *top;
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

treeNode *pop(stack *s)
{
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

struct symbolTableNode
{
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

symbolTableNode *createSymbolTableNode(char *name, char type)
{
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

void addToSymbolTable(symbolTableNode *table, symbolTableNode *node)
{
    symbolTableNode *temp = table;
    while (temp->next != NULL)
    {
        temp = temp->next;
    }
    temp->next = node;
}

symbolTableNode *searchSymbolTable(symbolTableNode *table, char *name)
{
    symbolTableNode *temp = table;
    while (temp != NULL)
    {
        if (strcmp(temp->name, name) == 0)
        {
            return temp;
        }
        temp = temp->next;
    }
    return NULL;
}

symbolTableNode *createSymbolTable()
{
    symbolTableNode *table = (symbolTableNode *)malloc(sizeof(symbolTableNode));
    table->name = "global";
    table->type = 'g';
    table->next = NULL;
    return table;
}

void printSymbolTable(symbolTableNode *table)
{
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
    while (temp != NULL)
    {
        printf("%s\t", temp->name);
        if (temp->isArray)
        {
            printf("array of ");
            if (temp->type == 'i')
            {
                printf("int\t");
            }
            else if (temp->type == 'r')
            {
                printf("real\t");
            }
            else if (temp->type == 'c')
            {
                printf("char\t");
            }
            else if (temp->type == 'b')
            {
                printf("bool\t");
            }
        }
        else
        {
            if (temp->type == 'i')
            {
                printf("int\t\t");
            }
            else if (temp->type == 'r')
            {
                printf("real\t\t");
            }
            else if (temp->type == 'c')
            {
                printf("char\t\t");
            }
            else if (temp->type == 'b')
            {
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
int eval_bool_exp(treeNode *node);

typedef struct returnVal
{
    int intValue;
    float floatValue;
    char charValue;
    int boolValue;
} returnVal;

int eval_readable(treeNode *node)
{
    if (lengthOfStackLinkedList(node->children) == 1)
    {
        symbolTableNode *temp = searchSymbolTable(symbolTable, node->children->node->terminal);
        if (temp != NULL)
        {
            if (temp->type == 'i')
            {
                return temp->intValue;
            }
            else if (temp->type == 'c')
            {
                return (int)temp->charValue;
            }
            else if (temp->type == 'b')
            {
                return temp->boolValue;
            }
            else if (temp->type == 'r')
            {
                return (int)temp->floatValue;
            }
        }
    }
    else
    {
        symbolTableNode *temp = searchSymbolTable(symbolTable, node->children->node->terminal);
        int index = eval_arith_expression(node->children->next->next->node->children->node) - 1;
        if (temp != NULL)
        {
            if (temp->type == 'i')
            {
                return temp->intArray[index];
            }
            else if (temp->type == 'c')
            {
                return (int)temp->charArray[index];
            }
            else if (temp->type == 'b')
            {
                return temp->boolArray[index];
            }
            else if (temp->type == 'r')
            {
                return (int)temp->floatArray[index];
            }
        }
    }
}

int eval_fExpression(treeNode *node)
{
    if (lengthOfStackLinkedList(node->children) == 1)
    {
        if (strcmp(node->children->node->nonTerminal, "INTLITERAL") == 0)
        {
            return atoi(node->children->node->terminal);
        }
        if (strcmp(node->children->node->nonTerminal, "CHAR_LIT") == 0)
        {
            return (int)(node->children->node->terminal[1]);
        }
        if (strcmp(node->children->node->nonTerminal, "readable") == 0)
        {
            return eval_readable(node->children->node);
        }
    }
    else
    {
        return eval_arith_expression(node->children->next->node);
    }
}

int eval_tExpression(treeNode *node)
{
    if (lengthOfStackLinkedList(node->children) == 1)
    {
        return eval_fExpression(node->children->node);
    }
    else
    {
        if (strcmp(node->children->next->node->terminal, "*") == 0)
        {
            return eval_tExpression(node->children->node) * eval_fExpression(node->children->next->next->node);
        }
        if (strcmp(node->children->next->node->terminal, "/") == 0)
        {
            return eval_tExpression(node->children->node) / eval_fExpression(node->children->next->next->node);
        }
        if (strcmp(node->children->next->node->terminal, "%") == 0)
        {
            return eval_tExpression(node->children->node) % eval_fExpression(node->children->next->next->node);
        }
    }
}

int eval_arith_expression(treeNode *node)
{
    if (lengthOfStackLinkedList(node->children) == 1)
    {
        return eval_tExpression(node->children->node);
    }
    else
    {
        if (strcmp(node->children->next->node->terminal, "+") == 0)
        {
            return eval_arith_expression(node->children->node) + eval_tExpression(node->children->next->next->node);
        }
        if (strcmp(node->children->next->node->terminal, "-") == 0)
        {
            return eval_arith_expression(node->children->node) - eval_tExpression(node->children->next->next->node);
        }
    }
}

int eval_cond(treeNode *node)
{
    int left = eval_arith_expression(node->children->node);
    int right = eval_arith_expression(node->children->next->next->node);

    if (strcmp(node->children->next->node->terminal, "=") == 0)
    {
        return left == right;
    }
    if (strcmp(node->children->next->node->terminal, "<") == 0)
    {
        return left < right;
    }
    if (strcmp(node->children->next->node->terminal, ">") == 0)
    {
        return left > right;
    }
    if (strcmp(node->children->next->node->terminal, "<=") == 0)
    {
        return left <= right;
    }
    if (strcmp(node->children->next->node->terminal, ">=") == 0)
    {
        return left >= right;
    }
    if (strcmp(node->children->next->node->terminal, "<>") == 0)
    {
        return left != right;
    }
}

int eval_factor(treeNode *node)
{
    if (lengthOfStackLinkedList(node->children) == 1)
    {
        if (strcmp(node->children->node->nonTerminal, "cond") == 0)
        {
            return eval_cond(node->children->node);
        }
        else
        {
            symbolTableNode *temp = searchSymbolTable(symbolTable, node->children->node->terminal);
            if (temp != NULL)
            {
                if (temp->type == 'b')
                {
                    return temp->boolValue;
                }
                else
                {
                    return temp->intValue != 0;
                }
            }
        }
    }
    if (strcmp(node->children->node->nonTerminal, "NOT") == 0)
    {
        return !eval_factor(node->children->next->node);
    }
    else
    {
        return eval_bool_exp(node->children->next->node);
    }
}

int eval_term(treeNode *node)
{
    if (lengthOfStackLinkedList(node->children) == 1)
    {
        return eval_factor(node->children->node);
    }
    else
    {
        return eval_term(node->children->node) && eval_factor(node->children->next->next->node);
    }
}

int eval_bool_exp(treeNode *node)
{
    if (lengthOfStackLinkedList(node->children) == 1)
    {
        return eval_term(node->children->node);
    }
    else
    {
        return eval_bool_exp(node->children->node) || eval_term(node->children->next->next->node);
    }
}

int eval_expression(treeNode *node)
{
    if (strcmp(node->children->node->nonTerminal, "arith_expression") == 0)
    {
        return eval_arith_expression(node->children->node);
    }
    else
    {
        return eval_bool_exp(node->children->node);
    }
}

void read_readable(treeNode *node)
{
    if (lengthOfStackLinkedList(node->children) == 1)
    {
        symbolTableNode *temp = searchSymbolTable(symbolTable, node->children->node->terminal);
        if (temp != NULL)
        {
            if (temp->type == 'i')
            {
                scanf("%d", &temp->intValue);
            }
            else if (temp->type == 'c')
            {
                scanf("%c", &temp->charValue);
            }
            else if (temp->type == 'b')
            {
                scanf("%d", &temp->boolValue);
            }
        }
    }
    else
    {
        symbolTableNode *temp = searchSymbolTable(symbolTable, node->children->node->terminal);
        if (temp != NULL)
        {
            int index = eval_arith_expression(node->children->next->next->node->children->node) - 1;
            if (temp->type == 'i')
            {
                scanf("%d", &temp->intArray[index]);
            }
            else if (temp->type == 'c')
            {
                scanf("%c", &temp->charArray[index]);
            }
            else if (temp->type == 'b')
            {
                scanf("%d", &temp->boolArray[index]);
            }
        }
    }
}

void eval_write(treeNode *printableNode)
{
    treeNode *tempPrintable = printableNode;
    while (1)
    {
        if (lengthOfStackLinkedList(tempPrintable->children) == 1)
        {
            if (strcmp(tempPrintable->children->node->nonTerminal, "STRING") == 0)
            {
                printf("%s ", tempPrintable->children->node->terminal);
                break;
            }
            else
            {
                printf("%d ", eval_arith_expression(tempPrintable->children->node));
                break;
            }
        }
        else
        {
            if (strcmp(tempPrintable->children->node->nonTerminal, "STRING") == 0)
            {
                printf("%s ", tempPrintable->children->node->terminal);
                tempPrintable = tempPrintable->children->next->next->node;
            }
            else
            {
                printf("%d ", eval_arith_expression(tempPrintable->children->node));
                tempPrintable = tempPrintable->children->next->next->node;
            }
        }
    }
    printf("\n");
}

void eval_assignment(treeNode *node)
{
    if (lengthOfStackLinkedList(node->children) == 4)
    {
        symbolTableNode *temp = searchSymbolTable(symbolTable, node->children->node->terminal);
        treeNode *expressionNode = node->children->next->next->node;
        if (temp != NULL)
        {
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
    else
    {
        symbolTableNode *temp = searchSymbolTable(symbolTable, node->children->node->terminal);
        treeNode *expressionNode = node->children->next->next->next->next->next->node;
        treeNode *indexNode = node->children->next->next->node;
        int index = eval_arith_expression(indexNode->children->node) - 1;

        if (temp != NULL)
        {
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
                temp->boolArray[index] = eval_expression(expressionNode);
            }
        }
    }
}

void eval_src(treeNode *node);

void eval_if(treeNode *node)
{
    if (lengthOfStackLinkedList(node->children) == 7)
    {
        if (eval_bool_exp(node->children->next->node))
        {
            eval_src(node->children->next->next->next->next->node);
        }
    }
    else
    {
        if (eval_bool_exp(node->children->next->node))
        {
            eval_src(node->children->next->next->next->next->node);
        }
        else
        {
            eval_src(node->children->next->next->next->next->next->next->next->next->node);
        }
    }
}

void eval_for(treeNode *node)
{
    treeNode *aNode1 = node->children->next->next->next->node;
    treeNode *aNode2 = node->children->next->next->next->next->next->node;
    symbolTableNode *temp = searchSymbolTable(symbolTable, node->children->next->node->terminal);
    int start = eval_arith_expression(aNode1);
    int end = eval_arith_expression(aNode2);
    int up = strcmp(node->children->next->next->next->next->node->children->node->terminal, "TO") == 0 ? 1 : 0;
    if (up)
    {
        for (int i = start; i <= end; i++)
        {
            temp->intValue = i;
            eval_src(node->children->next->next->next->next->next->next->next->next->node);
        }
    }
    else
    {
        for (int i = start; i >= end; i--)
        {
            temp->intValue = i;
            eval_src(node->children->next->next->next->next->next->next->next->next->node);
        }
    }
}

void eval_while(treeNode *node)
{
    while (eval_bool_exp(node->children->next->node))
    {
        eval_src(node->children->next->next->next->next->node);
    }
}

void eval_rule(treeNode *node)
{
    if (strcmp(node->children->node->nonTerminal, "WRITE") == 0)
    {
        eval_write(node->children->next->next->node);
    }
    else if (strcmp(node->children->node->nonTerminal, "READ") == 0)
    {
        read_readable(node->children->next->next->node);
    }
    else if (strcmp(node->children->node->nonTerminal, "assignment") == 0)
    {
        eval_assignment(node->children->node);
    }
    else if (strcmp(node->children->node->nonTerminal, "BEG") == 0)
    {
        eval_src(node->children->next->node);
    }
    else if (strcmp(node->children->node->nonTerminal, "ifCond") == 0)
    {
        eval_if(node->children->node);
    }
    else if (strcmp(node->children->node->nonTerminal, "forLoop") == 0)
    {
        eval_for(node->children->node);
    }
    else if (strcmp(node->children->node->nonTerminal, "whileLoop") == 0)
    {
        eval_while(node->children->node);
    }
    else
    {
        printf("Invalid rule\n");
    }
}

void eval_src(treeNode *node)
{
    treeNode *temp = node;
    while (1)
    {
        if (lengthOfStackLinkedList(temp->children) == 0)
        {
            break;
        }
        else
        {
            eval_rule(temp->children->node);
            temp = temp->children->next->node;
        }
    }
}