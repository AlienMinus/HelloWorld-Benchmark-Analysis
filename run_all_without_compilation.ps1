function RunWithTime($name, $command, $dependency) {
    if ($null -ne $dependency -and -not (Get-Command $dependency -ErrorAction SilentlyContinue)) {
        Write-Host "Skipping ${name}: '${dependency}' not found." -ForegroundColor Yellow
        return
    }

    Write-Host "`nRunning $name..."
    $start = Get-Date
    Invoke-Expression $command
    $end = Get-Date
    $duration = ($end - $start).TotalMilliseconds
    Write-Host "$name Execution Time: $duration ms"
}

RunWithTime "Go" "go run hello_go\helloworld.go" "go"
RunWithTime "Java" "javac hello_java\helloworld.java; java -cp hello_java helloworld" "javac"
RunWithTime "C" "gcc helloworld.c -o helloworld_c.exe; .\helloworld_c.exe" "gcc"
RunWithTime "C++" "g++ helloworld.cpp -o helloworld_cpp.exe; .\helloworld_cpp.exe" "g++"
RunWithTime "Python" "python helloworld.py" "python"
RunWithTime "Ruby" "ruby helloworld.rb" "ruby"
RunWithTime "JavaScript" "node helloworld.js" "node"
RunWithTime "PHP" "php helloworld.php" "php"
RunWithTime "Perl" "perl helloworld.pl" "perl"
RunWithTime "Shell" "bash helloworld.sh" "bash"
