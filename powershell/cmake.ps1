function cmake_gen() {
    if (Get-Command "ninja" -ErrorAction SilentlyContinue) {
        $generator = "Ninja"
    } else {
        $generator = "NMake Makefiles"
    }


    if (Get-Command "vcpkg" -ErrorAction SilentlyContinue) {
        $vcpkg_dir = split-path -parent (Get-Command "vcpkg" | Select-Object -ExpandProperty Definition)
        $vcpkg_toolchain_path = Join-Path -Path $vcpkg_dir -ChildPath scripts | Join-Path -ChildPath buildsystems | Join-Path -ChildPath vcpkg.cmake

        if (Test-Path -Path $vcpkg_toolchain_path) {
            $vcpkg_toolchain = '-DCMAKE_TOOLCHAIN_FILE="{0}"' -f $vcpkg_toolchain_path
        } else {
            $vcpkg_toolchain = ''
        }
    } else {
        $vcpkg_toolchain = ''
    }

    echo ">cmake -G $generator $vcpkg_toolchain $args"
    cmake -G $generator $vcpkg_toolchain $args
}

function cmake_build() {
    echo ">cmake --build $args"
    cmake --build $args
}
