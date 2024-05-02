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
    
    void ensureCapacity(int minCapacity) {
    if (minCapacity > varCapacity) {
        int newCapacity = varCapacity == 0 ? 4 : varCapacity * 2;
        if (newCapacity < minCapacity) {
            newCapacity = minCapacity;
        }
        char **newVarNames = realloc(varNames, newCapacity * sizeof(char*));
        char **newVarTypes = realloc(varTypes, newCapacity * sizeof(char*));
        char **newVarValues = realloc(varValues, newCapacity * sizeof(char *));
        // if (!newVarNames) {
        //     perror("Out of memory");
        //     exit(EXIT_FAILURE);
        // }
        varNames = newVarNames;
        varTypes = newVarTypes;
        varValues = newVarValues;
        for (int i = varCapacity; i < newCapacity; ++i) {
            varNames[i] = NULL; // Initialize new elements to NULL
            varTypes[i] = NULL;
            varValues[i] = strdup(safe);
        }
        varCapacity = newCapacity;
    }
}
        int bracketCheck(const char *name){
          for(int i = 0; i < strlen(name); i++){
          	if(name[i] == '['){
          		return 1;
                 }
          }
          return 0;
        }

	int addVariable(const char *name) {

	    for(int i = 0; i < varCount; i++){
	    	if(strcmp(varNames[i], name) == 0 && !(bracketCheck(varNames[i]))){
		   printf("Multiple declarations of variable: %s. ", name);
		   yyerror(1);
		   //perror("");
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



	void addVarType(const char *name) {
	    
	    for(int i = typeCount; i < varCount; i++){	
	    varTypes[i] = strdup(name); // Duplicate the string to store it
	    }
	    
	    // if (!varNames[typeCount]) {
		// perror("Out of memory");
		// exit(EXIT_FAILURE);
	    // }
	    typeCount = varCount;
	    
	    
	}

	int checkVar(const char *name) { //this is for the undeclared variable error
	   //printf("checkvar called for %s\n", name);
	   bool flag = false;
	   int j = -1;
	   for(int i = 0; i < varCount; i++){
	    	if(strcmp(varNames[i], name) == 0){
		   flag = true;
		   j = i;
		   break;
		}
	   }
	   
	   if(!flag){
	       printf("undeclared variable: %s. ", name);
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
		    printf("Variable & Type %d: %s %s %s\n", i + 1, varNames[i], varTypes[i], varValues[i]);
	    
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
	
const char* type_to_string(char typeCode) {
    switch (typeCode) {
        case 'c': return "character";
        case 'r': return "real";
        case 'b': return "boolean";
        case 'i': return "integer";
        default: return "unknown"; // Handle unexpected types
    }
}
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

start: PROGRAM IDENTIFIER SEMICOLON body 
body: VAR declList BEG src END PERIOD  
declList: 
        | decl declList
decl: vars COLON type SEMICOLON 
    | vars COLON ARRAY LBRACKET INTLITERAL PERIOD PERIOD INTLITERAL RBRACKET OF arraytype SEMICOLON 
    {/*printVariableList();*/ int left = $<test.value>5; int right = $<test.value>8; /*printf("%d %d", left, right); */ arrayReplacement(left, right); /*printVariableList();*/}

vars: vars COMMA IDENTIFIER {if(addVariable($<test.name>3) == 0){}}
    | IDENTIFIER            {if(addVariable($<test.name>1) == 0){}}

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
	    int j = checkVar($<test.name>1); 
	    if(j!=-1){
	    char *type1 = varTypes[j];
	    int flag=0;
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
		    // type2 = "unknown";
			// printf("asfasdfsdf");
		    // printf("Error: Unknown type '%c'\n", $<type>3);
		    flag=1;
		    break;
	    }

	    //printf("Type of the variable is %s\n", type1);
	    //printf("Type of the RHS is %s\n", type2);
	    if(flag==0){
	    if (strcmp(type1, type2) != 0) {
			if(strcmp(type1, "real")==0 && strcmp(type2, "int")==0){
				varValues[j] = strdup($<test.val>3);
			}else{
				if(type1[0] == 'a'){
					type1 = strdup("array");
				}
				printf("Type mismatch. Attempted to assign %s to %s. ", type2, type1);
				yyerror(1);
			}
	    }else{
			varValues[j] = strdup($<test.val>3);
		}
		}
	    //sprintf(varValues[j], "%d", $<test.value>3);}
	    
	 }
}

    | IDENTIFIER LBRACKET indexing RBRACKET ASGOP expression SEMICOLON //INDEXING NOT DONE
    
    {
	    //int j = checkVar($<test.name>1); 
	    //char *type1 = varTypes[j]; 
	    //memmove(type1, type1 + 1, strlen(type1));
	    //printf("aa");
	    //char *str;
	    //printf("xx");
	    //sprintf(str,"%d",$<test.value>3);
	    //printf("ss"); 

	   
	      char *str = strcat($<test.name>1, "[");
	      //printf("%s", str);
	      char *str2 = strdup($<test.val>3);
	      //printf("%s", str2);
	      char *str3 = strcat(str2, "]");
	      char *newStr = strcat(str, str3);
	      //printf("new str %s", newStr);
	      //char *newStr = strcat($<test.name>1, strcat("[", strcat("a", "]")));
	    int j = checkVar(newStr);
	    if(j!=-1){
	    char *type1 = varTypes[j];
	    int flag=0;
	    //printf("Index value is %d ", $<test.value>3);
	 
	    char *type2;
	    switch ($<type>6) {
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
		    // type2 = "unknown";
			
		    // printf("Error: Unknown type '%c'\n", $<type>3);
		    flag=1;
		    break;
	    }

	    //printf("Type of the variable is %s\n", type1);
	    //printf("Type of the RHS is %s\n", type2);
	    
	    // if (strcmp(type1, type2) != 0) {
		// 	printf("Type mismatch. Attempted to assign %s to %s. ", type2, type1);
		// 	yyerror(1);
	    // }else{
	    // 	varValues[j] = strdup($<test.val>3);
		// }
		if(flag==0){
		if (strcmp(type1, type2) != 0) {
			if(strcmp(type1, "real")==0 && strcmp(type2, "int")==0){
				if($<type>3 == 'i'){
					varValues[j] = strdup($<test.val>6);
				}
			}else{
				printf("Type mismatch. Attempted to assign %s to %s. ", type2, type1);
				yyerror(1);
			}
	    }else{
			if($<type>3 == 'i'){
				varValues[j] = strdup($<test.val>6);
			}
		}
		}
	}	    
}

expression: arith_expression {
	$<test.val>$ = strdup($<test.val>1);
	// $<test.value>$ = $<test.value>1; 
	// printf("%s  , ", $<test.val>$);
	$<type>$ = $<type>1;
 }
 | bool_exp {$<test.val>$ = strdup($<test.val>1); $<test.value>$ = $<test.value>1; $<type>$ = $<type>1;}

arith_expression: arith_expression ADDOP tExpression {
	int flag=0;
	if(($<type>1 == 'i' && $<type>3 == 'r') || ($<type>1 == 'r' && $<type>3 == 'i')){
		
	}else if ($<type>1 != $<type>3) {
		if(!(strcmp(type_to_string($<type>1), "unknown")==0 || strcmp(type_to_string($<type>3), "unknown")==0)){
    printf("Conflicting (%s) and (%s) used in RHS, at line number %d\n", 
           type_to_string($<type>1), type_to_string($<type>3), yylineno);
		   flag=1;}
	}
	// $<type>$ = $<type>3;
	if(flag == 0){
	if($<type>1 != $<type>3){
		$<type>$ = 'r';
	}else{
		$<type>$ = $<type>3;
	}
	// int tempint = atoi($<test.val>1) + atoi($<test.val>3);
	char tempchar[25] = "NULL";
	int f=0;
	if($<type>$ == 'r'){
		float tempval;
		if(!strcmp($<string>2, "+")){
			if(strcmp($<test.val>1, "NULL") && strcmp($<test.val>3, "NULL")){
				tempval = atof($<test.val>1) + atof($<test.val>3);
			}else{
				f=1;
			}
		}else if(!strcmp($<string>2, "-")){
			if(strcmp($<test.val>1, "NULL") && strcmp($<test.val>3, "NULL"))
				tempval = atof($<test.val>1) - atof($<test.val>3);
			else
				f=1;
		}
		if(f==0)
			sprintf(tempchar, "%f", tempval);
	}else{
		int tempval;
		if(!strcmp($<string>2, "+")){
			tempval = atoi($<test.val>1) + atoi($<test.val>3);
		}else if(!strcmp($<string>2, "-")){
			tempval = atoi($<test.val>1) - atoi($<test.val>3);
		}
		sprintf(tempchar, "%d", tempval);
	}
	// sprintf(tempchar, "%d", tempint);
	$<test.val>$ = strdup(tempchar);
	// $<test.value>$ = $<test.value>1 + $<test.value>3;
 } }


    | tExpression {$<test.val>$ = strdup($<test.val>1); $<test.value>$ = $<test.value>1; $<type>$ = $<type>1;}

tExpression: tExpression MULOP fExpression {
	int flag=0;
	if(($<type>1 == 'i' && $<type>3 == 'r') || ($<type>1 == 'r' && $<type>3 == 'i')){
		
	}else if ($<type>1 != $<type>3) {
		if(!(strcmp(type_to_string($<type>1), "unknown")==0 || strcmp(type_to_string($<type>3), "unknown")==0)){
    	printf("Conflicting (%s) and (%s) used in RHS, at line number %d\n", 
        type_to_string($<type>1), type_to_string($<type>3), yylineno);
		flag=1;}
	}
	//int tempint = atoi($<test.val>1) * atoi($<test.val>3);
	//char tempchar[25];
	//sprintf(tempchar, "%d", tempint);
	if(flag==0){
	if($<type>1 != $<type>3){
		$<type>$ = 'r';
		
	}else{
		if(!strcmp($<string>2, "/")){
			$<type>$ = 'r';
		}else{
			$<type>$ = $<type>3;
		}
	}
	if($<type>$ == 'r' && !strcmp($<string>2, "%")){
		printf("Use of real datatype with %% operator. Line number: %d", yylineno);
	}
	char tempchar[25] = "NULL";
	int f=0;
	if(!strcmp($<string>2, "/")){
		if($<type>$ == 'r'){
			float tempvar;
			
			if(strcmp($<test.val>1, "NULL") && strcmp($<test.val>3, "NULL"))
			{
				tempvar = atof($<test.val>1) / atof($<test.val>3);
				sprintf(tempchar, "%f", tempvar);
			}else{
				f=1;
			}
		}else{
			int tempvar;
			
			tempvar = atoi($<test.val>1) / atoi($<test.val>3);
			sprintf(tempchar, "%d", tempvar);
		}
	}else if(!strcmp($<string>2, "*")){
		if($<type>$ == 'r'){
			float tempvar;
			if(strcmp($<test.val>1, "NULL") && strcmp($<test.val>3, "NULL"))
			{
				tempvar = atof($<test.val>1) * atof($<test.val>3);
				sprintf(tempchar, "%f", tempvar);
			}
		}else{
			int tempvar;
			
			tempvar = atoi($<test.val>1) * atoi($<test.val>3);
			sprintf(tempchar, "%d", tempvar);
		}
	}else{
		int tempvar;
		
		tempvar = atoi($<test.val>1) % atoi($<test.val>3);
		sprintf(tempchar, "%d", tempvar);
	}
	
	$<test.val>$ = strdup(tempchar);
	//$<test.value>$ = $<test.value>1 * $<test.value>3;
} }
    | fExpression {$<test.val>$ = strdup($<test.val>1); $<test.value>$ = $<test.value>1; $<type>$ = $<type>1; }
    
fExpression: LPAREN arith_expression RPAREN {$<test.val>$ = strdup($<test.val>2); $<test.value>$ = $<test.value>2; $<type>$ = $<type>2;}
    | readable {$<test.val>$ = strdup($<test.val>1); $<test.value>$ = $<test.value>1; $<type>$ = $<type>1;}
    | INTLITERAL {$<test.val>$ = strdup($<test.val>1); $<test.value>$ = $<test.value>1; $<type>$ = 'i';}
    | CHAR_LIT {$<test.val>$ = strdup($<test.val>1); $<type>$ = 'c';}


bool_exp: term {$<type>$ = $<type>1;}
    | bool_exp OR term {
   if ($<type>1 != $<type>3) {
	   if(!(strcmp(type_to_string($<type>1), "unknown")==0 || strcmp(type_to_string($<type>3), "unknown")==0)){
    printf("Conflicting (%s) and (%s) used in RHS, at line number %d\n", 
           type_to_string($<type>1), type_to_string($<type>3), yylineno);}
} $<type>$ = $<type>3;} //CHANGE
    
term: factor {$<type>$ = $<type>1;}
    | term AND factor {
    if ($<type>1 != $<type>3) {
		if(!(strcmp(type_to_string($<type>1), "unknown")==0 || strcmp(type_to_string($<type>3), "unknown")==0)){
    printf("Conflicting (%s) and (%s) used in RHS, at line number %d\n", 
           type_to_string($<type>1), type_to_string($<type>3), yylineno);}
} $<type>$ = $<type>3;} //CHANGE
    
factor: cond {$<type>$ = $<type>1; $<test.val>$ = strdup($<test.val>1);}
    | NOT factor {$<type>$ = $<type>2; 
	    if(strcmp($<test.val>2, "1") == 0){
			$<test.val>$ = strdup("0");
		}
		else{
			$<test.val>$ = strdup("1");
		}
	}
    | LPAREN bool_exp RPAREN {$<type>$ = $<type>2; $<test.val>$ = strdup($<test.val>2);}
    | IDENTIFIER {int j = checkVar($<test.name>1); 
	if(j!=-1){
	if(tolower(varTypes[j][0]) == 'b'){
		$<type>$ = tolower(varTypes[j][0]);
	    $<test.val>$ = strdup($<test.val>1);
					}				
	else{
		printf("Non-boolean value assigned to boolean expression. ");
		yyerror(1);
	}
			}		}

printable: STRING | printable COMMA readable | printable COMMA STRING | arith_expression

range: TO | DOWNTO

cond: arith_expression RELOP arith_expression {
	if ($<type>1 != $<type>3) {
		if(($<type>1 == 'r' && $<type>3 == 'i') || ($<type>3 == 'r' && $<type>1 == 'i')){
			
		}
		else if(!(strcmp(type_to_string($<type>1), "unknown")==0 || strcmp(type_to_string($<type>3), "unknown")==0)){
    printf("Conflicting (%s) and (%s) used in RHS, at line number %d\n", 
           type_to_string($<type>1), type_to_string($<type>3), yylineno);}

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
} 
$<type>$ = 'b';}


/* srcWithIf: 
    | ruleWithIf srcWithIf
    
ruleWithIf: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN readable RPAREN SEMICOLON
    | ifCond
    | forLoopWithIf
    | whileLoopWithIf
    | assignment
    | BEG srcWithIf END

srcWithoutIf: 
    | ruleWithoutIf srcWithoutIf */

src: 
    | rule src
rule: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN readable RPAREN SEMICOLON
    | ifCond
    | forLoop
    | whileLoop
    | assignment
    | BEG src END

/* ruleWithoutIf: WRITE LPAREN printable RPAREN SEMICOLON
    | READ LPAREN readable RPAREN SEMICOLON
    | forLoopWithIf
    | whileLoopWithIf
    | assignment
    | BEG srcWithIf END */

readable: IDENTIFIER 
{ 
	int j = checkVar($<test.name>1); 
	if(j != -1){
		$<test.val>$ = strdup(varValues[j]); 
		if(strcmp($<test.val>$, safe) == 0) 
		{
			if($<type>1 != 'i' && $<type>1 != 'b' && $<type>1 != 'r'){
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
	// printf("hhsd - %s", $<test.val>1);
} 
    | IDENTIFIER LBRACKET indexing RBRACKET 
    {
    	  char *str = strcat($<test.name>1, "[");
	      char *str2 = strdup($<test.val>3);
		  if(strcmp(str2,"NULL")){
	      char *str3 = strcat(str2, "]");
	      char *newStr = strcat(str, str3);
		  //printf("%s--", newStr);
	      int j = checkVar(newStr);

		  
	      
	      
	      if(j!=-1){
			$<test.val>$ = varValues[j];
			if(strcmp($<test.val>$, safe) == 0) 
			{	printf("Variable %s used before it is assigned a value. ", $<test.name>1);
				yyerror(1);
			}
			$<test.val>$ = strdup(varValues[j]);
			$<type>$ = tolower(varTypes[j][0]);
			//printf("type of - %c",$<type>$); 
		  }else{
			  $<test.val>$ = "NULL";
		  }
		}
    }

indexing: arith_expression 
{
	$<test.val>$ = strdup($<test.val>1); 
	// printf("asdfsdfs= %s", $<test.val>$);
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

/* ifCond: IF conditionals THEN BEG matched END SEMICOLON
    | IF conditionals THEN BEG matched END ELSE BEG 
    tail END SEMICOLON
    
matched: IF conditionals THEN BEG matched END ELSE BEG 
    matched END SEMICOLON  
    | srcWithoutIf
tail: IF conditionals THEN BEG tail END SEMICOLON 
    | srcWithoutIf */

ifCond: IF conditionals THEN BEG src END SEMICOLON
    | IF conditionals THEN BEG src END ELSE BEG src END SEMICOLON

forLoop: FOR IDENTIFIER ASGOP arith_expression range arith_expression DO BEG src END SEMICOLON

    {	 
            int j = checkVar($<test.name>2); 
    if(j != -1){
        char *type1 = varTypes[j];
        if($<type>2 == 'i'){
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
                printf("Loop range values must be integer type. ");
                yyerror(1);
        }else{
            printf("Loop variable must be integer type. ");
            yyerror(1);
        }
    }
	}
    
whileLoop: WHILE conditionals DO BEG src END SEMICOLON


conditionals: bool_exp {$<type>$ = $<type>1;}


%%

void main(){
    yyin = fopen("sample.txt", "r");
    yyparse();
    printVariableList();
    printf("valid input\n");
    fclose(yyin);
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



