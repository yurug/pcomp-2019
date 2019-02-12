use data::{Index,Cell,Data,Point};
use data::Data::{Val,Wrong,Fun};
use std::fs::{OpenOptions,remove_file,read_to_string};
use std::io::{Write,Seek,SeekFrom,Error};

const NUM_SIZE_IN_BYTES : Index = 3 ;
const EOL_SEP : u8 = 10 ;
const REG_SEP : u8 = ';' as u8 ;
const WRONG_CHAR : u8 = 'p' as u8 ;

pub struct APrinter {
    target_path : String,
    change_path : String,
    cells_by_line : Index,
    bytes_by_line : Index,
}

impl APrinter {

    pub fn new(tp : String, cp : String, cells_by_line : Index) -> Self {
        let bbl =
        // place pour les numéros
            cells_by_line * NUM_SIZE_IN_BYTES
        // place pour les séparateurs
            + cells_by_line ;
        let p = APrinter {
            target_path : tp,
            change_path : cp,
            cells_by_line : cells_by_line,
            bytes_by_line : bbl,
        } ;
        p.clean() ;
        p
    }

    pub fn clean(&self) {
        let r1 = remove_file(self.target_path.clone());
        if r1.is_err() {
            println!("{} unreachable",self.target_path)
        }
        let r2 = remove_file(self.change_path.clone());
        if r2.is_err() {
            println!("{} unreachable",self.change_path)
        }
    }
    
    pub fn print(&self, cell:Cell) {
        let x = cell.loc.x ;
        let y = cell.loc.y ;
        if x >= self.cells_by_line {
            self.clean();
            panic!("Index out of bounds ^^")
        }
        let bx = x * (NUM_SIZE_IN_BYTES + 1) ;
        let by = self.bytes_by_line * y ;
        let offset = by + bx ;
        let suffix = if x == self.cells_by_line - 1 {
            EOL_SEP
        } else {
            REG_SEP
        };
        let mut bytes = self.get_val(cell.content) ;
        bytes.push(suffix) ;
        self.stamp(offset, bytes);
    }

    fn stamp(&self, offset : Index, text : Vec<u8>) {
        let mut file = OpenOptions::new()
            .read(true).write(true).create(true)
            .open(self.target_path.clone()).unwrap();
        let future_offset = offset + NUM_SIZE_IN_BYTES ;
        let f_len = file.metadata().unwrap().len();
        if f_len <= future_offset {
            self.io_may_crash(&mut || file.set_len(future_offset + 1)) ;
        }
        self.io_may_crash(&mut || {
            match file.seek(SeekFrom::Start(offset)) {
                Ok(_) => file.write_all(text.as_slice()),
                Err(e) => Err(e),
            }
        });
    }

    pub fn print_changes(&self, effects: Vec<(Cell, Vec<Cell>)>) {

        let mut file = OpenOptions::new()
            .read(true).write(true).create(true)
            .open(self.change_path.clone()).unwrap();
        
        for (change, consequences) in effects {

            let mut tmp = "after \"".as_bytes().to_vec() ;
            tmp.append(&mut self.raw_change(change)) ;
            tmp.append(&mut "\":".as_bytes().to_vec()) ;
            tmp.push(EOL_SEP) ;
            self.io_may_crash(&mut || file.write_all(tmp.as_slice()));

            for c in consequences {
                tmp.clear() ;
                tmp.append(&mut self.raw_change(c)) ;
                tmp.push(EOL_SEP) ;
                self.io_may_crash(&mut || file.write_all(tmp.as_slice())) ;
            }
        }
    }

    fn io_may_crash<F>(&self, f:&mut F)
    where F: FnMut() -> Result<(),Error> {
        let r = f() ;
        if r.is_err() {
            self.clean() ;
            panic!(r.unwrap_err()) ;
        }
    }
    
    fn raw_change(&self, change : Cell) -> Vec<u8> {
        let mut preffix = format!("{} {} ",change.loc.y,change.loc.x)
            .as_bytes()
            .to_vec() ;
        let mut d = self.raw_val(change.content) ;
        let mut line : Vec<u8> = vec![];
        line.append(&mut preffix);
        line.append(&mut d) ;
        line
    }
    
    fn raw_val(&self, d : Data) -> Vec<u8> {
        let res = match d {
            Val(n) => n.to_string().as_bytes().to_vec(),
            Wrong => vec![WRONG_CHAR],
            Fun(_) => vec![],
        };
        if res.len() == 0 {
            self.clean();
            panic!("Functions forbidden here !")
        } else {
            res
        }
    }

