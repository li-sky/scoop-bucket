param([Parameter(Mandatory)][string]$Version, [Parameter(Mandatory)][string]$SourceSha)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force package/data, dist | Out-Null
Copy-Item upstream/target/x86_64-pc-windows-msvc/release/kbshare.exe package/
Copy-Item upstream/target/x86_64-pc-windows-msvc/release/kbshare-config.exe package/
'{}' | Set-Content package/data/config.json -Encoding ascii
@'
@echo off
if "%~1"=="" (
    start "" "%~dp0kbshare.exe" --config "%~dp0data\config.json"
) else (
    start "" "%~dp0kbshare.exe" %*
)
'@ | Set-Content package/kbshare.cmd -Encoding ascii
@'
@echo off
if "%~1"=="" (
    start "" "%~dp0kbshare-config.exe" "%~dp0data\config.json" kbshare
) else (
    start "" "%~dp0kbshare-config.exe" %*
)
'@ | Set-Content package/kbshare-config.cmd -Encoding ascii
Copy-Item upstream/README.md package/UPSTREAM-README.md
@{
    repository = 'https://github.com/li-sky/ununifying_kboard_share'
    commit = $SourceSha
    version = $Version
    target = 'x86_64-pc-windows-msvc'
} | ConvertTo-Json | Set-Content package/source.json -Encoding utf8
$archive = "dist/kbshare-$Version-windows-x64.zip"
Compress-Archive -Path package/* -DestinationPath $archive
$hash = (Get-FileHash $archive -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  $(Split-Path $archive -Leaf)" | Set-Content "$archive.sha256" -Encoding ascii
python scripts/manifest.py --version $Version --archive $archive
if ($LASTEXITCODE) { throw 'Manifest generation failed' }
