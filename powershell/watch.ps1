param(
    [string]$program = $(throw "Please specify a program" ),
    [string]$argumentString = ""
)

while ($true) {
    try {
        $psi = new-object "Diagnostics.ProcessStartInfo"
        $psi.ErrorDialog = $true
        $psi.FileName = $program
        $psi.Arguments = $argumentString
        $proc = [Diagnostics.Process]::Start($psi)
        $proc.WaitForExit();
    } catch {
        echo "Cannot execute $program"
        break
    }
}
