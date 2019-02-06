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

    fn load_matrix_in_spreadsheet(m : Vec<Vec<Cell>>, s : &mut Spreadsheet) {
        for line in m.iter() {
            for c in line.iter() {
                s.add_cell(*c) ;
            }
        }
    }
    
    fn basic_guinea_pigs () -> (Spreadsheet, Vec<Vec<Cell>>) {
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
        let spreadsheet = Spreadsheet::new(3) ;
        (spreadsheet,cells)
    }

    #[test]
    fn test_simple_val() {
        let p = Point{x:0,y:1} ;
        let (mut spreadsheet,matrix) = basic_guinea_pigs() ;
        load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
        assert_eq!(Cell{content:Val(2),loc:p}, spreadsheet.eval(p)) ;
    }

    #[test]
    fn test_simple_count() {
        let p = Point{x:2,y:1} ;
        let (mut spreadsheet,matrix) = basic_guinea_pigs() ;
        load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
        assert_eq!(Cell{content:Val(2),loc:p}, spreadsheet.eval(p)) ;
    }

    #[test]
    fn test_propagate_wrong() {
        let p = Point{x:2,y:1} ;
        let (mut spreadsheet,mut matrix) = basic_guinea_pigs() ;
        matrix[0][1] = Cell{content:Wrong,loc:Point{x:1,y:0}} ;
        load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
        assert_eq!(Cell{content:Wrong,loc:p}, spreadsheet.eval(p)) ;
    }

}
