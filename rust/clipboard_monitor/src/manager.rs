//! Clipboard Manager implementation
extern crate clipboard_win;
use clipboard_win::{WindowsError, get_clipboard_string};
use clipboard_win::wrapper::{get_clipboard_seq_num, is_format_avail};
use std;
use std::time::Duration;

///Clipboard manager provides a primitive hack for console application to handle updates of
///clipboard. It uses ```get_clipboard_seq_num``` to determines whatever clipboard is updated or
///not. Due to that this manager is a bit hacky and not exactly right way to properly work with
///clipboard. On other hand it is the best and most easy option for console application as a proper
///window is required to be created to work with clipboard.
pub struct ClipboardManager {
    tmo: Duration,
    ok_fn: fn(&String) -> (),
    err_fn: fn(&WindowsError) -> (),
}

impl ClipboardManager {
    fn default_ok(text: &String) -> () { println!("Clipboard content: {}", &text); }
    fn default_err(err_code: &WindowsError) -> () { println!("Failed to get clipboard. Reason:{}", err_code.errno_desc()); }
    ///Constructs new ClipboardManager with default settings
    pub fn new() -> ClipboardManager {
        ClipboardManager {
            tmo: Duration::from_millis(100),
            ok_fn: ClipboardManager::default_ok,
            err_fn: ClipboardManager::default_err,
        }
    }

    ///Configure manager's delay between accessing clipboard.
    pub fn delay(&mut self, ms: u64) -> &mut ClipboardManager {
        self.tmo = Duration::from_millis(ms);
        self
    }

    ///Sets callback for successfully retrieved clipboard's text.
    pub fn ok_callback(&mut self, callback: fn(&String) -> ()) -> &mut ClipboardManager
     {
        self.ok_fn = callback;
        self
    }

    ///Sets callback for failed retrieval of clipboard's text.
    ///
    ///Error code is passed from ```get_clipboard_string()```
    pub fn err_callback(&mut self, callback: fn(&WindowsError) -> ()) -> &mut ClipboardManager
     {
        self.err_fn = callback;
        self
    }

    ///Starts manager loop.
    ///
    ///It's infinitely running with delay and checking whatever clipboard is updated.
    ///In case if it is updated callbacks will be called. Depending on whatever clipboard's text
    ///was retrieved or not right callback will be called.
    pub fn run(&self) -> () {
        let mut clip_num: u32 = get_clipboard_seq_num().expect("Lacks sufficient rights to access clipboard(WINSTA_ACCESSCLIPBOARD)");
        loop {
            if is_format_avail(clipboard_win::clipboard_formats::CF_UNICODETEXT)
            {
                // It is very unlikely that we would suddenly start to lack access rights.
                // So let's just skip this iteration. Maybe it is just Windows bug... ^_^
                let new_num = get_clipboard_seq_num().unwrap_or(0);
                if new_num != 0 && clip_num != new_num {
                    clip_num = new_num;
                    match get_clipboard_string() {
                        Ok(clip_text) => (self.ok_fn)(&clip_text),
                        Err(err_code) => (self.err_fn)(&err_code),
                    }
                }
            }
            std::thread::sleep(self.tmo);
        }
    }
}
