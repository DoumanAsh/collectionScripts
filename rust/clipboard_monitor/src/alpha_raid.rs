//! Alpha Raid text corrector

extern crate clipboard_win;
use clipboard_win::{set_clipboard, ClipboardManager};

fn handler_clip_text(text: &String) {
    const BEGIN: &'static[char] = &['「', '（'];
    const END: &'static[char] = &['」', '）'];
    if let (Some(begin_pos), Some(end_pos)) = (text.find(BEGIN), text.find(END)) {
        let end_pos = end_pos + 3; //+3 to go at the symbol of dialogue end
        if end_pos == text.len() { return; }

        println!(">>>Action:");
        if set_clipboard(&text[begin_pos..end_pos]).is_err() {
            println!("Hmph... failed to update clipboard");
        }
        else {
            println!("Dialogue is extracted");
        }
    }
}

fn main() {
    println!("####################################");
    println!("#  Alpha Ride ITH text corrector   #");
    println!("####################################");
    ClipboardManager::new().delay(10).ok_callback(handler_clip_text).run();
}
