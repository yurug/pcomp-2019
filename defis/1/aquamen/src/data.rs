pub type Num = u8 ;

#[derive(Debug,Clone)]
pub struct Point {
    pub x: u64,
    pub y: u64
}

#[derive(Debug)]
pub struct Cell {
    pub content: Data,
    pub loc: Point
}

#[derive(Debug,Clone)]
pub enum Data {
    Val(Num),
    Fun(Function),
    Wrong
}

#[derive(Debug,Clone)]
pub enum Function {
    Count(Point, Point, Num)
}
