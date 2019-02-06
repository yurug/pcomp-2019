use data::{Cell,Data,Point} ;
use data::Data::{Val,Fun,Wrong} ;
use data::Function::Count ;

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

    pub fn eval(&mut self, p : Point) -> Cell {
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

#[cfg(test)]
mod tests {

    use super::*;

    fn basic_guinea_pig () -> Spreadsheet {
        let num = 5 ;
        let r = (Point{x:0,y:0},Point{x:2,y:0});
        let cells = vec![
            vec![Cell{content:Val(num),loc:Point{x:0,y:0}},
                 Cell{content:Val(8),loc:Point{x:1,y:0}},
                 Cell{content:Val(num),loc:Point{x:2,y:0}}],
            vec![Cell{content:Val(2),loc:Point{x:0,y:1}},
                 Cell{content:Val(2),loc:Point{x:1,y:1}},
                 Cell{content:Fun(Count(r.0,r.1,num)),loc:Point{x:2,y:1}}]
        ];
        let mut spreadsheet = Spreadsheet::new(3) ;
        for line in cells.iter() {
            for c in line.iter() {
                spreadsheet.add_cell(*c) ;
            }
        }
        spreadsheet
    }

    #[test]
    fn test_simple_val() {
        let mut spreadsheet = basic_guinea_pig() ;
        let p = Point{x:0,y:1} ;
        assert_eq!(Cell{content:Val(2),loc:p}, spreadsheet.eval(p)) ;
    }

}
