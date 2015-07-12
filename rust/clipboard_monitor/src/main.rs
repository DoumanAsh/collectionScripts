extern crate winapi;
extern crate user32;
extern crate clipboard_win;

use user32::GetClipboardSequenceNumber;
use clipboard_win::*;

fn handler_clip_text(text: &String) {
    println!("Clipboard content: {}", &text);
    if !text.starts_with(' ') && !text.ends_with(' ') { return; }
    if set_clipboard(text.trim_matches(' ')).is_err() {
        println!("Failed to update clipboard");
    }
}

fn main() {
    println!("Clipboard monitor");
    unsafe {
        let mut clipboard_num = GetClipboardSequenceNumber();
        loop {
            let new_num = GetClipboardSequenceNumber();
            if clipboard_num != new_num {
                println!("Clipboard update: {}", clipboard_num);
                clipboard_num = new_num;
                match get_clipboard() {
                    Ok(clip_text) => { handler_clip_text(&clip_text) },
                    Err(err_text) => { println!("Failed to get clipboard. Reason:{}", err_text) },
                }
            println!(">>>");
            }
            std::thread::sleep_ms(100);
        }
    }
}
