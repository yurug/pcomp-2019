use std::sync::mpsc::Sender;

use aprinter::APrinter ;
use data::{Cell,Point};
use parser::parse_line;
use parser::parse_change;
use spreadsheet::Spreadsheet;

use printer::*;

use bench::bench;

type Requirement = Cell;

pub struct Processor {
    line_len : usize,
    sheet : Spreadsheet,
    printer : APrinter,
    mychannel : Sender<Requirement>
}

impl Processor {

    pub fn new(view0_path : &str, changes_path : &str, line_len : usize,
               mychannel : Sender<Requirement>) -> Processor {
        let vp = view0_path.to_string() ;
        let cp = changes_path.to_string();
        let sheet = Spreadsheet::new(line_len as u64);
        let printer = APrinter::new(vp,cp,line_len as u64) ;
        Processor {
            line_len : line_len,
            sheet : sheet,
            printer : printer,
            mychannel : mychannel
        }
    }
    
    pub fn initial_valuation(&mut self,buffer : String) {
        let it = buffer.split("\n") ;
        let line_num = it.clone().count() ;
        for (i,line) in it.enumerate() {
            let cells = parse_line(i as u64,line) ;
            for c in cells {
                // print!("add {:?}\n",c);
                self.sheet.add_cell(c) ;
            }
        }
        for i in 0..line_num {
            for j in 0..self.line_len {
                let p = Point{x:j as u64,y:i as u64};
                // quand il y aura le multithreading, il faudra traiter
                // le cas où il n'y a pas de résultat
                let v = match self.sheet.eval(p) {
                    Some(v) => v,
                    None => panic!(format!("{:?} impossible",p))
                };
                let c = Cell{content:v,loc:p};
                self.printer.print(c);
            }
        }
    }

    pub fn changes(&mut self,buffer : String) {
        let mut lines: Vec<&str> = buffer.split("\n").collect();
        lines.pop();
        let cells : Vec<Cell> = lines.into_iter()
            .map(|l| parse_change(l))
            .collect();
        for c in cells {
            self.sheet.add_cell(c) ;
        }
        let consequences = self.sheet.changes();
        self.printer.print_changes(consequences) ;
    }
}
