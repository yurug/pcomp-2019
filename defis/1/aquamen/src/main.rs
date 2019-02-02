#[macro_use]
extern crate combine;

mod data;
mod sched;
mod parser;
mod interpreter;
mod printer;

use std::env;

use sched::schedule;

fn main() {
    let args: Vec<String> = env::args().collect();

    schedule(&args[1], &args[2], &args[3], &args[4]);
}
