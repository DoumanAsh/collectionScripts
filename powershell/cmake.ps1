if (Get-Command "ninja" -ErrorAction SilentlyContinue) {
    $generator = "Ninja"
}
else {
    $generator = "NMake Makefiles"
}

if (Get-Command "vcpkg" -ErrorAction SilentlyContinue) {
    $vcpkg_dir = split-path -parent (Get-Command "vcpkg" | Select-Object -ExpandProperty Definition)

    function cmake_vcpkg() {
        cmake -G $generator -DCMAKE_TOOLCHAIN_FILE="$vcpkg_dir\scripts\buildsystems\vcpkg.cmake" $args
    }
}

function cmake_gen() {
    cmake -G $generator $args
}

function cmake_build() {
    cmake --build $args
}
