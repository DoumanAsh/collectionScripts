def --env sourcebat [cmd: string] {
    let cmd = $"($cmd) && set 2>&1"
    let result = ( do { cmd.exe /Q /C $"($cmd)" } | complete)

    if ($result.exit_code != 0) {
        error make {
            msg: $result.stderr
        }
    }

    $result.stdout | lines | filter { |in| not ($in | str starts-with '*') }
                   | str trim | filter { not ($in | is-empty) } | split column '=' | update column2 { str trim -c '"' }
                   | filter { $in.column1 != 'PWD' and $in.column1 != 'CURRENT_FILE' and $in.column1 != 'FILE_PWD' }
                   | transpose -r -d | load-env
}

export def --env set_vc_env_from_bat [arch: string] {
    let suffix = "Microsoft Visual Studio/Installer/vswhere.exe"
    let vswhere64 = $"($env.SystemDrive)/Program Files/($suffix)"
    let vswhere86 = $"($env.SystemDrive)/Program Files \(x86\)/($suffix)"

    let vswhere = (
        if ($vswhere64 | path exists) {
            $vswhere64
        } else if ($vswhere86 | path exists) {
            $vswhere86
        } else {
            ""
        }
    )

    if ( $vswhere | is-empty) {
        echo ">MSVC environment not installed"
    } else {
        echo $"Found vswhere: ($vswhere)"
        let vs_studio = cmd.exe /Q /C $"($vswhere)" "-products" "*" "-latest" "-property" installationpath

        echo $"Found VS installation: ($vs_studio)"
        # nushell is kinda dumb with how it passes arguments so we have no choice but to avoid white spaces
        cd $'($vs_studio)\Common7\Tools\'
        let bat = $"VsDevCmd.bat -arch=($arch) -host_arch=($arch)"
        echo $">Load MSVC environment ($arch)..."
        sourcebat $"($bat)"
        cd -
    }
}
