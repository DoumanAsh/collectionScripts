export def --env env_add_path [dest: string] {
    if ($dest | path exists) {
        if ($env._OS == Windows) {
            if ($dest not-in ($env.Path)) {
                $env.Path = ($env.Path | prepend $dest)
            }
        } else {
            if ($dest not-in ($env.PATH)) {
                $env.PATH = ($env.PATH | prepend $dest)
            }
        }
    }
}
