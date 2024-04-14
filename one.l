%{

#include<stdlib.h>
#include<stdio.h>
extern int yylval;
void yyerror (char const *s) { //can use this instead of the current printf return 0
 fprintf (stderr, "%s\n", s);
}
int linecount = 1;
char **varNames = NULL; // Pointer to an array of string pointers
int varCount = 0; // Number of variables currently stored
int varCapacity = 0; // Current capacity of the array

void ensureCapacity(int minCapacity) {
    if (minCapacity > varCapacity) {
        int newCapacity = varCapacity == 0 ? 4 : varCapacity * 2;
        if (newCapacity < minCapacity) {
            newCapacity = minCapacity;
        }
        char **newVarNames = realloc(varNames, newCapacity * sizeof(char*));
        if (!newVarNames) {
            yyerror("Out of memory");
            exit(EXIT_FAILURE);
        }
        varNames = newVarNames;
        for (int i = varCapacity; i < newCapacity; ++i) {
            varNames[i] = NULL; // Initialize new elements to NULL
        }
        varCapacity = newCapacity;
    }
}

void addVariable(const char *name) {
    ensureCapacity(varCount + 1);
    varNames[varCount] = strdup(name); // Duplicate the string to store it
    if (!varNames[varCount]) {
        yyerror("Out of memory");
        exit(EXIT_FAILURE);
    }
    varCount++;
}

void printVariableList() {
    if (varNames == NULL || varCount == 0) {
        printf("No variables stored.\n");
        return;
    }

    printf("Current Variables List:\n");
    for (int i = 0; i < varCount; ++i) {
        if (varNames[i] != NULL) {
            printf("Variable %d: %s\n", i + 1, varNames[i]);
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

%}
%x prog prevar var vartype commavar pblock assmtpunc assmt
letter [A-Za-z]
number [0-9]
lower [a-z]
upper [A-Z]
space [  \t]
arithop [+-%*/]
keywrd (program|integer|real|boolean|char|to|downto|if|else|var|while|for|do|array|and|or|not|begin|end|read|write) 
%%

program {printf("Line: %d Lexeme: %s Token Type: KEYWORD\n", linecount, yytext); BEGIN prog;}
<prog>{keywrd}; {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}
<prog>{letter}({letter}*|{number}*|_*)*; {printf("Line: %d Lexeme: %s Token Type: IDENTIFIER\n", linecount, yytext); BEGIN prevar;} //does this count as identifier?

<prevar>var{space}* {printf("Line: %d Lexeme: %s Token Type: KEYWORD\n", linecount, yytext); BEGIN var;} //this is for variables
<prevar>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}
<prog>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}

<var>begin{space}* {printf("Line: %d Lexeme: %s Token Type: KEYWORD\n", linecount, yytext); BEGIN pblock;}
<var>{keywrd}({space}|,) {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}
<var>{letter}({letter}*|{number}*|_*)*{space} { addVariable(yytext); printf("Line: %d Lexeme: %s Token Type: IDENTIFIER\n", linecount, yytext);} //currently assumes that there will be spaces before the colon
<var>{letter}({letter}*|{number}*|_*)*/, {addVariable(yytext); printf("Line: %d Lexeme: %s Token Type: IDENTIFIER\n", linecount, yytext); BEGIN commavar;} //currently assumes that there will be spaces before the

<commavar>{letter}({letter}*|{number}*|_*)*{space} { addVariable(yytext); printf("Line: %d Lexeme: %s Token Type: IDENTIFIER\n", linecount, yytext); BEGIN var;} //currently assumes that there will be spaces before the colon
<commavar>{letter}({letter}*|{number}*|_*)*/, {addVariable(yytext); printf("Line: %d Lexeme: %s Token Type: IDENTIFIER\n", linecount, yytext);} //currently assumes that there will be spaces before the
<commavar,var>, {printf("Line: %d Lexeme: %s Token Type: PUNCTUATOR\n", linecount, yytext);}
<commavar>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); printVariableList(); return 0; }
<var>: {printf("Line: %d Lexeme: %s Token Type: PUNCTUATOR\n", linecount, yytext); BEGIN vartype;} 
<vartype>(char|integer|boolean|real); {printf("Line: %d Lexeme: %s Token Type: KEYWORD\n", linecount, yytext); BEGIN var;}
<vartype>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}


<var>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;} //STARTING THE BEGIN BLOCK NOW

<pblock>Write\(\".*\"\); {printf("Line: %d Lexeme: Write Token Type: KEYWORD\n", linecount);} //do we do the one with a variable inside with states? Do we have to check if variable actually present? Idk.
<pblock>read\(.*\); {printf("Line: %d Lexeme: read Token Type: KEYWORD\n", linecount);}
<pblock>{letter}({letter}*|{number}*|_*)*/{space}*:= {printf("Line: %d Lexeme: %s Token Type: IDENTIFIER\n", linecount, yytext); BEGIN assmtpunc;}
<assmtpunc>:= {printf("Line: %d Lexeme: %s Token Type: PUNCTUATOR\n", linecount, yytext); BEGIN assmt;} 
<assmtpunc>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}
<assmt>{letter}({letter}*|{number}*|_*)*; {printf("Line: %d Lexeme: %s Token Type: IDENTIFIER\n", linecount, yytext); BEGIN pblock;}
<assmt>{number}+; {printf("Line: %d Lexeme: %s Token Type: NUMBER\n", linecount, yytext); BEGIN pblock;}
<assmt>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}




<pblock>[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}

<prog,prevar,var,vartype,commavar,pblock,assmtpunc,assmt>\n {printf("\n"); linecount++;}
<prog,prevar,var,vartype,commavar,pblock,assmtpunc,assmt>{space} {}
[^ \n\t] {printf("Line %d Syntax Error %s", linecount, yytext); return 0;}
. {}






%%
int main()
{
yyin = fopen("sample.c", "r");
yylex();
}
