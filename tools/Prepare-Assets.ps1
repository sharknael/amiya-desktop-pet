param([Parameter(Mandatory=$true)][string]$Video,[Parameter(Mandatory=$true)][string]$FFmpeg)
$ErrorActionPreference = 'Stop'
$Video = (Resolve-Path -LiteralPath $Video).Path
$FFmpeg = (Resolve-Path -LiteralPath $FFmpeg).Path
$root = Split-Path -Parent $PSScriptRoot
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
Push-Location $root
try {
 if (Test-Path -LiteralPath 'work/frames.zip') { throw 'work/frames.zip 已存在。请先备份或移走旧素材。' }
 if ((Test-Path -LiteralPath 'work/frames') -and (Get-ChildItem -LiteralPath 'work/frames' -Filter '*.png')) { throw 'work/frames 内有旧帧。请先备份或移走旧帧。' }
 New-Item -ItemType Directory -Force work/frames,assets | Out-Null
 & $FFmpeg -loglevel error -y -ss 6 -i $Video -t 26.6 -vf 'fps=30' 'work/frames/%04d.png'
 if ($LASTEXITCODE -ne 0) { throw '视频截取失败。' }
 & $FFmpeg -loglevel error -y -ss 6 -i $Video -t 26.6 -vn -acodec pcm_s16le work/music.wav
 if ($LASTEXITCODE -ne 0) { throw '音频截取失败。' }
 & $compiler /nologo /out:work\Prep.exe /r:System.Drawing.dll /r:System.IO.Compression.dll /r:System.IO.Compression.FileSystem.dll tools\Prep.cs
 if ($LASTEXITCODE -ne 0) { throw '素材工具编译失败。' }
 & .\work\Prep.exe
 if ($LASTEXITCODE -ne 0) { throw '透明化处理失败。' }
 Copy-Item work/frames.zip,work/music.wav assets/ -Force
 Write-Host '素材已保存到 assets。请运行 ./build.ps1。'
} finally { Pop-Location }
