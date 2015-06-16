extern crate hyper;
#[macro_use(trace, is_file)]
extern crate rusty_cute_macros;
extern crate regex;

use std::io::{Read, Write};
use std::borrow::Borrow;

macro_rules! input {
    ($msg:expr) => {{
        use std::io::{Read, Write};
        print!($msg);
        std::io::stdout().flush().unwrap();
        std::io::stdin().bytes().next();
    }}
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

    let mut http_client = hyper::client::Client::new();
    let mut tux_data: String = String::with_capacity(6200);
    let mut result = http_client.get("https://tuxproject.de/projects/vim").send().unwrap();

    if result.status != hyper::Ok {
        trace!("Failed to connect to tuxproject.de with result={}", result.status);
        return;
    }

    if result.read_to_string(&mut tux_data).unwrap_or(0) == 0 { trace!("Failed to retrieve data"); return; }
    let re_get_date = regex::Regex::new(r"(?m)\d{4}-\d{2}-\d{2}").unwrap();
    let vim_cur_date: (usize, usize, usize);

    if let Some(cap_date) = re_get_date.captures_iter(&tux_data).next() {
        vim_cur_date = get_date(cap_date.at(0).unwrap());
    }
    else { trace!("Failed to find build's date"); return; }

    drop(tux_data);
    drop(result);
    drop(re_get_date);
    //Get config file
    let mut config_file = match is_file!("vim_updater.cfg") {
        true => std::fs::File::open("vim_updater.cfg").unwrap(),
        false => std::fs::File::create("vim_updater.cfg").unwrap(),
    };
    let mut build_date: String = String::with_capacity(10);
    let to_update: bool;

    if config_file.read_to_string(&mut build_date).unwrap_or(0) == 0 { to_update = true; }
    else {
        let vim_old_date = get_date(build_date.borrow());
        to_update = vim_cur_date > vim_old_date;
    }

    if !to_update {
        println!("Vim is up-to-date");
        input!("Press Enter to exit...");
        return;
    }
    drop(build_date);
    drop(config_file);

    println!("Found new vim build:");
    println!("Date: {}-{}-{}", vim_cur_date.0, vim_cur_date.1, vim_cur_date.2);

    //Update config file
    if let Ok(mut file) = std::fs::File::create("vim_updater.cfg") {
        if file.write_fmt(format_args!("{}-{}-{}", vim_cur_date.0, vim_cur_date.1, vim_cur_date.2)).is_err() {
            trace!("Failed to write new data into config file");
            return;
        }
    }
    else { trace!("Unable to update config file"); return; }

    drop(vim_cur_date);
    //download new builds
    let mut download_res = http_client.get("https://tuxproject.de/projects/vim/complete-x64.7z").send().unwrap();
    if download_res.status != hyper::Ok { trace!("Failed to download vim build. Response status={}", download_res.status); return; }

    if let Ok(mut file) = std::fs::File::create("vim-x64.7z") {
        if std::io::copy(&mut download_res, &mut file).is_err() { trace!("Unable to save file"); return; }
    }
    else { trace!("Unable to create file"); return; }

    println!("Succesfully downloaded vim-x64.7z");
    let mut download_res = http_client.get("https://tuxproject.de/projects/vim/complete-x86.7z").send().unwrap();
    if download_res.status != hyper::Ok { trace!("Failed to download vim build. Response status={}", download_res.status); return; }

    if let Ok(mut file) = std::fs::File::create("vim-x86.7z") {
        if std::io::copy(&mut download_res, &mut file).is_err() { trace!("Unable to save file"); return; }
    }
    else { trace!("Unable to create file"); return; }
    println!("Succesfully downloaded vim-x86.7z");

    input!("Press Enter to exit...");
}
