
use data::{Matrix, Data};
use data::Data::{Val, Wrong};

// FIXME test!!!
pub fn print(block: Matrix<Num>) {
    for line in block.lines() {
        print!("{}\n",line.into_iter().map(|i| i.to_string()).collect::<Vec<String>>().join(";"))
    }
}
