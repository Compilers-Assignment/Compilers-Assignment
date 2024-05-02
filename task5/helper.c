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

// TODO: handling floats
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
        }
    }
    else
    {
        symbolTableNode *temp = searchSymbolTable(symbolTable, node->children->node->terminal);
        if (temp != NULL)
        {
            if (temp->type == 'i')
            {
                return temp->intArray[eval_arith_expression(node->children->next->next->node->children->node)];
            }
            else if (temp->type == 'c')
            {
                return (int)temp->charArray[eval_arith_expression(node->children->next->next->node->children->node)];
            }
            else if (temp->type == 'b')
            {
                return temp->boolArray[eval_arith_expression(node->children->next->next->node->children->node)];
            }
        }
    }
}

// TODO: handling floats
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

// TODO: handling floats
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

// TODO: handling floats
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

// TODO: handling floats
int eval_expression(treeNode *node)
{
    if (strcmp(node->children->node->nonTerminal, "arith_expression") == 0)
    {
        return eval_arith_expression(node->children->node);
    }
    else
    {
    }
}