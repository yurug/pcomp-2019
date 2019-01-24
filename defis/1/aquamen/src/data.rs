type Num = u8 ;

struct Coordinates {
    x: u32,
    y: u32
}

struct Cell {
    content: Data,
    location: Coordinates
}

pub enum Data {
    Val(Num),
    Fun(Function) 
}

enum Function {
    Count(Coordinates, Coordinates, Num)
}
