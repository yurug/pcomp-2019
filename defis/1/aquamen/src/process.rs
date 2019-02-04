use std::sync::mpsc::Sender;
use std::cmp::Ordering;

use parser::parse_line;
use parser::parse_change;
use interpreter::*;
use printer::*;

use data::Matrix;
use data::Cell;

use bench::bench;

type Requirement = Cell;

// FIXME add queue from scheduler to the process for cells
// FIXME add queue from scheduler to the process for changes???
pub fn process(spreadsheet_str: String,
               user_mod: String,
               view0_path: &str,
               changes_path:&str,
               _channel: Sender<Requirement>,
               bench: bench::Sender) {

    let sheet = build_spreadsheet(spreadsheet_str);
    let view0 = eval(&sheet, bench.clone());
    print_spreadsheet(&view0, view0_path);

    //Step 2
    let changes = build_changes(user_mod);
    let mut changes = eval_changes(&changes, &sheet, bench.clone());
    changes.sort_by(|c1, c2| cell_cmp(&c1, &c2));
    print_changes(changes, changes_path);
}

fn cell_cmp(c1: &Cell, c2: &Cell) -> Ordering {
    match c1.loc.x.cmp(&c2.loc.x) {
        Ordering::Equal => c1.loc.y.cmp(&c2.loc.y),
        o => o
    }
}


// FIXME for now we are going to assume that we
// receive the full sheet. This should be modified
// so that it can take an arbitrary rectangle view
// of the spreadsheet
fn build_spreadsheet(buffer: String) -> Matrix<Cell> {
    Matrix::from_2d_vec(buffer.split("\n").map(|l| parse_line(0, l)).collect())
}

fn build_changes(buffer: String) -> Vec<Cell> {
    let mut v: Vec<&str> = buffer.split("\n").collect();
    v.pop();
    v.into_iter().map(|l| parse_change(l)).collect()
}
