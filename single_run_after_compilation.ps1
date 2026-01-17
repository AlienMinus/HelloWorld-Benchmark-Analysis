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


# --- Compile First (One-Time) ---
Write-Host "`nCompiling Programs..."

if (Get-Command "gcc" -ErrorAction SilentlyContinue) { gcc helloworld.c -o helloworld_c.exe } else { Write-Host "Skipping C compilation: gcc not found." -ForegroundColor Yellow }
if (Get-Command "g++" -ErrorAction SilentlyContinue) { g++ helloworld.cpp -o helloworld_cpp.exe } else { Write-Host "Skipping C++ compilation: g++ not found." -ForegroundColor Yellow }
if (Get-Command "javac" -ErrorAction SilentlyContinue) { javac hello_java\helloworld.java } else { Write-Host "Skipping Java compilation: javac not found." -ForegroundColor Yellow }

Write-Host "Compilation Done."

# --- Benchmark Runtime Only ---
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

# --- Export Results to CSV ---
$results | Export-Csv "single_run_execution_times.csv" -NoTypeInformation

Write-Host "`nCSV file saved as single_run_execution_times.csv"