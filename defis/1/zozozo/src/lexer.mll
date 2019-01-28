{
open Lexing
open Parser

exception SyntaxError of string
}

let int = ['0'-'9']+
let newline = '\r' | '\n' | "\r\n"

rule read = parse
| newline  { NEWLINE (* Lexing.new_line lexbuf; read lexbuf *) }
| int      { INT (int_of_string (Lexing.lexeme lexbuf)) }
| '('      { LPAREN }
| ')'      { RPAREN }
| ','      { COLON }
| ';'      { SEMICOLON }
| "="      { EQ }
| "#"      { SHARP }
| eof      { EOF }
| _ { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
