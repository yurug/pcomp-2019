#[macro_use]
extern crate combine;

mod data;
// mod parser;
mod process;
mod sched;

use std::env;
use std::fs;
use process::*;

fn main() {
    let args: Vec<String> = env::args().collect();
    let filename = &args[1];
    let contents = fs::read_to_string(filename)
        .expect("Something went wrong reading the file");
    print!("{}",contents);
    sched::schedule(contents)
}
