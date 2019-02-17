# Principaux concepts de programmation

Certains de ces concepts sont communs à beaucoup de langages de programmation alors que d'autres sont un peu plus éxotiques.
Leur maîtrise vous ouvrira les portes de la programmation en Rust, qui n'est pas sans douleurs...

## Variable et mutabilité

Par défaut, les variables dans Rust sont immutables.

```rust
{
    let x = 5;
    x = 6;
}
```

```
error[E0384]: cannot assign twice to immutable variable `x`
 --> src/main.rs:4:5
  |
2 |     let x = 5;
  |         - first assignment to `x`
3 |     x = 6;
  |     ^^^^^ cannot assign twice to immutable variable
```
Le mot-clé `mut` permet de déclarer une variable mutable.
```rust
{
    let mut x = 5;
    x = 6;
}
```

```
$ cargo build
   Compiling variables v0.1.0 (file:///projects/variables)
    Finished dev [unoptimized + debuginfo] target(s) in 0.30 secs
```

### Constantes

Les constantes sont toujours immutables et ne peuvent pas utilisées avec le mot-clé `mut`.

```rust
const MAX_POINTS: u32 = 100_000;
```

### Masquage de nom

On peut déclarer une nouvelle variable du même nom qu'une autre la précédent, ce qui cache l'ancienne valeur associée à ce nom dans la zone d'éxecution courante.

```rust
{
    let x = 5;
    let x = x + 1;
}
```

Ce concept permet notamment de changer le type de la valeur associée à un nom au fil du programme, ce qui dans certains cas peut être très pratique et plus lisible.

```rust
{
    let spaces = "   ";
    let spaces = spaces.len();
}
```

## Types de données primitifs

### Types simples

```rust
{
    let i: i8 = 127; // i16, i32, i64, i128, isize
    let u: u8 = 255; // u16, u32, u64, u128, usize
    
    let f: f32 = 5.0; // f64
    
    let b: bool = true;
    
    let c: char = 'c';
    let heart_eyed_cat = '😻';
}
```

### Types composés

On peut définir des tuples de valeurs ayant des types distincts.

```rust
{
    let tup: (i32, f64, u8) = (500, 6.4, 1);

    let (x, y, z) = tup;
    
    let five_hundred = tup.0;
    let six_point_four = tup.1;
    let one = tup.2;
}
```

Tableaux

```rust
{
    let a: [i32; 5] = [1, 2, 3, 4, 5];

    let element = a[10];
}
```

```
$ cargo run
   Compiling arrays v0.1.0 (file:///projects/arrays)
    Finished dev [unoptimized + debuginfo] target(s) in 0.31 secs
     Running `target/debug/arrays`
thread '<main>' panicked at 'index out of bounds: the len is 5 but the index is
 10', src/main.rs:6
note: Run with `RUST_BACKTRACE=1` for a backtrace.
```

## Fonctions

La fonction "main" est le point d'entrée de tout programme Rust.
Chaque fonction est constituée d'une suite de déclarations optionnellement suivie par une expression dont le résultat sera la valeur de retour.

```rust
fn main() {
    let x = plus_one(5);

    println!("The value of x is: {}", x);
}

fn plus_one(x: i32) -> i32 {
    x + 1
}
```

Une fonction ne se terminant pas par une expression renvoie le type `()` correspondant au tuple vide.

```
error[E0308]: mismatched types
 --> src/main.rs:7:28
  |
7 |   fn plus_one(x: i32) -> i32 {
  |  ____________________________^
8 | |     x + 1;
  | |          - help: consider removing this semicolon
9 | | }
  | |_^ expected i32, found ()
  |
  = note: expected type `i32`
             found type `()`
```

## Structures de contrôle

### L'expression `if`

Structure conditionnelle classique qui peut être utilisée comme une déclaration ou une expression.

```rust
{
    let x = 5;
    let number = if x < 1 {
        0
    } else if x > 10 {
        1
    } else {
        2
    };
}
```

### Les boucles

