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
    int varCapacity = 0; // Current capacity of the array
    extern int yylineno;
    int yylex();
    void yyerror();
    extern FILE *yyin;
    
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

	int checkVar(const char *name) { //this is for the undeclared variable error
	   //printf("checkvar called for %s\n", name);
	   bool flag = false;
	   int j = 0;
	   for(int i = 0; i < varCount; i++){
	    	if(strcmp(varNames[i], name) == 0){
		   flag = true;
		   j = i;
		   break;
		}
	   }
	   
	   if(!flag){
	       printf("undeclared variable: %s", name);
	       yyerror(1);
	   }
	   return j;
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
%}

%token PROGRAM INTEGER REAL BOOLEAN CHAR TO DOWNTO IF ELSE VAR WHILE FOR DO ARRAY BEG END READ WRITE THEN AND OR NOT INTLITERAL IDENTIFIER ADDOP MULOP RELOP ASGOP SEMICOLON COLON LBRACKET RBRACKET COMMA LPAREN RPAREN PERIOD STRING OF CHAR_LIT

%union{
    char *string;   
    int integer;    
    double real;    
    char type;     
    int boolean;    
}

%%

start: PROGRAM IDENTIFIER SEMICOLON body 
body: VAR declList BEG srcWithIf END PERIOD 
declList: 
        | decl declList
decl: vars COLON type SEMICOLON 
    | vars COLON ARRAY LBRACKET INTLITERAL PERIOD PERIOD INTLITERAL RBRACKET OF arraytype SEMICOLON 
    {/*printVariableList();*/ int left = $<integer>5; int right = $<integer>8; /*printf("%d %d", left, right); */ arrayReplacement(left, right); /*printVariableList();*/}

vars: vars COMMA IDENTIFIER {if(addVariable($<string>3) == 0){yyerror(1);}}
    | IDENTIFIER            {if(addVariable($<string>1) == 0){yyerror(1);}}

type: INTEGER {addVarType("int");}
     | BOOLEAN {addVarType("bool");}
     | REAL {addVarType("real");}
     | CHAR {addVarType("char");}
     
     
arraytype:   INTEGER {addVarType("aint");}
	     | BOOLEAN {addVarType("abool");}
	     | REAL {addVarType("areal");}
	     | CHAR {addVarType("achar");}

assignment: IDENTIFIER ASGOP expression SEMICOLON 
{
	    int j = checkVar($<string>1); 
	    char *type1 = varTypes[j];
	 
	    char *type2;
	    switch ($<type>3) {
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
		    type2 = "unknown";
		    printf("Error: Unknown type '%c'\n", $<type>3);
		    yyerror(1);
		    break;
	    }

	    printf("Type of the variable is %s\n", type1);
	    printf("Type of the RHS is %s\n", type2);
	    
	    if (strcmp(type1, type2) != 0) {
		printf("Type mismatch. Attempted to assign %s to %s\n", type2, type1);
		yyerror(1);
	    }
}

    | IDENTIFIER LBRACKET indexing RBRACKET ASGOP expression SEMICOLON //ARRAYS, LATER

expression: arith_expression {$<type>$ = $<type>1;}| bool_exp {$<type>$ = $<type>1;}

arith_expression: arith_expression ADDOP tExpression {if($<type>$ != $<type>3) {printf("Type Mismatch"); yyerror(1);}$<type>$ = $<type>3;} 
    | tExpression {$<type>$ = $<type>1;}

tExpression: tExpression MULOP fExpression {if($<type>$ != $<type>3) {printf("Type Mismatch"); yyerror(1);} 
$<type>$ = $<type>3;} 
    | fExpression {$<type>$ = $<type>1;}
    
fExpression: LPAREN arith_expression RPAREN {$<type>$ = $<type>2;}
    | readable {$<type>$ = $<type>1;}
    | INTLITERAL {$<type>$ = 'i';}
    | CHAR_LIT {$<type>$ = 'c';}


bool_exp: term {$<type>$ = $<type>1;}
    | bool_exp OR term {if($<type>$ != $<type>3) {printf("Type Mismatch"); yyerror(1);} $<type>$ = $<type>3;} //CHANGE
    
term: factor {$<type>$ = $<type>1;}
    | term AND factor {if($<type>$ != $<type>3) {printf("Type Mismatch"); yyerror(1);} $<type>$ = $<type>3;} //CHANGE
    
factor: cond {$<type>$ = $<type>1;}
    | NOT factor {$<type>$ = $<type>2;}
    | LPAREN bool_exp RPAREN {$<type>$ = $<type>2;}
    | IDENTIFIER {int j = checkVar($<string>1); $<type>$ = tolower(varTypes[j][0]);}

printable: STRING | printable COMMA readable | printable COMMA STRING | arith_expression

range: TO | DOWNTO

cond: arith_expression RELOP arith_expression {if($<type>$ != $<type>3) {printf("Type Mismatch"); yyerror(1); }
$<type>$ = $<type>3;}


srcWithIf: 
    | ruleWithIf srcWithIf
    
ruleWithIf: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN readable RPAREN SEMICOLON
    | ifCond
    | forLoopWithIf
    | whileLoopWithIf
    | assignment
    | BEG srcWithIf END

srcWithoutIf: 
    | ruleWithoutIf srcWithoutIf

ruleWithoutIf: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN readable RPAREN SEMICOLON
    | forLoopWithIf
    | whileLoopWithIf
    | assignment
    | BEG srcWithIf END

readable: IDENTIFIER {int j = checkVar($<string>1); $<type>$ = tolower(varTypes[j][0]);} 
    | IDENTIFIER LBRACKET indexing RBRACKET //this is array bs we take lite for now

indexing: arith_expression

ifCond: IF conditionals THEN BEG matched END SEMICOLON
    | IF conditionals THEN BEG matched END ELSE BEG 
    tail END SEMICOLON
    
matched: IF conditionals THEN BEG matched END ELSE BEG 
    matched END SEMICOLON  
    | srcWithoutIf
tail: IF conditionals THEN BEG tail END SEMICOLON 
    | srcWithoutIf

forLoopWithIf: FOR IDENTIFIER ASGOP arith_expression range arith_expression
    DO BEG srcWithIf END SEMICOLON 
    {	 
            if($<type>4 != $<type>6){printf("Type Mismatch."); yyerror(1);} //if the arithops are not of the same type	
	    int j = checkVar($<string>2); 
	    char *type1 = varTypes[j];
	 
	    char *type2;
	    switch ($<type>4) {
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
		    type2 = "unknown";
		    printf("Error: Unknown type '%c'\n", $<type>4);
		    yyerror(1);
		    break;
	    }

	    printf("Type of the variable is %s\n", type1);
	    printf("Type of the RHS is %s\n", type2);
	    
	    if (strcmp(type1, type2) != 0) {
		printf("Type mismatch. Attempted to assign %s to %s\n", type2, type1);
		yyerror(1);
	    }
	}
    
whileLoopWithIf: WHILE conditionals
    DO BEG srcWithIf END SEMICOLON

conditionals: bool_exp {$<type>$ = $<type>1;}


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
        printf("line number %d", yylineno);
    }
    else{
    	printf("error line number %d", yylineno);
    }
    exit(1);
}



