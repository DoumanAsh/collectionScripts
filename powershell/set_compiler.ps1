# Handles special toolchains
function special_toolchains([string]$name) {
    switch ($name) {
        "android" {
            if (Test-Path env:ANDROID_NDK_HOME) {
                $host_tag = if ([Environment]::Is64BitOperatingSystem) { "windows-x86_64" } else { "windows" }
                $dir = "$env:ANDROID_NDK_HOME\toolchains\llvm\prebuilt\$host_tag\bin"

                if (Test-Path $dir) {
                    $env:PATH = "$env:PATH;$dir"
                    $env:CC = "$dir\clang.exe"
                    $env:CXX = "$dir\clang++.exe"
                } else {
                    echo "Expect to find directory with toolchain in '$dir' but it doesn't exist"
                }

            } else {
                echo "env:ANDROID_NDK_HOME is not set, cannot find android toolchain"
            }
        }
        default {
            throw "Unknown compiler name '$name'. Be sure to add it to PATH"
        }
    }
}

# Allows to set environment variables for compiler
function set_cc()
{
    $name = $args[0]
    $name_path = Get-Command $name -ea SilentlyContinue

    if ($name_path -eq $Null) {
        special_toolchains($name)
        return
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
            throw "Unknown compiler name '$name'. Be sure to add it to PATH"
        }
    }

}

function unset_cc() {
    Remove-Item Env:\AR -ea SilentlyContinue
    Remove-Item Env:\CC -ea SilentlyContinue
    Remove-Item Env:\CXX -ea SilentlyContinue
}
