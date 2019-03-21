use data::{Index,Cell,Data};
use data::Data::{Val,Wrong,Fun};
use std::fs::{File,OpenOptions,remove_file};
use std::io::{Write,Seek,SeekFrom};

const NUM_SIZE_IN_BYTES : Index = 3 ;
const EOL_SEP : u8 = 10 ;
const REG_SEP : u8 = ';' as u8 ;
const WRONG_CHAR : u8 = 'p' as u8 ;

/* Le travail du printer consiste essentiellement, du moins pour l'évaluation
   initiale, à imprimer la cellule qu'on lui fournit dans le fichier cible.
   Or, pour qu'il puisse être facilement parallélisé, il faut :
   - que les cellules puissent lui être passées dans le désordre. Il faut
     donc pouvoir calculer à quel byte du fichier cible il doit imprimer une
     cellule, en ne disposant que de ses coordonnées dans le tableur. Ainsi,
     il n'y a jamais besoin d'avoir plus d'une cellule en mémoire à la fois.
     Le fichier n'est ouvert qu'une fois, et on "saute" là où on veut écrire.
   - qu'il puisse agrandir le fichier cible en cours d'exécution. Ainsi, il
     n'a pas besoin qu'un autre fragment du programme l'informe une fois pour
     toutes de la quantité de données à traiter, et donc ne "bloque" pas en
     attendant cette information (nécessitant qu'on ait entièrement parcouru
     -et parsé - le fichier d'entrée). Memmap ne permet pas ce comportement :
     on doit donc s'en passer. */


pub struct APrinter {
    target_path : String,
    change_path : String,
    target : File,
    cells_by_line : Index,
    bytes_by_line : Index,
}

impl APrinter {

    pub fn new(tp : String, cp : String, cells_by_line : Index) -> Self {
        /* Chaque ligne contient (cellules + séparateurs) bytes, où
           cellules = nombre de cellules sur la ligne 
                      * taille d'une cellule (3, dans la mesure où i < 256
                                              s'écrit en ascii sur 3 bytes)
           séparateurs = nombre de cellules sur la ligne 
                         * taille d'un séparateur (1, ';' étant un char ascii)
        */
        let bbl =
            cells_by_line * NUM_SIZE_IN_BYTES
            + cells_by_line ;
        let t = OpenOptions::new()
            .read(true).write(true).create(true).truncate(true)
            .open(tp.clone()).unwrap();
        let p = APrinter {
            target_path : tp,
            change_path : cp,
            target : t,
            cells_by_line : cells_by_line,
            bytes_by_line : bbl,
        } ;
        p
    }

    pub fn cells_by_line(&self) -> Index {
        self.cells_by_line
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
    
    pub fn print(&mut self, cell:Cell) {
        let x = cell.loc.x ;
        let y = cell.loc.y ;

        /* On s'assure qu'on n'essaie pas d'écrire une cellule en-dehors du
           tableur. */ 
        if x >= self.cells_by_line {
            self.clean();
            panic!("Index out of bounds ^^")
        }

        /* On positionne le curseur au caractère o + c, où
           o = début de la ligne cible
             = y * bytes par ligne,
           c = colonne cible
             = x * (taille d'une cellule + 1), 1 pour le séparateur ; */
        let bx = x * (NUM_SIZE_IN_BYTES + 1) ;
        let by = self.bytes_by_line * y ;
        let offset = by + bx ;

        /* On choisit le suffixe de la cellule : ; au milieu d'une ligne,
           \n en fin de ligne. */
        let suffix = if x == self.cells_by_line - 1 {
            EOL_SEP
        } else {
            REG_SEP
        };

        /* On calcule le vecteur de bytes qui doit être écrit. */
        let mut bytes = self.get_val(cell.content) ;
        bytes.push(suffix) ;

        /* Et on l'écrit là où on a calculé le curseur. */
        self.stamp(offset, bytes);
    }

    fn stamp(&mut self, offset : Index, text : Vec<u8>) {

        /* On agrandit le fichier si l'écriture doit avoir lieu sur une ligne
           qui n'existe pas encore. */
        let future_offset = offset + NUM_SIZE_IN_BYTES ;
        let f_len = self.target.metadata().unwrap().len();
        if f_len <= future_offset {
            let _ = self.target.set_len(future_offset + 1) ;
        }

        /* On écrit dans le fichier concret.*/
        let _ = self.target.seek(SeekFrom::Start(offset)) ;
        let _ = self.target.write_all(text.as_slice()) ;
    }

    pub fn print_changes(&mut self, effects: Vec<(Cell, Vec<Cell>)>) {

        let mut file = OpenOptions::new()
            .read(true).write(true).create(true)
            .open(self.change_path.clone()).unwrap();
        
        for (change, consequences) in effects {

            /* On écrit la cellule modifiée. */
            let mut tmp = "after \"".as_bytes().to_vec() ;
            tmp.append(&mut self.raw_change(change)) ;
            tmp.append(&mut "\":".as_bytes().to_vec()) ;
            tmp.push(EOL_SEP) ;
            let _ = file.write_all(tmp.as_slice());

            /* Et on écrit les répercussions sur les autres cellules,
               séparées par newline. */
            for c in consequences {
                tmp.clear() ;
                tmp.append(&mut self.raw_change(c)) ;
                tmp.push(EOL_SEP) ;
                let _ = file.write_all(tmp.as_slice()) ;
            }
        }
    }

    /* Il ne s'agit ensuite que de fonctions de conversions, pour convertir
       les structures et les énumérations qu'on manipule en vecteurs de bytes
       au moment de les écrire. */
    
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
    use data::{Point} ;
    use std::fs::read_to_string ;
    
    #[test]
    fn test_dummest_output() {
        let mut printer = APrinter::new("u0".to_string(),"c0".to_string(),1);
        printer.print(Cell{content:Val(2),loc:Point{x:0,y:0}});
        let content = read_to_string("u0").unwrap();
        printer.clean();
        assert_eq!(content, "  2\n");
    }

    #[test]
    #[should_panic]
    fn test_rectangle_consistency() {
        let mut printer = APrinter::new("u0b".to_string(),"c0b".to_string(),1);
        printer.print(Cell{content:Val(2),loc:Point{x:3,y:0}});
    }

    #[test]
    fn test_two_columns() {
        let mut printer = APrinter::new("u1".to_string(),"c1".to_string(),2);
        printer.print(Cell{content:Val(2),loc:Point{x:0,y:0}});
        printer.print(Cell{content:Val(14),loc:Point{x:1,y:0}});
        let content = read_to_string("u1").unwrap();
        printer.clean();
        assert_eq!(content, "  2; 14\n");
    }

    #[test]
    fn test_minimal_matrix() {
        let mut printer = APrinter::new("u2".to_string(),"c2".to_string(),2);
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
        let mut printer = APrinter::new("u3".to_string(),"c3".to_string(),2);
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
        let mut printer = APrinter::new("u4".to_string(),"c4".to_string(),2);
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
        let mut printer = APrinter::new("u5".to_string(),"c5".to_string(),2);
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
        let mut printer = APrinter::new("u6".to_string(),"c6".to_string(),2);
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
