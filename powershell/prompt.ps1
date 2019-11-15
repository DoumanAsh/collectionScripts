# Simple ps prompt with git status
function prompt {
    $git_out = $(git branch 2> $null)
    if ([string]::IsNullOrEmpty($git_out)) {
        "$ESC[33m$($executionContext.SessionState.Path.CurrentLocation)$ESC[0m$("`n$(Get-Date -Format 'HH:mm') $" * ($nestedPromptLevel + 1)) "
    } else {
        $git_out = "$git_out" | Select-String -Pattern "\* (.+)" | % { $_.matches.groups[1].value }
        git diff --no-ext-diff --quiet --exit-code

        if ($?) {
            $status_color = "$ESC[32m"
        } else {
            $status_color = "$ESC[31m"
        }

        "$ESC[33m$($executionContext.SessionState.Path.CurrentLocation)$ESC[0m [$status_color$git_out$ESC[0m]$("`n$(Get-Date -Format 'HH:mm') $" * ($nestedPromptLevel + 1)) "
    }
}
