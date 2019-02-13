
#[cfg(feature="bench")]
pub mod bench {
    use std::sync::mpsc;
    use std::thread;
    use std::sync::mpsc::channel;
    use std::sync::mpsc::Receiver;
    use std::time::{Duration, Instant};
    use separator::Separatable;
    pub type Sender = mpsc::Sender<u64>;
    fn count(recv: Receiver<u64>) {
        let mut before = Instant::now();
        let mut count = 0;
        loop {
            count = match recv.try_recv() {
                Err(_) => count,
                Ok(_)  => count + 1,
            };
            let now = Instant::now();
            if now.duration_since(before) > Duration::from_secs(2) {
                let c: u64 = count / 2;
                println!("{} cells processed in 1s", c.separated_string());
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
        RESULT_SENDER = Some(Mutex::new(send));
        send
    }

    pub fn get_sender() -> Sender {
        RESULT_SENDER.as_ref().unwrap().lock().unwrap().clone()
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
        pub fn send(&self, _t: u64) -> Result<(), SendError<u64>> { Ok(()) }
    }
    pub fn start_bench() -> Sender {
        Sender {}
    }

    pub fn get_sender() -> Sender {
        Sender {}
    }
}
