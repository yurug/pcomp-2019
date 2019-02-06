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

    /** Doit être un binding sur add_cell **/
    pub fn add_line(&mut self, cells: Vec<Cell>) {
        panic!("Impl missing")
    }

    pub fn eval(&mut self, p : Point) -> Option<Cell> {
        panic!("Impl missing")
    }

    /** Doit être un binding sur eval **/
    pub fn eval_all(&mut self) -> &Vec<Vec<Data>> {
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
        assert_eq!(Cell{content:Val(2),loc:p}, spreadsheet.eval(p).unwrap()) ;
    }

    #[test]
    fn test_order_consistency() {
        let p = Point{x:1,y:0} ;
        let (mut spreadsheet,mut matrix) = basic_guinea_pigs() ;
        matrix.reverse();
        load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
        assert_eq!(Cell{content:Val(8),loc:p}, spreadsheet.eval(p).unwrap()) ;
    }

    #[test]
    fn test_simple_count() {
        let p = Point{x:2,y:1} ;
        let (mut spreadsheet,matrix) = basic_guinea_pigs() ;
        load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
        assert_eq!(Cell{content:Val(2),loc:p}, spreadsheet.eval(p).unwrap()) ;
    }

    #[test]
    fn test_propagate_wrong() {
        let p = Point{x:2,y:1} ;
        let (mut spreadsheet,mut matrix) = basic_guinea_pigs() ;
        matrix[0][1] = Cell{content:Wrong,loc:Point{x:1,y:0}} ;
        load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
        assert_eq!(Cell{content:Wrong,loc:p}, spreadsheet.eval(p).unwrap()) ;
    }

    #[test]
    fn test_simple_change() {
        let c = Cell{content:Val(9),loc:Point{x:0,y:1}} ;
        let (mut spreadsheet,matrix) = basic_guinea_pigs() ;
        load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
        spreadsheet.add_cell(c) ;
        assert_eq!(
            spreadsheet.changes(),
            vec![c]
        );
    }

    #[test]
    fn test_propagate_changes() {
        let c = Cell{content:Val(9),loc:Point{x:0,y:0}} ;
        let (mut spreadsheet,matrix) = basic_guinea_pigs() ;
        load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
        spreadsheet.add_cell(c) ;
        assert_eq!(
            spreadsheet.changes(),
            vec![c, Cell{content:Val(1), loc:Point{x:2,y:1}}]
        );
    }
    
    #[test]
    fn test_simple_cycle() {
        let mut spreadsheet = Spreadsheet::new(3) ;
        let p = Point{x:0,y:0} ;
        let c = Cell{content:Fun(Count(p,p,0)),loc:p};
        spreadsheet.add_cell(c) ;
        assert_eq!(spreadsheet.eval(p).unwrap(), Cell{content:Wrong,loc:p}) ;
    }

    #[test]
    #[should_panic]
    fn test_rectangle_consistency() {
        let mut spreadsheet = Spreadsheet::new(3) ;
        spreadsheet.add_cell(Cell{content:Val(0),loc:Point{x:4,y:0}}) ;
    }

    #[test]
    fn test_supports_unfinished_spreadsheet() {
        let mut spreadsheet = Spreadsheet::new(3) ;
        let p = Point{x:2,y:1} ;
        let c = Cell{content:Val(0),loc:p};
        spreadsheet.add_cell(c) ;
        assert_eq!(spreadsheet.eval(p).unwrap(), c) ;
    }
}
