%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
    
char **varNames = NULL; // Pointer to an array of string pointers
char **varTypes = NULL;
int varCount = 0; // Number of variables currently stored
int typeCount = 0;
int varCapacity = 0; // Current capacity of the array


void yyerror();

void ensureCapacity(int minCapacity) {
    if (minCapacity > varCapacity) {
        int newCapacity = varCapacity == 0 ? 4 : varCapacity * 2;
        if (newCapacity < minCapacity) {
            newCapacity = minCapacity;
        }
        char **newVarNames = realloc(varNames, newCapacity * sizeof(char*));
        char **newVarTypes = realloc(varTypes, newCapacity * sizeof(char*));
        if (!newVarNames) {
            perror("Out of memory");
            exit(EXIT_FAILURE);
        }
        varNames = newVarNames;
        varTypes = newVarTypes;
        for (int i = varCapacity; i < newCapacity; ++i) {
            varNames[i] = NULL; // Initialize new elements to NULL
            varTypes[i] = NULL;
        }
        varCapacity = newCapacity;
    }
}

int addVariable(const char *name) {

    for(int i = 0; i < varCount; i++){
    	if(strcmp(varNames[i], name) == 0){
           printf("Multiple declarations of variable: %s", name);
           //perror("");
           return 0;
        }

    } 
    	
    ensureCapacity(varCount + 1);
    varNames[varCount] = strdup(name); // Duplicate the string to store it
    if (!varNames[varCount]) {
        perror("Out of memory");
        exit(EXIT_FAILURE);
    }
    varCount++;
    
    return 1;
}



void addVarType(const char *name) {
    
    for(int i = typeCount; i < varCount; i++){	
    varTypes[i] = strdup(name); // Duplicate the string to store it
    }
    
    if (!varNames[typeCount]) {
        perror("Out of memory");
        exit(EXIT_FAILURE);
    }
    typeCount = varCount;
    
    
}

int checkVar(const char *name) {
   printf("checkvar called for %s\n", name);
   bool flag = false;
   for(int i = 0; i < varCount; i++){
    	if(strcmp(varNames[i], name) == 0){
           flag = true;
           break;
        }
   }
   
   if(!flag){
       printf("undeclared variable: %s", name);
       yyerror(1);
   }
   return 1;
}

void printVariableList() {
    if (varNames == NULL || varCount == 0) {
        printf("No variables stored.\n");
        return;
    }

    printf("Current Variables List:\n");
    for (int i = 0; i < varCount; ++i) {
        if (varNames[i] != NULL) {
            printf("Variable & Type %d: %s %s\n", i + 1, varNames[i], varTypes[i]);
    
        } else {
            printf("Variable %d: [Unassigned]\n", i + 1);
        }
    }
}


void freeVariables() {
    for (int i = 0; i < varCount; ++i) {
        free(varNames[i]);
    }
    free(varNames);
    varNames = NULL;
    varCount = 0;
    varCapacity = 0;
}


void arrayReplacement(int left, int right) {
    int i = varCount - 1;
    while (i >= 0 && (strcmp(varTypes[i], "aint") == 0 ||
                      strcmp(varTypes[i], "abool") == 0 ||
                      strcmp(varTypes[i], "achar") == 0 ||
                      strcmp(varTypes[i], "areal") == 0)) {
        char *baseName = varNames[i];
        char *baseType = varTypes[i] + 1; // Remove the 'a' prefix from the type

        for (int j = left; j <= right; j++) {
            // Allocate memory for the new variable name
            char *newVarName = malloc(strlen(baseName) + 16); // 16 for subscript and null terminator
            if (newVarName == NULL) {
                perror("Out of memory");
                exit(EXIT_FAILURE);
            }

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
    int yylex();
    extern FILE *yyin;


    
    
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
decl: vars COLON type SEMICOLON {printVariableList();} | vars COLON ARRAY LBRACKET INTLITERAL PERIOD PERIOD INTLITERAL RBRACKET OF arraytype SEMICOLON {printVariableList(); int left = $<integer>5; int right = $<integer>8; printf("%d %d", left, right); arrayReplacement(left, right); printVariableList();}
vars: vars COMMA IDENTIFIER {if(addVariable($<string>3) == 0){yyerror(1);}}| IDENTIFIER {if(addVariable($<string>1) == 0){yyerror(1);}}
type: INTEGER {addVarType("int");}| BOOLEAN {addVarType("bool");}| REAL {addVarType("real");}| CHAR {addVarType("char");}
arraytype: INTEGER {addVarType("aint");}| BOOLEAN {addVarType("abool");}| REAL {addVarType("areal");}| CHAR {addVarType("achar");}
assignment: IDENTIFIER ASGOP expression SEMICOLON {checkVar($<string>1);}

expression: arith_expression | bool_exp

arith_expression: arith_expression ADDOP tExpression | tExpression  
tExpression: tExpression MULOP fExpression | fExpression
fExpression: LPAREN arith_expression RPAREN | readable | INTLITERAL | CHAR_LIT

bool_exp: term
    | bool_exp OR term
term: factor
    | term AND factor
factor: cond
    | NOT factor
    | LPAREN bool_exp RPAREN | IDENTIFIER {checkVar($<string>1);}

printable: STRING | printable COMMA readable | printable COMMA STRING | arith_expression
range: TO | DOWNTO
/* cond: readable RELOP readable 
    | readable RELOP INTLITERAL
    | INTLITERAL RELOP readable
    | INTLITERAL RELOP INTLITERAL */
cond: arith_expression RELOP arith_expression

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

readable: IDENTIFIER {checkVar($<string>1);}
    | IDENTIFIER LBRACKET indexing RBRACKET {checkVar($<string>1);}

indexing: IDENTIFIER {checkVar($<string>1);}
    | INTLITERAL
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

void yyerror(int code) {
    if (code != 1) {
        printf("syntax error\n");
    }
    exit(1);
}




