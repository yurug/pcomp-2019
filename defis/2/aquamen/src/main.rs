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

// use sched::schedule;

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
    // log::set_logger(&MY_LOGGER).unwrap();
    // FIXME better handling of logging
    // log::set_max_level(LevelFilter::Trace);

    let bench = bench::bench::start_bench();

    // use tree::Tree;
    // use data::Data::*;
    // use data::Point;
    // use data::Cell;

    // let num_cell: u8 = 15;

    // let mut t = Tree::with_size(num_cell as u64);

    // let mut cells = Vec::with_capacity((num_cell as usize) * (num_cell as usize));

    // for i in 0..num_cell {
    //     for j in 0..num_cell {
    //         cells.push((i, j))
    //     }
    // }

    // for (i, j) in &cells {
    //     t.add_cell(Cell{
    //         loc: Point{x:*i as u64, y:*j as u64},
    //         content: Val(i+j),
    //     });
    // }
    // for (i, j) in &cells {
    //     println!("{:?}", t.get_cell(Point{x:*i as u64, y:*j as u64}));
    // }
    // println!("{}", t.size());

    // let args: Vec<String> = env::args().collect();


    // schedule(&args[1], &args[2], &args[3], &args[4], bench);
}
