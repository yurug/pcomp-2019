#[macro_use]
extern crate combine;
extern crate separator;

mod data;
mod sched;
mod parser;
mod interpreter;
mod printer;
mod process;
mod bench;


use std::env;

use sched::schedule;

fn main() {
    let args: Vec<String> = env::args().collect();

    let bench = bench::bench::start_bench();

    schedule(&args[1], &args[2], &args[3], &args[4], bench);
}
