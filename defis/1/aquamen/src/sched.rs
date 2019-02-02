
use std::fs;
use std::cmp::Ordering;

use parser::parse_line;
use interpreter::*;
use printer::*;

use data::Matrix;
use data::Cell;

// FIXME test!!!!

pub fn schedule(in1: &str, in2: &str, out1: &str, out2: &str) {

    // Step 1

    let buffer = fs::read_to_string(in1)
        .expect("Something went wrong reading the file");

    let spreadsheet = build_spreadsheet(buffer);

    let spreadsheet = eval(&spreadsheet);

    print_spreadsheet(&spreadsheet, out1);


    //Step 2

    let buffer = fs::read_to_string(in2)
        .expect("Something went wrong reading the file");
    
    let changes = build_changes(buffer);

    let mut changes = eval_changes(&changes, &spreadsheet);

    changes.sort_by(|c1, c2| cell_cmp(&c1, &c2));

    print_changes(changes, out2);
}

// FIXME for now we are going to assume that we
// receive the full sheet. This should be modified
// so that it can take an arbitrary rectangle view
// of the spreadsheet
fn build_spreadsheet(buffer: String) -> Matrix<Cell> {
    // FIXME setup the channel
    // FIXME setup a way to get data from central authority?
    Matrix::from_2d_vec(buffer.split("\n").map(|l| parse_line(0, l)).collect())
}



fn build_changes(buffer: String) -> Vec<Cell> {
    Vec::new() // TODO Hugo
}

fn cell_cmp(c1: &Cell, c2: &Cell) -> Ordering {
    match c1.loc.x.cmp(&c2.loc.x) {
        Ordering::Equal => c1.loc.y.cmp(&c2.loc.y),
        o => o
    }
}
