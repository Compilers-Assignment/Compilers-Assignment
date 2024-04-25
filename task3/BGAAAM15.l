%{
    #include "y.tab.h"
    #include <stdio.h>
    #include <string.h>
    int linecount = 1;
    int yylex();
    void convertToLower(char * s)
    {
        for(int i = 0; s[i]; i++)
        {
            if (s[i]>='A' && s[i]<='Z')
                s[i] = s[i] + ('a' - 'A');
        }
    }
    int ctr=0;
%}

%option caseless

letter [A-Za-z]
number [0-9]

%%

\/\/.* {}
\n {linecount++;}
\".*\" {
    yylval.string = yytext;
    return STRING;
}

\'[0-9a-zA-Z]\' {
    // printf("%d %s character literal\n", linecount, yytext); 
    yylval.string = yytext;
    return CHAR_LIT;
}

(program|integer|real|boolean|char|to|downto|if|else|var|while|for|do|array|begin|end|read|write|then|array|of|writeln) { 
    
    // printf("%d %s keyword\n", linecount, yytext); 
    convertToLower(yytext);
    if(strcmp(yytext, "program") == 0) return PROGRAM;
    if(strcmp(yytext, "integer") == 0) return INTEGER;
    if(strcmp(yytext, "real") == 0) return REAL;
    if(strcmp(yytext, "boolean") == 0) return BOOLEAN;
    if(strcmp(yytext, "char") == 0) return CHAR;
    if(strcmp(yytext, "to") == 0) return TO;
    if(strcmp(yytext, "downto") == 0) return DOWNTO;
    if(strcmp(yytext, "if") == 0) return IF;
    if(strcmp(yytext, "else") == 0) return ELSE;
    if(strcmp(yytext, "var") == 0) return VAR;
    if(strcmp(yytext, "while") == 0) return WHILE;
    if(strcmp(yytext, "for") == 0) return FOR;
    if(strcmp(yytext, "do") == 0) return DO;
    if(strcmp(yytext, "array") == 0) return ARRAY;
    if(strcmp(yytext, "begin") == 0) return BEG;
    if(strcmp(yytext, "end") == 0) return END;
    if(strcmp(yytext, "read") == 0) return READ;
    if(strcmp(yytext, "write") == 0) return WRITE;
    if(strcmp(yytext, "writeln") == 0) return WRITE;
    if(strcmp(yytext, "then") == 0) return THEN;
    if(strcmp(yytext, "array") == 0) return ARRAY;
    if(strcmp(yytext, "of") == 0) return OF;
}


(and|or|not) {

    // printf("%d %s boolean operator\n", linecount, yytext); 
    convertToLower(yytext);
    if(strcmp(yytext, "and") == 0) return AND;
    if(strcmp(yytext, "or") == 0) return OR;
    if(strcmp(yytext, "not") == 0) return NOT;
}

{number}* {
    
    // printf("%d %s integer literal\n", linecount, yytext); 

    yylval.string = yytext;
    return INTLITERAL;
}

{letter}({letter}|{number}|_)* {

    // // printf("%d %s identifier\n", linecount, yytext); 
    yylval.string = yytext;
    return IDENTIFIER;
}

("+"|"-"|"*"|"/"|"%") {

    // printf("%d %s arithmetic operator\n", linecount, yytext);  
    convertToLower(yytext);

    if (strcmp(yytext, "+") == 0) {
        yylval.string = "+";
        return ADDOP;
    }
    if (strcmp(yytext, "-") == 0) {
        yylval.string = "-";
        return ADDOP;
    }
    if (strcmp(yytext, "*") == 0) {
        yylval.string = "*";
        return MULOP;
    };
    if (strcmp(yytext, "/") == 0) {
        yylval.string = "/";
        return MULOP;
    };
    if (strcmp(yytext, "%") == 0) {
        yylval.string = "%";
        return MULOP;
    };
}

(=|<>|<|>|<=|>=) {

    // printf("%d %s relational operator\n", linecount, yytext);
    if(strcmp(yytext, "=") == 0){
        yylval.string = "=";
    }
    if(strcmp(yytext, "<>") == 0){
        yylval.string = "<>";
    }
    if(strcmp(yytext, "<") == 0){
        yylval.string = "<";
    }
    if(strcmp(yytext, ">") == 0){
        yylval.string = ">";
    }
    if(strcmp(yytext, "<=") == 0){
        yylval.string = "<=";
    }
    if(strcmp(yytext, ">=") == 0){
        yylval.string = ">=";
    }
    return RELOP;
}

:= {

    // printf("%d %s assignment operator\n", linecount, yytext); 

    return ASGOP;
}

(";"|:|"["|"]"|,|"("|")"|".") {
    // printf("%d %s punctuator\n", linecount, yytext); 
    convertToLower(yytext);

    if (strcmp(yytext, ";") == 0) return SEMICOLON;
    if (strcmp(yytext, ":") == 0) return COLON;
    if (strcmp(yytext, "[") == 0) return LBRACKET;
    if (strcmp(yytext, "]") == 0) return RBRACKET;
    if (strcmp(yytext, ",") == 0) return COMMA;
    if (strcmp(yytext, "(") == 0) return LPAREN;
    if (strcmp(yytext, ")") == 0) return RPAREN;
    if (strcmp(yytext, ".") == 0) return PERIOD;
}

" "* {;}

[ \r] {;}

. {
    // ctr++;
    printf("syntax error\n");
    exit(0);
    // printf("%d\n",ctr);
    }
%%
