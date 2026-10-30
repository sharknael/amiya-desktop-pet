param([string]$Assets = (Join-Path $PSScriptRoot 'assets'))
$ErrorActionPreference = 'Stop'
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (!(Test-Path -LiteralPath $compiler)) { throw '需要 64 位 Windows 和 .NET Framework 4.x 编译器。' }
foreach ($name in @('frames.zip','music.wav')) { if (!(Test-Path -LiteralPath (Join-Path $Assets $name))) { throw "素材缺失：$name。请将发布素材包解压到 assets，或运行 tools/Prepare-Assets.ps1。" } }
$dist = Join-Path $PSScriptRoot 'dist'
New-Item -ItemType Directory -Force $dist | Out-Null
$exe = Join-Path $dist 'AmiyaPet-Blue.exe'
& $compiler /nologo /target:winexe /platform:x64 "/out:$exe" /r:System.Drawing.dll /r:System.Windows.Forms.dll /r:System.IO.Compression.dll "/resource:$(Join-Path $Assets 'frames.zip'),frames" "/resource:$(Join-Path $Assets 'music.wav'),music" (Join-Path $PSScriptRoot 'src/Pet.cs') (Join-Path $PSScriptRoot 'src/Theme.cs')
if ($LASTEXITCODE -ne 0) { throw '编译失败。' }
Write-Host "完成：$exe"
