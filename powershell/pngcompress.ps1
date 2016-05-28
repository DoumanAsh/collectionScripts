Set-Location $PSScriptRoot

function pngcrush() {
    param([String]$png)
    .\pngcrush.exe -ow -s $png
}

foreach ($arg in $args) {
    if ( Test-Path "$arg" -PathType Leaf ) {
        if ($arg.split('.')[1] -eq "png") {
            echo "Compress file: $arg"
            pngcrush($arg)
        }
        else {
            echo "Not an PNG file: $arg"
        }
    }
    elseif ( Test-Path "$arg" -PathType Container ) {
        echo ">>>Compress PNGs in directory: $arg"
        Get-ChildItem $arg | Where-Object {$_.Extension -match "png"} | foreach {
            $png = $_.FullName
            echo "Compress file: $png"
            pngcrush($png)
        }
    }
    else {
        echo ">>>$arg No such file or directory"
    }
    echo ""
}

Read-Host ">>Press any key to exit..."

exit
