if (Get-Command "ninja" -ErrorAction SilentlyContinue) {
    $generator = "Ninja"
}
else {
    $generator = "NMake Makefiles"
}

function cmake_gen() {
    cmake -G $generator $args
}

function cmake_build() {
    cmake --build $args
}
