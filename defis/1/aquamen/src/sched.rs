
use std::sync::mpsc::channel;
use std::fs;

use process::Processor;
use parser::parse_line;


use bench::bench;

// FIXME test!!!!

pub fn schedule(sheet_path: &str,
                user_mod_path: &str,
                view0_path: &str,
                changes_path: &str,
                bench: bench::Sender) {

    let sheet = fs::read_to_string(sheet_path)
        .expect("Something went wrong reading the first file");
    let changes = fs::read_to_string(user_mod_path)
        .expect("Something went wrong reading the second file");
    let line_len = match sheet.split("\n").next() {
        Some(t) => parse_line(0,t).len(),
        None => 0
    } ;
    let (sender, _recv) = channel();
    let mut proc = Processor::new(view0_path, changes_path, line_len, sender);
    proc.initial_valuation(sheet);
    proc.changes(changes);
}
