extern crate hyper;
#[macro_use(trace, is_file, drop)]
extern crate rusty_cute_macros;
extern crate regex;

use std::io::{Read, Write, Seek};
use std::borrow::Borrow;

/// RETURN macro.
///
/// @msg_type - macro identfier which will be called to print
macro_rules! RETURN {
    (msg_type=>$msg_type:ident, $($arg:tt)+) => {{
        $msg_type!($($arg)+);
        print!("Press Enter to exit...");
        std::io::stdout().flush().unwrap();
        std::io::stdin().bytes().next();
        return;
    }};
    ($($arg:tt)+) => {{ RETURN!(msg_type=>println, $($arg)+); }};
}

/// Extract tuple from date's string in format [yyyy-mm-dd]
fn get_date(str_date: &str) -> (usize, usize, usize) {
    let mut result: (usize, usize, usize) = (0, 0, 0);
    let mut date_split = str_date.split("-");

    result.0 = date_split.next().unwrap().parse::<usize>().unwrap_or(0);
    result.1 = date_split.next().unwrap().parse::<usize>().unwrap_or(0);
    result.2 = date_split.next().unwrap().parse::<usize>().unwrap_or(0);
    result
}

fn main() {
    println!("###################################################");
    println!("#Source: https://tuxproject.de/projects/vim/");
    println!("#Visit site to give thanks(donate button at bottom)");
    println!("###################################################\n");

    let http_client = hyper::client::Client::new();
    let mut tux_data: String = String::with_capacity(6200);
    let mut result = http_client.get("https://tuxproject.de/projects/vim").send().unwrap();

    if result.status != hyper::Ok {
        RETURN!(msg_type=>trace, "Failed to connect to tuxproject.de with result={}", result.status);
    }

    if result.read_to_string(&mut tux_data).unwrap_or(0) == 0 {
        RETURN!(msg_type=>trace, "Failed to retrieve data");
    }
    let re_get_date = regex::Regex::new(r"(?m)\d{4}-\d{2}-\d{2}").unwrap();
    let vim_cur_date: (usize, usize, usize);

    if let Some(cap_date) = re_get_date.captures_iter(&tux_data).next() {
        vim_cur_date = get_date(cap_date.at(0).unwrap());
    }
    else {
        RETURN!(msg_type=>trace, "Failed to find build's date");
    }

    drop!(tux_data, result, re_get_date);
    //Get config file
    let mut config_file = std::fs::OpenOptions::new().read(true).write(true).create(true).open("vim_updater.cfg").unwrap();
    let mut build_date: String = String::with_capacity(10);
    let to_update: bool;

    if config_file.read_to_string(&mut build_date).unwrap_or(0) == 0 { to_update = true; }
    else {
        let vim_old_date = get_date(build_date.borrow());
        to_update = vim_cur_date > vim_old_date;
    }

    if !to_update {
        RETURN!("Vim is up-to-date");
    }

    println!("Found new vim build:");
    println!("Date: {}-{}-{}", vim_cur_date.0, vim_cur_date.1, vim_cur_date.2);

    //Update config file
    config_file.seek(std::io::SeekFrom::Start(0)).unwrap();
    if config_file.set_len(0).is_err() {
        RETURN!("Failed to trunctuate config file");
    }
    if config_file.write_fmt(format_args!("{}-{}-{}", vim_cur_date.0, vim_cur_date.1, vim_cur_date.2)).is_err() {
        RETURN!(msg_type=>trace, "Failed to write new data into config file");
    }

    drop!(vim_cur_date, config_file, build_date);
    //download new builds
    let client_arc = std::sync::Arc::new(http_client);
    let client_64 = client_arc.clone();
    let client_86 = client_arc.clone();
    let handler64 = std::thread::spawn(move || {
        println!(">>>Download vim-x64.7z");
        let mut download_res = client_64.get("https://tuxproject.de/projects/vim/complete-x64.7z").send().unwrap();
        if download_res.status != hyper::Ok {
            RETURN!(msg_type=>trace, "Failed to download vim build. Response status={}", download_res.status);
        }

        if let Ok(mut file) = std::fs::File::create("vim-x64.7z") {
            if std::io::copy(&mut download_res, &mut file).is_err() {
                RETURN!(msg_type=>trace, "Unable to save file");
            }
        }
        else {
            RETURN!(msg_type=>trace, "Unable to create file");
        }
        println!("Succesfully downloaded vim-x64.7z");
    });

    let handler32 = std::thread::spawn(move || {
        println!(">>>Download vim-x86.7z");
        let mut download_res = client_86.get("https://tuxproject.de/projects/vim/complete-x86.7z").send().unwrap();
        if download_res.status != hyper::Ok {
            RETURN!(msg_type=>trace, "Failed to download vim build. Response status={}", download_res.status);
        }

        if let Ok(mut file) = std::fs::File::create("vim-x86.7z") {
            if std::io::copy(&mut download_res, &mut file).is_err() {
                RETURN!(msg_type=>trace, "Unable to save file");
            }
        }
        else {
            RETURN!(msg_type=>trace, "Unable to create file");
        }

        println!("Succesfully downloaded vim-x86.7z");
    });

    handler64.join().unwrap();
    handler32.join().unwrap();
    RETURN!(">>>Done");
}
