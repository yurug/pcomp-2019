use std::collections::HashSet;
use std::collections::HashMap;

use data::{Cell, Data, Point};
use data::Data::{Val, Fun, Wrong};
use data::Function::Count;
use data::PointsListsMap;
use data::PointsList;
use data::Function;
use data::Index;


///===============================///
///========= Spreadsheet =========///
///===============================///


pub struct Spreadsheet {
    width: Index,
    inner: HashMap<Point, Data>,
    bindings: PointsListsMap,
    changes: PointsList
}

impl Spreadsheet {
    
    pub fn new(n: Index) -> Self {
        Spreadsheet {
            width: n,
            inner: HashMap::new(),
            bindings: HashMap::new(),
            changes: HashSet::new()
        }
    }
    
    pub fn add_cell(&mut self, cell: Cell) {
        match self.get(&cell.loc) {
            Some(_) => { self.update_changes(cell.loc); },
            None => self.bind(&cell)
        }
        
        if cell.loc.y < self.width {
            self.set(cell.loc, cell.content);
        } else {
            panic!("add_cell: Index out of bounds error");
        }
    }

    /** Doit être un binding sur add_cell **/
    pub fn add_line(&mut self, cells: Vec<Cell>) {
        cells.into_iter().for_each(|c| self.add_cell(c));
    }

    pub fn eval(&self, p: Point) -> Option<Data> {
        self._eval(p, &mut HashSet::new())
    }

    fn _eval(&self, p: Point, viewed: &mut HashSet<Point>) -> Option<Data> {
        if viewed.contains(&p) {
            return Some(Wrong)
        } 
        viewed.insert(p);
        
        match self.get(&p) {
            Some(Fun(Count(Point { x: x1, y: y1 }, Point { x: x2, y: y2 }, n))) => {
                let mut res = 0;
                for x in *x1..(x2 + 1) {
                    for y in *y1..(y2 + 1) {
                        let point = Point { x: x, y: y };
                        match self._eval(point, viewed) {
                            Some(Val(x)) => if x == *n {
                                res += 1;
                            },
                            Some(Fun(_)) => panic!("Unlikely"),
                            Some(Wrong) => return Some(Wrong),
                            None => return None
                        }
                    }
                }
                Some(Val(res))
            },
            Some(x) => Some(*x),
            None => None
        }
    }

    /** Doit être un binding sur eval **/
    pub fn eval_all(&mut self) -> Vec<Vec<Data>> {
        let height = self.inner.len() as Index / self.width;        

        let mut matrix = Vec::with_capacity(height as usize);

        for i in 0..height {
            let mut line = Vec::with_capacity(self.width as usize);
            
            for j in 0..self.width {
                line.push(self.eval(Point { x: i, y: j })
                          .expect(&format!("Cell {}-{} doesn't exist", i, j)));
            }

            matrix.push(line);
        }
        
        matrix
    }

    pub fn changes(&mut self) -> Vec<Cell> {
        let mut changes = Vec::new();
        
        for point in &self.changes {
            if let Some(data) = self.eval(*point) { // hard to handle if None
                changes.push(Cell { content: data, loc: *point});
            }
        }
        
        changes.sort_by(|c1, c2| c1.cmp(&c2));
        
        changes
    }

    pub fn print(&self) {
        for (k, v) in self.inner.iter() {
            print!("{}-{} ", k.x, k.y);
        }
    }

    ///======== PRIVATE SCOPE ========///

    fn get(&self, p: &Point) -> Option<&Data> {
        self.inner.get(p)
    }

    fn set(&mut self, p: Point, d: Data) {
        self.inner.insert(p, d);
    }

    fn bind(&mut self, c: &Cell) {
        match c.content {
            Val(_) | Wrong => (),
            Fun(f) => self.bind_function(f, c.loc)
        }
    }

    fn bind_function(&mut self, f: Function, p: Point) {        
        match f {
            Count(Point { x: x1, y: y1 }, Point { x: x2, y: y2 }, _) =>
                for x in x1..(x2 + 1) {
                    for y in y1..(y2 + 1) {
                        let pcell = Point { x, y };
                        self.bind_cell(pcell, p);
                    }
                }
        }
    }

