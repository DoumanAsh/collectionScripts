//! VN text corrector

extern crate clipboard_win;
use clipboard_win::{set_clipboard, ClipboardManager};
pub mod utils;

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
    else if let Some(first_sen_end) = text.rfind('。') {
        if (first_sen_end+3) != text.len() { return; }

        let mut sen_end = first_sen_end;
        let mut sen_start: usize = text[..sen_end].rfind('。').unwrap_or(0);

        if sen_start == 0 { return; }

        while let Some(next_sen_start) = text[..sen_start].rfind('。') {
            if text[sen_start..sen_end] != text[next_sen_start..sen_start] {
                sen_end = sen_start;
                break;
            }
            sen_end = sen_start;
            sen_start = next_sen_start;
        }

        if text[..sen_start+3].ends_with(&text[sen_start+3..sen_end+3]) {
            sen_end = sen_start;
        }
        else if first_sen_end == sen_end { return; }

        let text = utils::remove_text_reps(&text[..sen_end+3]);
        println!(">>>Action:");
        if set_clipboard(&text).is_err() {
            println!("Hmph... failed to update clipboard");
        }
        else {
            println!("Text is trimmed of repetitions");
        }
    }
}

fn main() {
    println!("####################################");
    println!("#    Alpha Ride text corrector     #");
    println!("####################################");
    ClipboardManager::new().delay(10).ok_callback(handler_clip_text).run();
}
