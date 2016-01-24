//! VN text corrector

extern crate clipboard_win;
use clipboard_win::{set_clipboard};
pub mod utils;
pub mod manager;

fn handler_clip_text(text: &String) {
    if !utils::is_jp(text) { return; }

    const BEGIN: &'static[char] = &['「', '（'];
    const END: &'static[char] = &['」', '）'];
    if let (Some(begin_pos), Some(end_pos)) = (text.find(BEGIN), text.find(END)) {
        let end_pos = end_pos + 3; //+3 to go at the symbol of dialogue end
        if end_pos == text.len() { return; }

        println!(">>>Action:");
        if set_clipboard(&text[begin_pos..end_pos].replace("\n", "")).is_err() {
            println!("Hmph... failed to update clipboard");
        }
        else {
            println!("Dialogue is extracted");
        }
    }
}

fn main() {
    println!("####################################");
    println!("#        VN text corrector         #");
    println!("####################################");
    manager::ClipboardManager::new().delay(10)
                                    .ok_callback(handler_clip_text)
                                    .run();
}
