use data::{Cell,Data} ;

pub struct Spreadsheet {
}

impl Spreadsheet {
    
    pub fn new(n: u64) -> Self {
        panic!("Impl missing")
    }
    
    pub fn add_cell(&mut self, cell : Cell) {
        panic!("Impl missing")
    }

    pub fn add_line(&mut self, cells: Vec<Cell>) {
        /** Doit être un binding sur add_cell **/
        panic!("Impl missing")
    }

    pub fn eval(&mut self, x : u64, y : u64) -> Cell {
        panic!("Impl missing")
    }
    
    pub fn eval_all(&mut self) -> &Vec<Vec<Data>> {
        /** Doit être un binding sur eval **/
        panic!("Impl missing")
    }

    pub fn changes(&mut self) -> Vec<Cell> {
        panic!("Impl missing")
    }
}
