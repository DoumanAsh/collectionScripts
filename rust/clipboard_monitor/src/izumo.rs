//! Izumo 4 text corrector

extern crate clipboard_win;
use clipboard_win::{set_clipboard};
use utils;

pub fn handler_clip_text(text: &String) {
    const BEG: char = '{';
    const END: char = '}';
    const SEP: char = '/';
    const DOT: &'static str = "・";

    if !utils::is_jp(text) { return; }
    else if text.find(BEG) == None { return; }

    let orig_len = text.len();
    let mut after_text = String::with_capacity(text.len());
    let mut text = &text[..];

    while let Some(beg_pos) = text.find(BEG) {
        after_text.push_str(&text[..beg_pos]);
        text = &text[beg_pos+1..];

        let sep_pos = text.find(SEP).unwrap_or(0);
        let end_pos = text.find(END).unwrap_or(0);

        if sep_pos == 0 {
            after_text.push(BEG);
            after_text.push_str(&text[..end_pos]);
            continue;
        }
        else if end_pos == 0 {
            after_text.push(BEG);
            break;
        }

        if let Some(_) = text[sep_pos..end_pos].find(DOT) {
            after_text.push_str(&text[..sep_pos]);
        }
        else {
            after_text.push(BEG);
            after_text.push_str(&text[..end_pos+1]);
        }
        text = &text[end_pos+1..];
    }

    after_text.push_str(text);
    if orig_len > after_text.len() {
        println!(">>>Action:");
        if set_clipboard(&after_text).is_err() {
            println!("Hmph... failed to update clipboard");
        }
        else {
            println!("Text is corrected.");
        }
    }
}
