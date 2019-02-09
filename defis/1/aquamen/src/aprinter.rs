use data::{Index,Cell,Data,Point};
use data::Data::{Val,Wrong,Fun};
use std::fs::{File,OpenOptions,remove_file,read_to_string};
use std::io::{Write,Seek,SeekFrom};

const NUM_SIZE_IN_BYTES : Index = 3 ;
const EOL_SEP : u8 = 10 ;
const REG_SEP : u8 = ';' as u8 ;
const WRONG_CHAR : char = 'p' ;

pub struct APrinter {
    target_path : String,
    cells_by_line : Index,
    bytes_by_line : Index,
    view_file : File,
}

impl APrinter {

    pub fn new(tp : String, cells_by_line : Index) -> Self {
        let bbl =
        // place pour les numéros
            cells_by_line * NUM_SIZE_IN_BYTES
        // place pour les séparateurs
            + cells_by_line ;
        // let path: PathBuf = "view0.csv" ;
        let f = OpenOptions::new()
            .read(true).write(true).create(true)
            .open(tp.clone())
            .unwrap();
        APrinter {
            target_path : tp,
            cells_by_line : cells_by_line,
            bytes_by_line : bbl,
            view_file : f,
        }
    }

    pub fn print(&mut self, cell:Cell) {
        let f_len = self.view_file.metadata().unwrap().len();
        let x = cell.loc.x ;
        let y = cell.loc.y ;
        if x >= self.cells_by_line {
            remove_file(self.target_path.clone());
            panic!("Index out of bounds ^^")
        }
        let bx = x * (NUM_SIZE_IN_BYTES + 1) ;
        let by = self.bytes_by_line * y ;
        let offset = by + bx ;
        let future_offset = offset + NUM_SIZE_IN_BYTES ;
        if f_len <= future_offset {
            self.view_file.set_len(future_offset + 1) ;
        }
        let suffix = if x == self.cells_by_line - 1 {
            EOL_SEP
        } else {
            REG_SEP
        };
        let mut bytes = get_val(cell.content) ;
        bytes.push(suffix) ;
        self.view_file.seek(SeekFrom::Start(offset));
        self.view_file.write_all(bytes.as_slice()) ;
    }

    pub fn print_changes(&mut self, cells:Vec<Cell>) {
        panic!("Impl missing")
    }
}

fn get_val(d : Data) -> Vec<u8> {
    let mut significant = match d {
        Val(n) => n.to_string().as_bytes().to_vec(),
        Wrong => vec![WRONG_CHAR as u8],
        Fun(_) => panic!("Functions forbidden here !"),
    };
    let res = fill_with_until_size(&mut significant,
                                   ' ' as u8,
                                   NUM_SIZE_IN_BYTES as usize);
    res
}

fn fill_with_until_size(v:&mut Vec<u8>, stamp:u8, size:usize) -> Vec<u8> {
    let missing = size - v.len() ;
    let mut v0 = Vec::with_capacity(missing) ;
    for _ in 0..missing {
        v0.push(stamp);
    }
    v0.append(v) ;
    v0
}

#[cfg(test)]
mod tests {

    use super::*;
    use std::panic::catch_unwind ;

    #[test]
    fn test_fill() {
        let mut v = vec!['2' as u8] ;
        let v1 = fill_with_until_size(&mut v, ' ' as u8, 3) ;
        assert_eq!(v1, vec![' ' as u8, ' ' as u8, '2' as u8]);
    }
    
    #[test]
    fn test_dummest_output() {
        let path = "test0.csv";
        let mut printer = APrinter::new(path.to_string(),1);
        printer.print(Cell{content:Val(2),loc:Point{x:0,y:0}});
        let content = read_to_string(path).unwrap();
        remove_file(path);
        assert_eq!(content, "  2\n");
    }

    #[test]
    #[should_panic]
    fn test_rectangle_consistency() {
        let path = "test0b.csv";
        let mut printer = APrinter::new(path.to_string(),1);
        printer.print(Cell{content:Val(2),loc:Point{x:3,y:0}});
    }

    #[test]
    fn test_two_columns() {
        let path = "test1.csv";
        let mut printer = APrinter::new(path.to_string(),2);
        printer.print(Cell{content:Val(2),loc:Point{x:0,y:0}});
        printer.print(Cell{content:Val(14),loc:Point{x:1,y:0}});
        let content = read_to_string(path).unwrap();
        remove_file(path);
        assert_eq!(content, "  2; 14\n");
    }

    #[test]
    fn test_minimal_matrix() {
        let path = "test2.csv";
        let mut printer = APrinter::new(path.to_string(),2);
        printer.print(Cell{content:Val(2),loc:Point{x:0,y:0}});
        printer.print(Cell{content:Val(14),loc:Point{x:1,y:0}});
        printer.print(Cell{content:Val(100),loc:Point{x:0,y:1}});
        printer.print(Cell{content:Val(86),loc:Point{x:1,y:1}});
        let content = read_to_string(path).unwrap();
        remove_file(path);
        assert_eq!(content, "  2; 14\n100; 86\n");
    }

    #[test]
    fn test_unordered_print() {
        let path = "test3.csv";
        let mut printer = APrinter::new(path.to_string(),2);
        printer.print(Cell{content:Val(100),loc:Point{x:0,y:1}});
        printer.print(Cell{content:Val(14),loc:Point{x:1,y:0}});
        printer.print(Cell{content:Val(2),loc:Point{x:0,y:0}});
        printer.print(Cell{content:Val(86),loc:Point{x:1,y:1}});
        let content = read_to_string(path).unwrap();
        remove_file(path);
        assert_eq!(content, "  2; 14\n100; 86\n");
    }

    #[test]
    fn test_with_wrong() {
        let path = "test4.csv";
        let mut printer = APrinter::new(path.to_string(),2);
        printer.print(Cell{content:Val(100),loc:Point{x:0,y:1}});
        printer.print(Cell{content:Wrong,loc:Point{x:1,y:0}});
        printer.print(Cell{content:Val(2),loc:Point{x:0,y:0}});
        printer.print(Cell{content:Val(86),loc:Point{x:1,y:1}});
        let content = read_to_string(path).unwrap();
        remove_file(path);
        assert_eq!(content, "  2;  p\n100; 86\n");
    }
}
