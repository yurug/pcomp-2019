use combine::parser::char::{spaces, digit, char};
use combine::{choice,from_str,many1,Parser,sep_by,token,position,Stream};
use combine::error::ParseError;
use data::{Point,Cell,Data};
use data::Data::{Val};

parser!{
    fn num[I]()(I) -> Data
    where [I: Stream<Item = char>]
    {
        from_str(many1::<String, _>(digit())).map(Val)
    }
}

parser!{
    fn data_vec[I]()(I) -> Vec<Data>
    where [I: Stream<Item = char>]
    {
        sep_by(choice!(
            num()
        ), token(','))
    }
}


pub fn run() {
    println!("{:?}", data_vec().easy_parse("123,12,200"));
}
