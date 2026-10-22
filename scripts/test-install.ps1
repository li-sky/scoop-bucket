param([Parameter(Mandatory)][string]$Version)
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
New-Item -ItemType Directory -Force .test | Out-Null
Invoke-WebRequest https://raw.githubusercontent.com/ScoopInstaller/Scoop/master/schema.json -OutFile .test/schema.json
python -m pip install --quiet jsonschema
if ($LASTEXITCODE) { throw 'Cannot install schema validator' }
python -c "import json,jsonschema; jsonschema.validate(json.load(open('bucket/kbshare.json')),json.load(open('.test/schema.json')))"
if ($LASTEXITCODE) { throw 'Manifest schema validation failed' }

# Exercise Scoop itself on an isolated runner, using a local copy of the archive.
$env:SCOOP = Join-Path $env:RUNNER_TEMP 'scoop'
$scoopRoot = Join-Path $env:SCOOP 'apps/scoop/current'
git clone --depth 1 https://github.com/ScoopInstaller/Scoop.git $scoopRoot
if ($LASTEXITCODE) { throw 'Cannot fetch Scoop' }
New-Item -ItemType Directory -Force "$env:SCOOP/shims", "$env:SCOOP/buckets" | Out-Null
$scoop = Join-Path $scoopRoot 'bin/scoop.ps1'
& $scoop config aria2-enabled false
$archive = "dist/kbshare-$Version-windows-x64.zip"
python scripts/manifest.py --version $Version --archive $archive --url "http://127.0.0.1:18765/kbshare-$Version-windows-x64.zip" --output .test/kbshare.json
if ($LASTEXITCODE) { throw 'Cannot generate local test manifest' }
$server = Start-Process python -ArgumentList '-m', 'http.server', '18765', '--bind', '127.0.0.1' -WorkingDirectory "$root/dist" -PassThru -RedirectStandardOutput "$root/.test/http.log" -RedirectStandardError "$root/.test/http-error.log"
try {
    $ready = $false
    for ($attempt = 0; $attempt -lt 20; $attempt++) {
        try {
            Invoke-WebRequest http://127.0.0.1:18765/ -UseBasicParsing | Out-Null
            $ready = $true
            break
        } catch { Start-Sleep -Milliseconds 500 }
    }
    if (!$ready) { throw 'Local package server failed to start' }
    & $scoop install --no-update-scoop "$root/.test/kbshare.json"
    $installed = Join-Path $env:SCOOP 'apps/kbshare/current'
    foreach ($name in 'kbshare.exe', 'kbshare-config.exe', 'kbshare.cmd', 'kbshare-config.cmd', 'data/config.json') {
        if (!(Test-Path "$installed/$name")) { throw "Missing installed file: $name" }
    }
    foreach ($name in 'kbshare', 'kbshare-config') {
        if (!(Test-Path "$env:SCOOP/shims/$name.cmd")) { throw "Missing command shim: $name" }
    }
    $help = Start-Process "$installed/kbshare.exe" -ArgumentList '--help' -PassThru -Wait
    if ($help.ExitCode -ne 0) { throw 'kbshare executable smoke test failed' }
    $shell = New-Object -ComObject WScript.Shell
    $menu = Join-Path ([Environment]::GetFolderPath('StartMenu')) 'Programs/Scoop Apps'
    foreach ($name in 'kbshare', 'kbshare Configuration') {
        $shortcut = "$menu/$name.lnk"
        if (!(Test-Path $shortcut)) { throw "Missing shortcut: $name" }
        $link = $shell.CreateShortcut($shortcut)
        if (!(Test-Path $link.TargetPath)) { throw "Broken shortcut target: $name" }
        if ($link.Arguments -notlike '*data\config.json*') { throw "Shortcut missing persistent config: $name" }
    }
    $persist = Join-Path $env:SCOOP 'persist/kbshare/data'
    '{"local_id":"scoop-test","remote_id":"peer"}' | Set-Content "$installed/data/config.json" -Encoding ascii
    New-Item -ItemType Directory -Force "$installed/data/certs" | Out-Null
    'persistence-test' | Set-Content "$installed/data/certs/marker.txt"
    if (!(Test-Path "$persist/certs/marker.txt")) { throw 'Data is not persisted' }
    $configHash = (Get-FileHash "$persist/config.json").Hash
    & $scoop uninstall kbshare
    if (Test-Path $installed) { throw 'Scoop uninstall failed' }
    if (!(Test-Path "$persist/certs/marker.txt")) { throw 'Uninstall lost persistent data' }
    & $scoop install --no-update-scoop "$root/.test/kbshare.json"
    if ((Get-FileHash "$installed/data/config.json").Hash -ne $configHash) { throw 'Reinstall overwrote user config' }
    if (!(Test-Path "$installed/data/certs/marker.txt")) { throw 'Reinstall lost certificate directory' }
    Write-Host 'PASS: schema, Scoop install, executable, shims, shortcuts and persistence across reinstall.'
} finally {
    Stop-Process -Id $server.Id -ErrorAction SilentlyContinue
}
