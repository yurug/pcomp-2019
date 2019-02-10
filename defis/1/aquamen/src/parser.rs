use combine::attempt;
use combine::parser::char::{digit, spaces, string};
use combine::parser::repeat::many;
use combine::parser::repeat::skip_until;
use combine::{between, choice, from_str, many1, token, value, Parser, Stream};
use data::Data::{Fun, Val, Wrong};
use data::Function::Count;
use data::Num;
use data::{Cell, Data, Point};

const CSEP: char = ';';
const LCOUNT: &'static str = "=#(";
const RCOUNT: char = ')';
const SEP_COUNT: char = ',';

parser! {
    fn num[I]()(I) -> Num where [I: Stream<Item = char>] {
        spaces().with(from_str(many1::<String, _>(digit())))
    }
}

parser! {
    fn val[I]()(I) -> Data where [I: Stream<Item = char>] {
        num().map(Val)
    }
}

parser! {
    fn coord[I]()(I) -> u64 where [I: Stream<Item = char>] {
        spaces().with(from_str(many1::<String, _>(digit())))
    }
}

parser! {
    fn count[I]()(I) -> Data where [I: Stream<Item = char>] {
        let p = (coord().skip(token(SEP_COUNT)),
                 coord().skip(token(SEP_COUNT)),
                 coord().skip(token(SEP_COUNT)),
                 coord().skip(token(SEP_COUNT)),
                 num())
            .map(|t| Fun(Count(Point{x:t.0,y:t.1},
                               Point{x:t.2,y:t.3},
                               t.4)));

        between(string(LCOUNT),token(RCOUNT), p)
    }
}

parser! {
    fn wrong[I]()(I) -> Data where [I: Stream<Item = char>] {
        skip_until(token(CSEP)).with(value(Wrong))
    }
}

parser! {
    fn data[I]()(I) -> Data where [I: Stream<Item = char>] {
        spaces().with(choice!(
            attempt(val()),
            attempt(count()),
            wrong()
        ))
    }
}

parser! {
    fn data_line[I]()(I) -> Vec<Data> where [I: Stream<Item = char>] {
        many(choice!(
            attempt(data().skip(spaces().with(token(CSEP)))),
            data())
        )
    }
}

parser! {
    fn change[I]()(I) -> Cell where [I: Stream<Item = char>] {
        (coord(),
         coord(),
         data())
            .map(|t| Cell{loc:Point{x:t.1,y:t.0},
                            content:t.2})
    }
}

pub fn parse_line(line: u64, s: &str) -> Vec<Cell> {
    let res = data_line().easy_parse(s);
    let (v,s) = match res {
        Ok((v, s)) => (v,s),
        Err(e) => panic!("{}",e),
    };
    let mut cell_vec = Vec::new();
    for i in 0..(v.len()) {
        cell_vec.push(Cell {
            content: v[i].clone(),
            loc: Point {
                x: i as u64,
                y: line
            },
        });
    }
    // Il reste du texte : on finit avec Wrong
    if s.len() > 0 {
        cell_vec.push(Cell{content:Wrong,
                           loc:Point{x:v.len() as u64,y:line}});
    }
    cell_vec
}

pub fn parse_change(s : &str) -> Cell {
    let res = change().easy_parse(s) ;
    match res {
        Ok((v, _)) => v,
        Err(e) => panic!("{}",e),
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    const T1 : (&str,Data) = ("12",Val(12));
    const T2 : (&str,Data) = ("=#(1250,6000,7851,92573, 125)",
                              Fun(Count
                                 (Point{x:1250,y:6000},
                                  Point{x:7851,y:92573},
                                  125)));
    const T3 : (&str,Data) = ("aaa",Wrong);
    const T4 : (&str,Cell) = ("489 1000 5",Cell{content:Val(5),
                                                loc:Point{x:1000,y:489}});
    const T5 : (&str,Cell) = ("489 1000 =#(1250,6000,7851,92573, 125)",
                              Cell{content:Fun(Count
                                               (Point{x:1250,y:6000},
                                                Point{x:7851,y:92573},
                                                125)),
                                   loc:Point{x:1000,y:489}});
    
    #[test]
    fn test_simple_val() {
        assert_eq!(
            parse_line(0,T1.0),
            vec![Cell{content:T1.1,loc:Point{x:0,y:0}}]
        );
    }

    #[test]
    fn test_simple_form() {
        assert_eq!(
            parse_line(0,T2.0),
            vec![Cell{content:T2.1,loc:Point{x:0,y:0}}]
        );
    }

    #[test]
    fn test_simple_wrong() {
        assert_eq!(
            parse_line(0,T3.0),
            vec![Cell{content:T3.1,loc:Point{x:0,y:0}}]
        );
    }

    #[test]
    fn test_list() {
        assert_eq!(
            parse_line(0,&format!("{}{}{}{}{}{}{}",
                                 T1.0,CSEP,T2.0,CSEP,T3.0,CSEP,T1.0)),
            vec![
                Cell{content:T1.1,loc:Point{x:0,y:0}},
                Cell{content:T2.1,loc:Point{x:1,y:0}},
                Cell{content:T3.1,loc:Point{x:2,y:0}},
                Cell{content:T1.1,loc:Point{x:3,y:0}}
            ]
        );
    }

    #[test]
    fn test_spaces_robustness() {
        assert_eq!(
            parse_line(0,&format!("{} {} {}{} {}{} {}",
                                 T1.0,CSEP,T2.0,CSEP,T3.0,CSEP,T1.0)),
            vec![
                Cell{content:T1.1,loc:Point{x:0,y:0}},
                Cell{content:T2.1,loc:Point{x:1,y:0}},
                Cell{content:T3.1,loc:Point{x:2,y:0}},
                Cell{content:T1.1,loc:Point{x:3,y:0}}
            ]
        );
    }

    #[test]
    fn test_list_ending_wrong() {
        assert_eq!(
            parse_line(0,&format!("{}{}{}",T1.0,CSEP,T3.0)),
            vec![
                Cell{content:T1.1,loc:Point{x:0,y:0}},
                Cell{content:T3.1,loc:Point{x:1,y:0}}
            ]
        );
    }

    #[test]
    fn test_simple_change() {
        assert_eq!(parse_change(T4.0),T4.1);
    }

    #[test]
    fn test_count_change() {
        assert_eq!(parse_change(T5.0),T5.1);
    }
}
