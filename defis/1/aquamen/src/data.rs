struct Coordinates {
    x: u32,
    y: u32
}

struct Cell {
    content: Val,
    location: Coordinates
}

enum Val {
    Raw(u8),
    Fun(Function) 
}

enum Function {
    Count(Coordinates, Coordinates, u8)
}
