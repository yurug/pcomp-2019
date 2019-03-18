use std::cmp::Ordering;
use std::collections::HashSet;
use std::collections::HashMap;

pub type Num = u8;
pub type Index = u64;


///===============================///
///============ Point ============///
///===============================///


// FIXME derivemore pour cmp (Ord)
#[derive(Debug,Clone,Copy,PartialEq,Hash,Eq)]
pub struct Point {
    pub x: Index,
    pub y: Index
}

impl PartialOrd for Point {
    fn partial_cmp(&self, p: &Point) -> Option<Ordering> {
        Some(self.cmp(p))
    }
}

impl Ord for Point {
    fn cmp(&self, p: &Point) -> Ordering {
        match self.y.cmp(&p.y) {
            Ordering::Equal => self.x.cmp(&p.x),
            o => o
        }
    }
}

pub type PointsList = HashSet<Point>;

pub type PointsListsMap = HashMap<Point, PointsList>;


///===============================///
///============= Cell ============///
///===============================///


#[derive(Debug,Clone,Copy,PartialEq)]
pub struct Cell {
    pub content: Data,
    pub loc: Point
}

impl Cell {
    pub fn cmp(self, c: &Cell) -> Ordering {
        self.loc.cmp(&c.loc)
    }
}

pub fn new_cell(d: Data, p: Point) -> Cell {
    Cell { content: d, loc: p}
}


///===============================///
///============= Data ============///
///===============================///


#[derive(Debug,Clone,Copy,PartialEq)]
pub enum Data {
    Val(Num),
    Fun(Function),
    Wrong
}


///===============================///
///=========== Function ==========///
///===============================///

#[derive(Debug,Clone,Copy,PartialEq)]
pub enum Function {
    Count(Point, Point, Num)
}


/// For now we don't need requirements
/// so the type is a "singleton" type
/// to avoid to deal with passing Vec around.
/// The type will be changed when we do need
/// to split sheets
// pub type Requirements = Vec<Cell>;
pub enum Requirements { Empty }

// pub struct Matrix<T: Copy + Clone> {
//     inner: Vec<Vec<T>>
// }

// impl<T: Copy + Clone> Matrix<T> {
//     pub fn from_2d_vec(v: Vec<Vec<T>>) -> Matrix<T> {
//         Matrix {
//             inner: v
//         }
//     }
//     // Assume that the ordering of cell is conserved
//     // aka mat.get(p).loc == p
//     pub fn get(&self, c: Point) -> T {
//         self.inner[c.x as usize][c.y as usize].clone()
//     }

//     pub fn lines(&self) -> &Vec<Vec<T>> {
//         &self.inner
//     }
// }
