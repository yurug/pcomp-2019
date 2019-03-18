
#[cfg(feature="bench")]
pub mod bench {
    use std::sync::mpsc;
    use std::sync::*;
    use std::thread;
    use std::sync::mpsc::channel;
    use std::sync::mpsc::Receiver;
    use std::time::{Duration, Instant};
    use separator::Separatable;
    pub type Sender = mpsc::Sender<i64>;
    fn count(recv: Receiver<i64>) {
        let mut before = Instant::now();
        let mut count = 0;
        loop {
            count = match recv.try_recv() {
                Err(_) => count,
                Ok(i)  => count + i,
            };
            let now = Instant::now();
            if now.duration_since(before) > Duration::from_millis(100) {
                let c: i64 = count;
                println!("{} cells in memory", c.separated_string());
                before = now;
                count = 0;
            }
        }
    }

    static mut RESULT_SENDER: Option<Mutex<Sender>> = None;

    pub fn start_bench() -> Sender {
        let (send, recv) = channel();
        thread::spawn(move || {
            count(recv);
        });
        unsafe {
            RESULT_SENDER = Some(Mutex::new(send));
            RESULT_SENDER.as_ref().unwrap().lock().unwrap().clone()
        }
    }

    pub fn get_sender() -> Sender {
        unsafe {
            RESULT_SENDER.as_ref().unwrap().lock().unwrap().clone()
        }
    }
}

#[cfg(not(feature="bench"))]
pub mod bench {
    /// Mimic Sender but do nothing
    use std::sync::mpsc::SendError;
    #[derive(Debug,Copy,Clone)]
    pub struct Sender {}
    unsafe impl Send for Sender {}
    impl Sender {
        pub fn send(&self, _t: i64) -> Result<(), SendError<i64>> { Ok(()) }
    }
    pub fn start_bench() -> Sender {
        Sender {}
    }

    pub fn get_sender() -> Sender {
        Sender {}
    }
}
