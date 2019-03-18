use std::collections::HashSet;
use std::collections::HashMap;

use data::{Cell, Data, Point};
use data::Data::{Val, Fun, Wrong};
use data::Function::Count;
use data::PointsListsMap;
use data::Function;
use data::Index;
use data::new_cell;

use tree2::Tree;

///===============================///
///========= Spreadsheet =========///
///===============================///


pub struct Spreadsheet {
    width: Index,
    inner: Tree,
    functions: HashMap<Point, Function>,
    bindings: PointsListsMap,
}

impl Spreadsheet {

    pub fn new(n: Index) -> Self {
        Spreadsheet {
            width: n,
            inner: Tree::with_size(n),
            functions: HashMap::new(),
            bindings: HashMap::new(),
        }
    }

    pub fn add_cell(&mut self, cell: Cell) {
        if cell.loc.x < self.width {
            self.set(cell.loc, cell.content);
        } else {
            panic!("add_cell: Index out of bounds error");
        }

        self.bind(&cell)
    }

    /** Doit être un binding sur add_cell **/
    // pub fn add_line(&mut self, cells: Vec<Cell>) {
    //     cells.into_iter().for_each(|c| self.add_cell(c));
    // }

    pub fn eval(&mut self, p: Point) -> Option<Data> {
        let data = self._eval(p, &mut HashSet::new());
        match data {
            Some(data) => self.set(p, data),
            None => ()
        }
        data
    }

    fn _eval(&mut self, p: Point, viewed: &mut HashSet<Point>) -> Option<Data> {
        if viewed.contains(&p) {
            return Some(Wrong)
        }
        viewed.insert(p);

        match self.get(&p) {
            Some(Fun(Count(Point { x: x1, y: y1 }, Point { x: x2, y: y2 }, n))) => {
                let mut res = 0;
                for y in y1..(y2 + 1) {
                    for x in x1..(x2 + 1) {
                        let point = Point { x, y };
                        match self._eval(point, viewed) {
                            Some(Val(v)) => if v == n {
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
            Some(d) => Some(d),
            None => None
        }
    }

    // Used for changes
    fn eval_fun(&mut self, p: Point) -> Option<Data> {
        match self.get_fun(&p) {
            Some(Count(Point { x: x1, y: y1 }, Point { x: x2, y: y2 }, n)) => {
                let mut res = 0;
                for y in y1..(y2 + 1) {
                    for x in x1..(x2 + 1) {
                        let point = Point { x, y };
                        match self.get(&point) {
                            Some(Val(v)) => if v == n {
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
            None => panic!("Not a function !")
        }
    }

    fn get_fun(&self, p: &Point) -> Option<Function> {
        match self.functions.get(p) {
            Some(f) => Some(*f),
            None => None
        }
    }

    /** Doit être un binding sur eval **/
    pub fn eval_all(&mut self) -> Vec<Vec<Data>> {
        let height = self.inner.end.y - self.inner.begin.y;


        let mut matrix = Vec::with_capacity(height as usize);

        for y in 0..height {
            let mut line = Vec::with_capacity(self.width as usize);

            for x in 0..self.width {
                line.push(self.eval(Point { x, y })
                          .expect(&format!("Cell {}-{} doesn't exist", x, y)));
            }

            matrix.push(line);
        }

        matrix
    }

    pub fn apply_change(&mut self, cell: Cell) -> (Cell, Vec<Cell>) {
        let mut changes: Vec<Cell> = Vec::new();

        if self.get(&cell.loc).unwrap() != cell.content {
            self.set(cell.loc, cell.content);
            changes.push(cell);

            let mut pending: Vec<Point> = Vec::new();

            match self.bindings.get(&cell.loc) {
                Some(set) => {
                    for point in set {
                        pending.push(*point);
                    }
                },
                None => ()
            }

            while !pending.is_empty() {
                let point = pending.pop().unwrap(); // safe

                // All functions using this cell need to be re-evaluated
                match self.bindings.get(&point) {
                    Some(set) => {
                        for point in set {
                            pending.push(*point);
                        }
                    },
                    None => ()
                }

                // None is not handled
                let last_val = self.get(&point).unwrap();
                let new_val = self.eval_fun(point).unwrap();

                // If the value didn't change, well it's not a change
                if last_val != new_val {
                    self.set(point, new_val); // NEEDED ?
                    changes.push(new_cell(new_val, point));
                }
            }

            changes.sort_by(|c1, c2| c1.cmp(&c2));
        }

        (cell, changes)
    }

    ///======== PRIVATE SCOPE ========///

    fn get(&mut self, p: &Point) -> Option<Data> {
        match self.inner.get(*p) {
            Some(d) => Some(d.content),
            None => None
        }
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
        self.functions.insert(p, f);
        match f {
            Count(Point { x: x1, y: y1 }, Point { x: x2, y: y2 }, _) =>
                for y in y1..(y2 + 1) {
                    for x in x1..(x2 + 1) {
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

    // #[test]
    // fn test_simple_change() {
    //     let c = Cell{content:Val(9),loc:Point{x:0,y:1}} ;
    //     let (mut spreadsheet,matrix) = basic_guinea_pigs() ;
    //     load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
    //     spreadsheet.add_cell(c) ;
    //     assert_eq!(
    //         spreadsheet.changes(),
    //         vec![c]
    //     );
    // }

    // #[test]
    // fn test_propagate_changes() {
    //     let c = Cell{content:Val(9),loc:Point{x:0,y:0}} ;
    //     let (mut spreadsheet,matrix) = basic_guinea_pigs() ;
    //     load_matrix_in_spreadsheet(matrix, &mut spreadsheet) ;
    //     spreadsheet.add_cell(c) ;
    //     assert_eq!(
    //         spreadsheet.changes(),
    //         vec![c, Cell{content:Val(1), loc:Point{x:2,y:1}}]
    //     );
    // }

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
        spreadsheet.add_cell(Cell{content:Val(0),loc:Point{x:4,y:0}}) ;
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