    fn bind_cell(&mut self, pcell: Point, p: Point) {
        if let Some(set) = self.bindings.get_mut(&pcell) {
            set.insert(p);
            return;
        }
        
        let mut set = HashSet::new();
        set.insert(p);
        self.bindings.insert(pcell, set);
    }

    fn update_changes(&mut self, p: Point) {
        let mut stack = vec!(p);
        while !stack.is_empty() {            
            let top = stack.pop().unwrap();
            self.changes.insert(top);
            match self.bindings.get(&top) {
                Some(set) => {
                    for point in set {
                        stack.push(*point);
                    }
                },
                None => ()
            }   
        }   
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
        assert_eq!(Val(2), spreadsheet.eval(p).unwrap()) ;
    }

    #[test]
    fn test_order_consistency() {
        let p = Point{x:1,y:0} ;
        let (mut spreadsheet,mut matrix) = basic_guinea_pigs() ;
        matrix.reverse();
        load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
        assert_eq!(Val(8), spreadsheet.eval(p).unwrap()) ;
    }

    #[test]
    fn test_simple_count() {
        let p = Point{x:2,y:1} ;
        let (mut spreadsheet,matrix) = basic_guinea_pigs() ;
        load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
        assert_eq!(Val(2), spreadsheet.eval(p).unwrap()) ;
    }

    #[test]
    fn test_complex_count() {
        let p0 = Point{x:0,y:0};
        let p1 = Point{x:2,y:1};
        let pp = Point{x:1,y:1} ;
        let (mut spreadsheet,mut matrix) = basic_guinea_pigs() ;
        matrix[0][0] = Cell{content:Fun(Count(pp,pp,2)),
                            loc:Point{x:0,y:0}};
        load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
        assert_eq!(
            (spreadsheet.eval(p1).unwrap(), spreadsheet.eval(p0).unwrap()),
            (Val(1), Val(1))
            );
    }
    
    #[test]
    fn test_propagate_wrong() {
        let p = Point{x:2,y:1} ;
        let (mut spreadsheet,mut matrix) = basic_guinea_pigs() ;
        matrix[0][1] = Cell{content:Wrong,loc:Point{x:1,y:0}} ;
        load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
        assert_eq!(Wrong, spreadsheet.eval(p).unwrap()) ;
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
        assert_eq!(spreadsheet.eval(p).unwrap(), Wrong) ;
    }

    #[test]
    #[should_panic]
    fn test_rectangle_consistency() {
        let mut spreadsheet = Spreadsheet::new(3) ;
        spreadsheet.add_cell(Cell{content:Val(0),loc:Point{x:0,y:4}}) ;
    }

    #[test]
    fn test_supports_partial_spreadsheet() {
        let mut spreadsheet = Spreadsheet::new(3) ;
        let p = Point{x:2,y:1} ;
        let v = Val(0);
        let c = Cell{content:v,loc:p};
        spreadsheet.add_cell(c) ;
        assert_eq!(spreadsheet.eval(p).unwrap(), v) ;
    }

    #[test]
    fn test_dependency_missing() {
        let mut spreadsheet = Spreadsheet::new(3) ;
        let p = Point{x:0,y:0} ;
        let c = Cell{content:Fun(Count(p,Point{x:1,y:0},0)),loc:Point{x:2,y:0}};
        spreadsheet.add_cell(c) ;
        assert_eq!(spreadsheet.eval(p), None) ;
    }

    #[test]
    fn test_wrong_if_mut_rec() {
        let mut spreadsheet = Spreadsheet::new(3) ;
        let p1 = Point{x:0,y:0} ;
        let p2 = Point{x:1,y:1} ;
        let c1 = Cell{content:Fun(Count(p2,p2,0)),loc:p1};
        let c2 = Cell{content:Fun(Count(p1,p1,0)),loc:p2};
        spreadsheet.add_cell(c1) ;
        spreadsheet.add_cell(c2) ;
        assert_eq!(spreadsheet.eval(p2).unwrap(),  Wrong) ;
    }
}
