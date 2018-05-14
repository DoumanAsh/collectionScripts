# Allows to set environment variables for compiler
function set_cc()
{
    $name = $args[0]
    $name_path = Get-Command $name -ea SilentlyContinue

    if ($name_path -eq $Null) {
        throw "Unknown compiler name '$name'. Be sure to add it to PATH"
    }

    $env:CC = $name_path.Definition

    switch ($name) {
        "gcc" {
            $env:CXX = $(Get-Command g++).Definition
        }
        "clang" {
            $env:CXX = $(Get-Command clang++).Definition
        }
        "clang-cl" {
            $env:CXX = $name_path.Definition
        }
        "cl" {
            $env:CXX = $name_path.Definition
        }
        "arm-none-eabi-gcc" {
            $env:CXX = $(Get-Command arm-none-eabi-g++).Definition
            $env:AR = $(Get-Command arm-none-eabi-ar).Definition
        }
        default {
            echo "Unknown compiler: $name"
        }
    }

}

function unset_cc() {
    Remove-Item Env:\AR -ea SilentlyContinue
    Remove-Item Env:\CC -ea SilentlyContinue
    Remove-Item Env:\CXX -ea SilentlyContinue
}
