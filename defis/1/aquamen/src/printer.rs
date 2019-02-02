
use std::fs::File;
use std::io::Write;

use data::{Matrix, Cell, Data};
use data::Data::{Val, Wrong};

// FIXME test!!!
pub fn print_spreadsheet(block: &Matrix<Cell>, filename: &str) {

    let mut file = File::create(filename).expect(
        &format!("Error creating file {}", filename)
    );
    
    for line in block.lines() {
        writeln!(&mut file, "{}", line.into_iter().map(|cell| {
            to_string(&cell.content)
        }).collect::<Vec<String>>().join(";")).unwrap();
    }
}

pub fn print_changes(block: Vec<Cell>, filename: &str) {
    let mut file = File::create(filename).expect(
        &format!("Error creating file {}", filename)
    );

    writeln!(&mut file, "after \"r c d\":").unwrap();

    for cell in block {
        let v = to_string(&cell.content);
        writeln!(&mut file, "{} {} {}", cell.loc.x, cell.loc.y, v).unwrap();
    }
}

fn to_string(data: &Data) -> String {
    match data {
        Val(v) => v.to_string(),
        Wrong => "P".to_owned(),
        _ => panic!("Unexpected value while printing")
    }
}
