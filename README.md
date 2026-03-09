# claude-code-shared

Claude Code の設定ファイル（Skills、CLAUDE.md、settings 等）を複数PC間で共有管理するための Git リポジトリです。

## リポジトリ構成

```
claude-code-shared/
├── README.md                  ← このファイル
├── global/
│   ├── CLAUDE.md              ← グローバル CLAUDE.md
│   └── skills/                ← グローバル Skills フォルダ
├── project-templates/
│   ├── CLAUDE.md              ← プロジェクト用 CLAUDE.md テンプレート
│   └── settings.local.json    ← プロジェクト用設定ファイル
├── setup-global.ps1           ← グローバル設定のセットアップスクリプト
├── setup-project.ps1          ← プロジェクト設定のセットアップスクリプト
└── sync-commands.ps1          ← B案（コピー方式）用スクリプト（将来実装）
```

## 前提条件

- **OS**: Windows 10/11
- **開発者モード有効化** または **管理者権限**: SymbolicLink の作成に必要
  - 設定 → 更新とセキュリティ → 開発者向け → 開発者モード を有効にする
- **Git**: リポジトリの clone・管理用
- **PowerShell**: セットアップスクリプトの実行用

## セットアップ手順

### 1. 新しいPCでの初回セットアップ

```powershell
# 1. リポジトリを clone
git clone <リポジトリURL> C:\Users\<user>\claude-code-shared

# 2. グローバル設定をリンク（PCにつき1回）
cd C:\Users\<user>\claude-code-shared
.\setup-global.ps1

# 3. プロジェクト設定を初期化
cd "C:\Users\<user>\OneDrive - Cisco\デスクトップ\mpj\10-dev\<project>"
& "C:\Users\<user>\claude-code-shared\setup-project.ps1"
```

`setup-global.ps1` は以下のリンクを作成します：
- `%USERPROFILE%\.claude\skills` → リポジトリの `global/skills`（Junction）
- `%USERPROFILE%\.claude\CLAUDE.md` → リポジトリの `global/CLAUDE.md`（SymbolicLink）

既存のファイルがある場合は `.bak` にリネームしてバックアップされます。

### 2. 既存PCで新しいプロジェクトを追加する場合

グローバル設定は既にリンク済みなので、プロジェクト設定のみ実行します。

```powershell
cd "C:\Users\<user>\OneDrive - Cisco\デスクトップ\mpj\10-dev\<new-project>"
& "C:\Users\<user>\claude-code-shared\setup-project.ps1"

# テンプレートを指定する場合
& "C:\Users\<user>\claude-code-shared\setup-project.ps1" -Template web-app
```

### 3. 共有リポジトリを更新した場合の反映方法

```powershell
cd C:\Users\<user>\claude-code-shared
git pull
```

| 設定の種類 | リンク方式 | 反映方法 |
|---|---|---|
| グローバル設定（skills, CLAUDE.md） | Junction / SymbolicLink | `git pull` のみで**自動反映** |
| プロジェクト設定 | コピー | `setup-project.ps1` の**再実行が必要** |

## OneDrive 環境での注意事項

プロジェクトディレクトリが OneDrive 配下にある場合、以下の点に注意してください。

- **Junction/SymbolicLink との相性**: OneDrive がリンクを実体ファイルとして同期してしまう場合があります。その場合は B案（コピー方式）への切り替えを検討してください
- **グローバル設定**: `%USERPROFILE%\.claude` は通常 OneDrive 管理外なので問題ありません
- **プロジェクト設定**: コピー方式のため OneDrive の影響は受けません

## 将来の拡張

### テンプレートの追加

`project-templates/` 配下にサブフォルダを作成し、プロジェクトタイプ別のテンプレートを管理できます。

```
project-templates/
├── CLAUDE.md              ← デフォルトテンプレート
├── settings.local.json    ← デフォルト設定
└── web-app/               ← Web アプリ用テンプレート
    ├── CLAUDE.md
    └── settings.local.json
```

使用時は `-Template` パラメータで指定します：

```powershell
.\setup-project.ps1 -Template web-app
```

### B案（コピー方式）への切り替え

OneDrive 環境で Junction に問題が発生した場合、`sync-commands.ps1` を実装してコピー方式に切り替えることができます。コピー方式ではグローバル設定も定期的な同期（手動またはタスクスケジューラ）が必要になります。
