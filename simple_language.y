%{
#include <iostream>
#include <string>
#include <map>
#include <cstdlib>

static std::map<std::string, int> vars;

void yyerror(const char *str) {
    std::cerr << "Error: " << str << std::endl;
}

int yylex();
%}

%union { int num; std::string *str; }

%token<num> NUMBER
%token<str> ID
%token EOL
%token UNKNOWN_CHAR

%type<num> expression
%type<num> assignment

%right '='
%left '+' '-'
%left '*' '/'

%%

program: statement_list
        ;

statement_list: statement
    | statement_list statement
    ;

statement: assignment EOL
    | expression ':' EOL        { std::cout << $1 << std::endl; }
    | error EOL                 { yyerrok; }
    | UNKNOWN_CHAR              { 
        std::cerr << "Error: token desconocido" << std::endl; 
        yyerrok; 
    }
    ;

assignment: ID '=' expression
    { 
        printf("Assign %s = %d\n", $1->c_str(), $3); 
        $$ = vars[*$1] = $3; 
        delete $1;
    }
    ;

expression: NUMBER                  { $$ = $1; }
    | ID                            { 
        if (vars.find(*$1) == vars.end()) {
            yyerror(("Undefined variable: " + *$1).c_str());
            $$ = 0;
        } else {
            $$ = vars[*$1];
        }
        delete $1; 
    }
    | expression '+' expression     { $$ = $1 + $3; }
    | expression '-' expression     { $$ = $1 - $3; }
    | expression '*' expression     { $$ = $1 * $3; }
    | expression '/' expression     { 
        if ($3 == 0) {
            yyerror("Division by zero");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
    | '(' expression ')'            { $$ = $2; }
    | error                         { $$ = 0; }
    ;
%%

int main() {
    int result = yyparse();
    if (result != 0) {
        std::cerr << "Parsing failed" << std::endl;
        return 1;
    }
    return 0;
}