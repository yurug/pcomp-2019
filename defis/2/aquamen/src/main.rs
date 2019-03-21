#![feature(fn_traits)]
#[macro_use]
extern crate combine;
extern crate separator;
extern crate log;
extern crate env_logger;
extern crate rand;

mod data;
mod sched;
mod serialize;
mod parser;
mod printer;
mod process;
mod bench;
mod spreadsheet;
mod aprinter ;
mod tree2;
mod area;

use std::env;

use sched::schedule;

use log::{Record, Level, Metadata, LevelFilter};

static MY_LOGGER: MyLogger = MyLogger;

struct MyLogger;

impl log::Log for MyLogger {
    fn enabled(&self, metadata: &Metadata) -> bool {
        metadata.level() <= Level::Trace
    }

    fn log(&self, record: &Record) {
        if self.enabled(record.metadata()) {
            println!("{} - {}", record.level(), record.args());
        }
    }
    fn flush(&self) {}
}

fn main() {
    log::set_logger(&MY_LOGGER).unwrap();
    log::set_max_level(LevelFilter::Trace);

    let _bench = bench::bench::start_bench();

    let args: Vec<String> = env::args().collect();

    schedule(&args[1], &args[2], &args[3], &args[4]);
}
