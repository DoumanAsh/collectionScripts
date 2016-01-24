//! Evolimit VN text corrector.

extern crate clipboard_win;
use clipboard_win::{set_clipboard};
pub mod utils;
pub mod manager;

fn handler_clip_text(text: &String) {
    let mut update = false;
    let mut text = text.clone();
    if !utils::is_jp(&text) { return; }

    const DOT: &'static str = "・";
    if let Some(_) = text.find(DOT) {
        update = true;
        text = text.replace(DOT, "");
    }

    if update {
        println!(">>>Action:");
        if set_clipboard(&text).is_err() {
            println!("Hmph... failed to update clipboard");
        }
        else {
            println!("Text is cleaned");
        }
    }
}

fn main() {
    println!("####################################");
    println!("#     Evolimit text corrector      #");
    println!("####################################");
    manager::ClipboardManager::new().delay(10).ok_callback(handler_clip_text).run();
}
