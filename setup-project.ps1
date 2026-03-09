<#
.SYNOPSIS
    Claude Code のプロジェクト設定をテンプレートから初期化するスクリプト。

.DESCRIPTION
    カレントディレクトリに .claude フォルダを作成し、テンプレートから
    CLAUDE.md と settings.local.json をコピーします。
    プロジェクト固有のカスタマイズが入るため、リンクではなくコピーです。

.PARAMETER Template
    テンプレート名（任意）。指定された場合は project-templates\<template>\ 配下の
    ファイルを使用します。省略時は project-templates\ 直下のファイルを使用します。

.EXAMPLE
    # デフォルトテンプレートを使用
    .\setup-project.ps1

    # web-app テンプレートを使用
    .\setup-project.ps1 -Template web-app
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$Template = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── パス解決 ──────────────────────────────────────────────
$repoRoot = $PSScriptRoot
$projectDir = Get-Location

if ($Template -ne "") {
    $templateDir = Join-Path $repoRoot "project-templates" $Template
} else {
    $templateDir = Join-Path $repoRoot "project-templates"
}

$claudeDir = Join-Path $projectDir ".claude"

# コピー対象ファイル
$filesToCopy = @(
    @{ Src = "CLAUDE.md";           Dst = Join-Path $claudeDir "CLAUDE.md" },
    @{ Src = "settings.local.json"; Dst = Join-Path $claudeDir "settings.local.json" }
)

# ── ヘルパー関数 ──────────────────────────────────────────
function Write-Step  { param([string]$Msg) Write-Host "[*] $Msg" -ForegroundColor Cyan }
function Write-Ok    { param([string]$Msg) Write-Host "[+] $Msg" -ForegroundColor Green }
function Write-Warn  { param([string]$Msg) Write-Host "[!] $Msg" -ForegroundColor Yellow }
function Write-Err   { param([string]$Msg) Write-Host "[-] $Msg" -ForegroundColor Red }

# ── メイン処理 ────────────────────────────────────────────
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Claude Code プロジェクト設定セットアップ" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Step "プロジェクト   : $projectDir"
Write-Step "テンプレート元 : $templateDir"
if ($Template -ne "") {
    Write-Step "テンプレート名 : $Template"
}
Write-Host ""

# テンプレートディレクトリの存在確認
if (-not (Test-Path $templateDir)) {
    Write-Err "テンプレートディレクトリが見つかりません: $templateDir"
    exit 1
}

# .claude フォルダの作成
if (-not (Test-Path $claudeDir)) {
    Write-Step ".claude フォルダを作成します..."
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    Write-Ok ".claude フォルダを作成しました: $claudeDir"
} else {
    Write-Step ".claude フォルダは既に存在します: $claudeDir"
}

$hasError = $false

foreach ($file in $filesToCopy) {
    $srcPath = Join-Path $templateDir $file.Src
    $dstPath = $file.Dst

    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Step "$($file.Src) のセットアップ"

    # ソースファイルの存在確認
    if (-not (Test-Path $srcPath)) {
        Write-Warn "テンプレートにファイルがありません（スキップ）: $srcPath"
        continue
    }

    # コピー先に既にファイルがある場合の上書き確認
    if (Test-Path $dstPath) {
        Write-Warn "コピー先に既にファイルがあります: $dstPath"
        $response = Read-Host "  上書きしますか？ (y/N)"
        if ($response -ne "y" -and $response -ne "Y") {
            Write-Step "スキップしました: $($file.Src)"
            continue
        }
    }

    # コピー実行
    try {
        Copy-Item -Path $srcPath -Destination $dstPath -Force
        Write-Ok "$($file.Src) をコピーしました: $dstPath"
    }
    catch {
        Write-Err "コピーに失敗しました ($($file.Src)): $_"
        $hasError = $true
    }
}

# ── 完了メッセージ ────────────────────────────────────────
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($hasError) {
    Write-Warn "セットアップは一部エラーがありました。上記のメッセージを確認してください。"
} else {
    Write-Ok "プロジェクト設定のセットアップが完了しました！"
    Write-Host ""
    Write-Step "次のステップ:"
    Write-Host "  1. .claude/CLAUDE.md を編集してプロジェクト固有の設定を記載してください"
    Write-Host "  2. .claude/settings.local.json を必要に応じて編集してください"
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
