type Num = u8 ;

#[derive(Debug)]
pub struct Point {
    pub x: u32,
    pub y: u32
}

#[derive(Debug)]
pub struct Cell {
    pub content: Data,
    pub loc: Point
}

#[derive(Debug)]
pub enum Data {
    Val(Num),
    Fun(Function) 
}

#[derive(Debug)]
pub enum Function {
    Count(Point, Point, Num)
}
