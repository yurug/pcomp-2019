#[macro_use]
extern crate combine;
extern crate separator;
// extern crate memmap;

mod data;
mod sched;
mod parser;
mod printer;
mod process;
mod bench;
mod spreadsheet;
mod aprinter ;
mod tree;

use std::env;

use sched::schedule;

fn main() {
    let args: Vec<String> = env::args().collect();

    let bench = bench::bench::start_bench();

    schedule(&args[1], &args[2], &args[3], &args[4], bench);
}
