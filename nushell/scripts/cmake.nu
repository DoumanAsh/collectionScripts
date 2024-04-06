export alias cmake_build = cmake --build

export def --wrapped cmake_gen [...args: string] {
    let generator = (
        if (which ninja | is-empty) {
            if ((sys).host.name == "Windows") {
                "NMake Makefiles"
            } else {
                "Unix Makefiles"
            }
        } else  {
            "Ninja"
        }
    )

    let vcpkg = which vcpkg
    let vcpkg_toolchain = (
        if ($vcpkg | is-empty) {
            ""
        } else {
            let vcpkg_manifest = $vcpkg | get path | path dirname | path join scripts buildsystems vcpkg.cmake
            if ($vcpkg_manifest | path exists) {
                $'-DCMAKE_TOOLCHAIN_FILE=($vcpkg_manifest)'
            } else {
                print $"VCPKG installation is missing manifest: ($vcpkg_manifest)"
                ""
            }
        }
    )

    cmake -G $generator $vcpkg_toolchain ...$args
}

export def --env set_cc [arg: string] {
    let arg_which = which $"($arg)"

    if ($arg_which | is-empty) {
        error make {
            msg: $"($arg): No such compiler is found"
        }
    } else {
        $env.CC = ($arg_which | get path | get 0)
        if ($arg == "gcc") {
            $env.CXX = (which g++ | get path | get 0)
        } else if ($arg == "clang") {
            $env.CXX = (which clang++ | get path | get 0)
        } else {
            $env.CXX = $env.CC
        }
    }
}
