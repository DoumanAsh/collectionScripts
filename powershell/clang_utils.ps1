function clang-format-all() {
    Get-ChildItem -Path . -Include *.hpp,*.h,*.c,*.cpp -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object {
        $name = $_.FullName
        clang-format -i $name
    }
}
