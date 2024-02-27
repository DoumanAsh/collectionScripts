export def --env env_add_path [dest: string] {
    if ($dest | path exists) {
        if ($dest not-in $env.PATH) {
            $env.PATH = ($env.PATH | prepend $dest)
        }
    }
}
