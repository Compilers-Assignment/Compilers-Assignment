%{
    #include <stdio.h>    
%}

%token NL PL ML ST DIV 
%union{
    char *str;
    int ival;
}

%%

s : E NL 
    {printf("\n....................DONE.........................\n"); return 1; } 

E:  E PL E

    |E ML E


    |E ST E

    
    |E DIV E


    | NUM 

; 
%%