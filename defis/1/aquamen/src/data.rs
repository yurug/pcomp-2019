
pub type Num = u8 ;

pub struct Matrix<T: Copy + Clone> {
    inner: Vec<Vec<T>>
}

impl<T: Copy + Clone> Matrix<T> {
    pub fn from_2d_vec(v: Vec<Vec<T>>) -> Matrix<T> {
        Matrix {
            inner: v
        }
    }
    // Assume that the ordering of cell is conserved
    // aka mat.get(p).loc == p
    pub fn get(&self, c: Point) -> T {
        self.inner[c.x as usize][c.y as usize].clone()
    }

    pub fn lines(&self) -> &Vec<Vec<T>> {
        &self.inner
    }
}

#[derive(Debug,Clone,Copy,PartialEq)]
pub struct Point {
    pub x: u64,
    pub y: u64
}

#[derive(Debug,PartialEq,Copy,Clone)]
pub struct Cell {
    pub content: Data,
    pub loc: Point
}

#[derive(Debug,Clone,PartialEq,Copy)]
pub enum Data {
    Val(Num),
    Fun(Function),
    Wrong
}

#[derive(Debug,Clone,PartialEq,Copy)]
pub enum Function {
    Count(Point, Point, Num)
}
