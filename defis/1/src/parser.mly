%{
    open Ast
%}

%token <int> INT
%token LPAREN RPAREN SEMICOLON EQ SHARP

%start <Ast.spreadsheet> spreadsheet
%%

spreadsheet:
  e = separated_list(line, NEWLINE) EOF { e }

line:
  l = separated_list(cell, SEMICOLON) { l }

cell:
  i = INT     { { value = i; formula = None } }
| f = formula { { value = Undefined; formula = Some f } }

formula:
  EQ SHARP LPAREN
    r1 = INT COLON c1 = INT COLON r2 = INT COLON c2 = INT COLON v = INT
  RPAREN
  { Occ (({ r = r1; c = c1}, { r = r2; c = c2}), v) }
