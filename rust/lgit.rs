///Lazy git tool
use std::env;
use std::process::Command;

///Executes git command with arguments
macro_rules! exec_git_cmd {
    ($args:expr) => {
        Command::new("git").args($args).status().unwrap();
    }
}

///Amend changes
fn git_amend(args: &[String]) {
    git_add();
    if (args.len() != 0) && (args[0] == "edit") {
        exec_git_cmd!(&["commit", "--amend"]);
    }
    else {
        exec_git_cmd!(&["commit", "--amend", "--no-edit"]);
    }
}

///Fetch changes from upstream
fn git_fetch() {
    exec_git_cmd!(&["checkout", "master"]);
    exec_git_cmd!(&["fetch", "upstream"]);
    exec_git_cmd!(&["merge", "upstream/master"]);
}

///Push the current branch
fn git_push() {
    exec_git_cmd!(&["push", "origin", "HEAD"]);
}

///Add all changes
fn git_add() {
    exec_git_cmd!(&["add", "--all"]);
}

///Unexpected argument handler
fn unexpected(arg: &str) {
    println!("Unexpected argument: {}", arg);
}

fn main() {
    let args: Vec<String> = env::args().collect();
    //exclude file name
    let s_args = &args[1..];
    let is_repo = Command::new("git").arg("rev-parse").arg("-q").output().unwrap();

    if is_repo.status.code().unwrap() != 0 {
        println!("Not a git repository");
        return;
    }
    else if s_args.len() == 0 {
        println!("lgit [option]\n");
        println!("options:");
        println!("  amend [edit] - amend all changes into last commit");
        println!("  add - add all changes");
        println!("  push - push current branch");
        println!("  fetch - get updates from upstream\n");
        return;
    }

    match s_args[0].as_ref() {
        "amend" => git_amend(&args[2..]),
        "fetch" => git_fetch(),
        "push"  => git_push(),
        "add"   => git_add(),
        _       => unexpected(s_args[0].as_ref()),
    }
}
