export def git_prompt [] {
    # Perform tilde substitution on dir
    # To determine if the prefix of the path matches the home dir, we split the current path into
    # segments, and compare those with the segments of the home dir. In cases where the current dir
    # is a parent of the home dir (e.g. `/home`, homedir is `/home/user`), this comparison will
    # also evaluate to true. Inside the condition, we attempt to str replace `$nu.home-dir` with `~`.
    # Inside the condition, either:
    # 1. The home prefix will be replaced
    # 2. The current dir is a parent of the home dir, so it will be uneffected by the str replace
    let dir = (
        if ($env.PWD | path split | zip ($nu.home-dir | path split) | all { $in.0 == $in.1 }) {
            ($env.PWD | str replace $nu.home-dir "~")
        } else {
            $env.PWD
        }
    )

    # Prepare git prompt
    mut git_prompt = "";
    let git_porcelain = (
        do { git status --porcelain=v2 --branch -unormal --ahead-behind --renames } | complete | $in.stdout | str trim
        | lines | each { $in | split column ' '  --number 4} | flatten | rename idx name param1 param2
    )

    if (($git_porcelain | length) != 0) {
        let git_color = (
            if ($git_porcelain | any {($in | get idx) != "#"}) {
                ansi red
            } else {
                ansi green
            }
        )

        mut git_branch = ($git_porcelain | get 1 | get param1 | str trim)
        mut git_diff = ""

        if ($git_branch == "(detached)") {
            $git_branch = $git_porcelain | get 0 | get param1 | str trim | str substring 0..7
        } else if (($git_porcelain | length) > 3) {
            let commits_ab = $git_porcelain | get 3 --optional
            if (($commits_ab != null) and ($commits_ab | get name) == "branch.ab") {
                let commits_ahead = $commits_ab | get param1 | str trim -c '+' -l | into int
                let commits_behind = $commits_ab | get param2 | str trim -c '-' -l | into int
                $git_diff = (
                    if ($commits_ahead != 0 and $commits_behind != 0) {
                        $" ^ ($commits_ahead) -($commits_behind)"
                    } else if ($commits_ahead != 0) {
                        $" ^ ($commits_ahead)"
                    } else if ($commits_behind != 0) {
                        $" -($commits_behind)"
                    } else {
                        ""
                    }
                )
            }
        }

        $git_prompt = $" [($git_color)($git_branch)($git_diff)(ansi reset)]"
    }

    $"(ansi yellow)($dir)(ansi reset)($git_prompt)\n(date now | format date '%H:%M') "
}
