{
open Lexing
open Parser

exception SyntaxError of string
}

let int = ['0'-'9']+
let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"

rule read = parse
| white    { read lexbuf }
| newline  { NEWLINE (* Lexing.new_line lexbuf; read lexbuf *) }
| int      { INT (int_of_string (Lexing.lexeme lexbuf)) }
| '('      { LPAREN }
| ')'      { RPAREN }
| ';'      { SEMICOLON }
| "="      { EQ }
| "#"      { SHARP }
| eof      { EOF }
| _ { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
