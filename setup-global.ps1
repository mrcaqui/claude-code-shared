<#
.SYNOPSIS
    Claude Code のグローバル設定（skills, CLAUDE.md）をこのリポジトリへリンクするセットアップスクリプト。

.DESCRIPTION
    %USERPROFILE%\.claude 配下の skills フォルダと CLAUDE.md を、このリポジトリの
    global/ 配下へ Junction / SymbolicLink で接続します。
    PCにつき初回1回だけ実行してください。

    - skills フォルダ → Junction（ディレクトリ用）
    - CLAUDE.md        → SymbolicLink（ファイル用）

.NOTES
    Windows の SymbolicLink 作成には「開発者モード」の有効化、
    または管理者権限での実行が必要です。
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── パス解決 ──────────────────────────────────────────────
$repoRoot   = $PSScriptRoot
$claudeHome = Join-Path $env:USERPROFILE ".claude"

$links = @(
    @{
        LinkPath   = Join-Path $claudeHome "skills"
        TargetPath = Join-Path $repoRoot "global" "skills"
        Type       = "Junction"
        Label      = "skills フォルダ"
    },
    @{
        LinkPath   = Join-Path $claudeHome "CLAUDE.md"
        TargetPath = Join-Path $repoRoot "global" "CLAUDE.md"
        Type       = "SymbolicLink"
        Label      = "CLAUDE.md"
    }
)

# ── ヘルパー関数 ──────────────────────────────────────────
function Write-Step  { param([string]$Msg) Write-Host "[*] $Msg" -ForegroundColor Cyan }
function Write-Ok    { param([string]$Msg) Write-Host "[+] $Msg" -ForegroundColor Green }
function Write-Warn  { param([string]$Msg) Write-Host "[!] $Msg" -ForegroundColor Yellow }
function Write-Err   { param([string]$Msg) Write-Host "[-] $Msg" -ForegroundColor Red }

function Test-ReparsePoint {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $false }
    $item = Get-Item $Path -Force
    return ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
}

# ── メイン処理 ────────────────────────────────────────────
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Claude Code グローバル設定セットアップ" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Step "リポジトリルート : $repoRoot"
Write-Step "Claude Home      : $claudeHome"
Write-Host ""

# .claude フォルダが存在しなければ作成
if (-not (Test-Path $claudeHome)) {
    Write-Step "$claudeHome を作成します..."
    New-Item -ItemType Directory -Path $claudeHome -Force | Out-Null
    Write-Ok "$claudeHome を作成しました。"
}

$hasError = $false

foreach ($link in $links) {
    $linkPath   = $link.LinkPath
    $targetPath = $link.TargetPath
    $linkType   = $link.Type
    $label      = $link.Label

    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Step "$label のセットアップ"
    Write-Step "  リンク元 : $linkPath"
    Write-Step "  リンク先 : $targetPath"

    # リンク先（リポジトリ側）の存在確認
    if (-not (Test-Path $targetPath)) {
        Write-Err "リンク先が見つかりません: $targetPath"
        $hasError = $true
        continue
    }

    # 既にリンクが張られている場合
    if (Test-ReparsePoint $linkPath) {
        $existing = Get-Item $linkPath -Force
        $existingTarget = $existing.Target
        if ($existingTarget -eq $targetPath) {
            Write-Ok "$label は既に正しいリンクが設定されています。スキップします。"
            continue
        } else {
            Write-Warn "$label は別のリンク先を指しています: $existingTarget"
            Write-Warn "既存リンクを削除して再作成します..."
            # Junction/Symlinkの削除（中身は消えない）
            if ($linkType -eq "Junction") {
                cmd /c rmdir "$linkPath" 2>$null
            } else {
                Remove-Item $linkPath -Force
            }
        }
    }

    # 既存のファイル/フォルダがある場合はバックアップ
    if (Test-Path $linkPath) {
        $bakPath = "$linkPath.bak"
        $counter = 1
        while (Test-Path $bakPath) {
            $bakPath = "$linkPath.bak.$counter"
            $counter++
        }
        Write-Warn "既存の $label をバックアップします: $bakPath"
        Move-Item -Path $linkPath -Destination $bakPath -Force
        Write-Ok "バックアップ完了: $bakPath"
    }

    # リンク作成
    try {
        Write-Step "$linkType を作成しています..."
        New-Item -ItemType $linkType -Path $linkPath -Target $targetPath -Force | Out-Null
        Write-Ok "$label の $linkType を作成しました。"
    }
    catch {
        Write-Err "$label の作成に失敗しました: $_"
        Write-Err "SymbolicLink の場合は開発者モードの有効化、または管理者権限での実行が必要です。"
        $hasError = $true
    }
}

# ── 完了メッセージ ────────────────────────────────────────
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($hasError) {
    Write-Warn "セットアップは一部エラーがありました。上記のメッセージを確認してください。"
} else {
    Write-Ok "グローバル設定のセットアップが完了しました！"
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
