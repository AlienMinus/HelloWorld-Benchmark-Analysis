$results = @()

function RunWithTime($name, $command, $dependency) {
    if ($dependency -ne $null -and -not (Get-Command $dependency -ErrorAction SilentlyContinue)) {
        Write-Host "Skipping $name: '$dependency' not found." -ForegroundColor Yellow
        return
    }

    # For compiled executables, check if file exists
    if ($command -match "^\.\\" -and -not (Test-Path ($command -split ' ')[0])) {
        Write-Host "Skipping $name: Executable not found." -ForegroundColor Yellow
        return
    }

    Write-Host "`nRunning $name..."

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Start-Process powershell -ArgumentList "-Command $command" -Wait -NoNewWindow
    $sw.Stop()

    $time = $sw.ElapsedMilliseconds

    Write-Host "$name Execution Time: $time ms"

    $script:results += [PSCustomObject]@{
        Language = $name
        Time_ms  = $time
    }
}

# ---- Compile Programs ----
if (Get-Command "gcc" -ErrorAction SilentlyContinue) { gcc helloworld.c -o helloworld_c.exe } else { Write-Host "Skipping C compilation: gcc not found." -ForegroundColor Yellow }
if (Get-Command "g++" -ErrorAction SilentlyContinue) { g++ helloworld.cpp -o helloworld_cpp.exe } else { Write-Host "Skipping C++ compilation: g++ not found." -ForegroundColor Yellow }
if (Get-Command "javac" -ErrorAction SilentlyContinue) { javac hello_java\helloworld.java } else { Write-Host "Skipping Java compilation: javac not found." -ForegroundColor Yellow }

# ---- Benchmark ----
RunWithTime "Go" "go run hello_go\helloworld.go" "go"
RunWithTime "Java" "java -cp hello_java helloworld" "java"
RunWithTime "C" ".\helloworld_c.exe" $null
RunWithTime "C++" ".\helloworld_cpp.exe" $null
RunWithTime "Python" "python helloworld.py" "python"
RunWithTime "Ruby" "ruby helloworld.rb" "ruby"
RunWithTime "JavaScript" "node helloworld.js" "node"
RunWithTime "PHP" "php helloworld.php" "php"
RunWithTime "Perl" "perl helloworld.pl" "perl"
RunWithTime "Shell" "bash helloworld.sh" "bash"

# ---- CSV Update Logic ----
$csvPath = "multi_run_execution_times.csv"

if (!(Test-Path $csvPath)) {
    # First run → create CSV
    $results | Select-Object Language, @{Name="Run1";Expression={$_.Time_ms}} |
        Export-Csv $csvPath -NoTypeInformation
    Write-Host "`nCreated CSV with Run1"
}
else {
    # Load existing CSV
    $existing = Import-Csv $csvPath

    # Find next Run column number
    $runIndex = ($existing[0].PSObject.Properties | Where-Object {$_.Name -match "^Run"}).Count + 1
    $newRunColumn = "Run$runIndex"

    # Convert new results into lookup
    $lookup = @{}
    foreach ($r in $results) {
        $lookup[$r.Language] = $r.Time_ms
    }

    # Add new column to existing rows
    foreach ($row in $existing) {
        if ($lookup.ContainsKey($row.Language)) {
            $row | Add-Member -NotePropertyName $newRunColumn -NotePropertyValue $lookup[$row.Language]
        }
        else {
            $row | Add-Member -NotePropertyName $newRunColumn -NotePropertyValue ""
        }
    }

    # Save updated CSV
    $existing | Export-Csv $csvPath -NoTypeInformation
    Write-Host "`nAdded new timing column: $newRunColumn"
}