La boucle `loop` inconditionnelle

```rust
{
    let mut counter = 0;

    let result = loop {
        counter += 1;

        if counter == 10 {
            break counter * 2;
        }
    };
}
```

La boucle `while` et la boucle `for` classiques

```rust
{
    let a = [10, 20, 30, 40, 50];
    
    let mut index = 0;
    while index < 5 {
        println!("the value is: {}", a[index]);
        index = index + 1;
    }

    for element in a.iter() {
        println!("the value is: {}", element);
    }
    for index in 0..5 {
        println!("the value is: {}", a[index]);
    }
}
```

## Les structures

### Définition et instanciation

Une structure est une composition de données où chaque champs est nommé (l'ordre des membres n'est donc pas significatif).

```rust
struct Rectangle {
    width: u32,
    height: u32,
}
```

```rust
let r = Rectangle {
    height: 25,
    width: 10,
}
```

### Définition de méthodes

On définit des méthodes pour une structure dans un bloc `impl` associé au même nom.
Chaque méthode a pour premier paramêtre le mot-clé `self`, ce qui permet d'utiliser les champs de la structure depuis laquelle elle est invoquée.

```rust
impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
    
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}

fn main() {
    let rect1 = Rectangle { width: 30, height: 50 };

    println!(
        "The area of the rectangle is {} square pixels.",
        rect1.area()
    );
}
```

### Définition de fonctions associées

On peut également définir des fonctions qui ne s'exécutent pas à partir d'une instance de structure.

```rust
impl Rectangle {
    fn square(size: u32) -> Rectangle {
        Rectangle { width: size, height: size }
    }
}
```

```rust
let sq = Rectangle::square(3);
```

## Les types énumérés

### Définition

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(u8, u8, u8),
}
```

### Instanciation

```rust
let message = Message::ChangeColor(0,255,255);
```

### Le type `enum` Option

```rust
enum Option<T> {
    Some(T),
    None,
}
```

## Le pattern matching

```rust
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter,
}

fn value_in_cents(coin: Coin) -> u32 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}
```

### Éxhaustivité

```rust
{
    let value = 8;
    match value {
       1 => println!("one"),
       3 => println!("three"),
       5 => println!("five"),
       7 => println!("seven"),
       _ => (),
    }
}
```

### Sucre syntaxique

```rust
let value = Some(14);

match some_u8_value {
    Some(3) => println!("three"),
    _ => (),
}

if let Some(3) = value {
    println!("three");
}
```

## Gestion des erreurs

### Ne pas paniquer !

```rust
fn main() {
    panic!("crash and burn");
}
```

```
$ cargo run
   Compiling panic v0.1.0 (file:///projects/panic)
    Finished dev [unoptimized + debuginfo] target(s) in 0.25 secs
     Running `target/debug/panic`
thread 'main' panicked at 'crash and burn', src/main.rs:2:4
note: Run with `RUST_BACKTRACE=1` for a backtrace.
```

### Erreurs non rédhibitoires

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

```rust
use std::fs::File;

fn main() {
    let f = File::open("hello.txt");

    let f = match f {
        Ok(file) => file,
        Err(error) => {
            panic!("There was a problem opening the file: {:?}", error)
        },
    };
}
```

Raccourcis

```rust
fn main() {
    let f = File::open("hello.txt").unwrap();
}
```

```rust
fn main() {
    let f = File::open("hello.txt").expect("Failed to open hello.txt");
}
```

### Propagation des erreurs

```rust

use std::io;
use std::io::Read;
use std::fs::File;

fn read_username_from_file() -> Result<String, io::Error> {
    let f = File::open("hello.txt");

    let mut f = match f {
        Ok(file) => file,
        Err(e) => return Err(e),
    };

    let mut s = String::new();

    match f.read_to_string(&mut s) {
        Ok(_) => Ok(s),
        Err(e) => Err(e),
    }
}
```

```rust
fn read_username_from_file() -> Result<String, io::Error> {
    let mut f = File::open("hello.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}
```