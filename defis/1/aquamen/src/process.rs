use std::sync::mpsc::Sender;

use parser::parse_line;
use parser::parse_change;
use spreadsheet::*;
use printer::*;

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

    let mut sheet = build_spreadsheet(spreadsheet_str);
    let view0 = sheet.eval_all();
    print_spreadsheet(&view0, view0_path);

    //Step 2
    let changes = build_changes(user_mod);

    for cell in changes {
        sheet.add_cell(cell);
    }
    
    print_changes(sheet.changes(), changes_path);
}


// FIXME for now we are going to assume that we
// receive the full sheet. This should be modified
// so that it can take an arbitrary rectangle view
// of the spreadsheet
fn build_spreadsheet(buffer: String) -> Spreadsheet {
    let mut it = buffer.split("\n") ;
    let head = it.next();
    let first_line = match head {
        Some(t) => parse_line(0,t),
        None => vec![],
    };
    
    let mut res = Spreadsheet::new(first_line.len() as u64);
    res.add_line(first_line) ;
    
    for (i,line) in it.enumerate() {
        res.add_line(parse_line((i + 1) as u64, line));
    }

    res
}

fn build_changes(buffer: String) -> Vec<Cell> {
    let mut v: Vec<&str> = buffer.split("\n").collect();
    v.pop();
    v.into_iter().map(|l| parse_change(l)).collect()
}