    fn get_val(&self, d : Data) -> Vec<u8> {
        let mut significant = self.raw_val(d);
        let res = self.fill_with_until_size(&mut significant,
                                            ' ' as u8,
                                            NUM_SIZE_IN_BYTES as usize);
        res
    }

    fn fill_with_until_size(&self,v:&mut Vec<u8>, stamp:u8, size:usize)
                            -> Vec<u8> {
        let missing = size - v.len() ;
        let mut v0 = Vec::with_capacity(missing) ;
        for _ in 0..missing {
            v0.push(stamp);
        }
        v0.append(v) ;
        v0
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test_dummest_output() {
        let printer = APrinter::new("u0".to_string(),"c0".to_string(),1);
        printer.print(Cell{content:Val(2),loc:Point{x:0,y:0}});
        let content = read_to_string("u0").unwrap();
        printer.clean();
        assert_eq!(content, "  2\n");
    }

    #[test]
    #[should_panic]
    fn test_rectangle_consistency() {
        let printer = APrinter::new("u0b".to_string(),"c0b".to_string(),1);
        printer.print(Cell{content:Val(2),loc:Point{x:3,y:0}});
    }

    #[test]
    fn test_two_columns() {
        let printer = APrinter::new("u1".to_string(),"c1".to_string(),2);
        printer.print(Cell{content:Val(2),loc:Point{x:0,y:0}});
        printer.print(Cell{content:Val(14),loc:Point{x:1,y:0}});
        let content = read_to_string("u1").unwrap();
        printer.clean();
        assert_eq!(content, "  2; 14\n");
    }

    #[test]
    fn test_minimal_matrix() {
        let printer = APrinter::new("u2".to_string(),"c2".to_string(),2);
        printer.print(Cell{content:Val(2),loc:Point{x:0,y:0}});
        printer.print(Cell{content:Val(14),loc:Point{x:1,y:0}});
        printer.print(Cell{content:Val(100),loc:Point{x:0,y:1}});
        printer.print(Cell{content:Val(86),loc:Point{x:1,y:1}});
        let content = read_to_string("u2").unwrap();
        printer.clean();
        assert_eq!(content, "  2; 14\n100; 86\n");
    }

    #[test]
    fn test_unordered_print() {
        let printer = APrinter::new("u3".to_string(),"c3".to_string(),2);
        printer.print(Cell{content:Val(100),loc:Point{x:0,y:1}});
        printer.print(Cell{content:Val(14),loc:Point{x:1,y:0}});
        printer.print(Cell{content:Val(2),loc:Point{x:0,y:0}});
        printer.print(Cell{content:Val(86),loc:Point{x:1,y:1}});
        let content = read_to_string("u3").unwrap();
        printer.clean();
        assert_eq!(content, "  2; 14\n100; 86\n");
    }

    #[test]
    fn test_with_wrong() {
        let printer = APrinter::new("u4".to_string(),"c4".to_string(),2);
        printer.print(Cell{content:Val(100),loc:Point{x:0,y:1}});
        printer.print(Cell{content:Wrong,loc:Point{x:1,y:0}});
        printer.print(Cell{content:Val(2),loc:Point{x:0,y:0}});
        printer.print(Cell{content:Val(86),loc:Point{x:1,y:1}});
        let content = read_to_string("u4").unwrap();
        printer.clean();
        assert_eq!(content, "  2;  p\n100; 86\n");
    }

    #[test]
    fn test_changes() {
        let printer = APrinter::new("u5".to_string(),"c5".to_string(),2);
        let first =  Cell{content:Val(72),loc:Point{x:5,y:100}} ;
        let changes = vec![
            (first,
            vec![
                first,
                Cell{content:Val(150),loc:Point{x:1230,y:4}},
            ])
        ];
        printer.print_changes(changes);
        let content = read_to_string("c5").unwrap();
        printer.clean();
        assert_eq!(content,
                   "after \"100 5 72\":\n100 5 72\n4 1230 150\n");
    }

    #[test]
    fn test_changes_with_wrong() {
        let printer = APrinter::new("u6".to_string(),"c6".to_string(),2);
        let first =  Cell{content:Val(72),loc:Point{x:5,y:100}} ;
        let changes = vec![
            (first,
            vec![
                first,
                Cell{content:Wrong,loc:Point{x:500,y:10}},
                Cell{content:Val(150),loc:Point{x:1230,y:4}},
            ])
        ];
        printer.print_changes(changes);
        let content = read_to_string("c6").unwrap();
        printer.clean();
        assert_eq!(content,
                   "after \"100 5 72\":\n100 5 72\n10 500 p\n4 1230 150\n");
    }
}
