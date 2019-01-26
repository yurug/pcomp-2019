%{
    open Ast

    let row, col = ref 0, ref 0
    let data = Data.create 16 16
%}

%token <int> INT
%token LPAREN RPAREN COLON SEMICOLON EQ SHARP NEWLINE EOF

%start <Ast.formula> formla
%%

data:

line:
  f = formula SEMICOLON line NEWLINE { Data.set {r = !row; c = !col} f data}

formula:
  i = INT                 { Val i }
| EQ SHARP f = occurences { f }

occurences:
  SHARP LPAREN
    r1 = INT COLON c1 = INT COLON r2 = INT COLON c2 = INT COLON v = INT
  RPAREN
  { Occ (({ r = r1; c = c1}, { r = r2; c = c2}), v) }
