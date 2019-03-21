use std::sync::mpsc::channel;
use std::fs;
use std::fs::File;
use std::io::{BufReader,BufRead} ;

use process::Processor;
use parser::parse_line;
use aprinter::APrinter;

pub fn schedule(sheet_path: &str,
                user_mod_path: &str,
                view0_path: &str,
                changes_path: &str) {
    let line_len = guess_line_len(sheet_path) ;
    let mut sheet = BufReader::new(File::open(sheet_path).unwrap());
    let printer =  APrinter::new(view0_path.to_string(),
                                 changes_path.to_string(),
                                 line_len as u64) ;
    let (sender, _recv) = channel();
    let mut proc = Processor::new(printer, sender);

    let mut line_offset = 0 ;
    let mut res = Ok(1);
    while res.unwrap() > 0 {
        let mut line = String::new() ;
        res = sheet.read_line(&mut line) ;
        proc.initial_valuation(line, line_offset) ;
        line_offset += 1 ;
    }

    let changes = fs::read_to_string(user_mod_path)
        .expect(&format!("Something went wrong while reading {}", user_mod_path));
    proc.changes(changes);
}

fn guess_line_len(sheet_path: &str) -> usize {
    let sheet = BufReader::new(File::open(sheet_path).unwrap());
    let line : String = sheet.lines().next().unwrap().unwrap() ;
    parse_line(0,&*line).len()
}
