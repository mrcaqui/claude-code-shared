# claude-code-shared

Claude Code の設定（グローバル CLAUDE.md、スキル、プロジェクトテンプレート）を Git で管理し、複数の PC で共有するためのリポジトリ。

## リポジトリ構成

```
claude-code-shared/
├── global/                  # グローバル設定（シンボリックリンクで共有）
│   ├── CLAUDE.md            # ~/.claude/CLAUDE.md のリンク先
│   └── skills/              # ~/.claude/skills/ のリンク先
│       ├── codex-review/
│       ├── execplan-spec/
│       └── release/
├── project-templates/       # プロジェクト初期化テンプレート（コピーして使用）
│   ├── CLAUDE.md            # プロジェクト共通の CLAUDE.md 雛形
│   └── settings.local.json  # プロジェクト共通の権限設定
├── setup-global.ps1         # グローバル設定セットアップ（PC につき 1 回）
└── setup-project.ps1        # プロジェクト設定セットアップ（プロジェクトごと）
```

## 2 つのセットアップスクリプトの違い

| | setup-global.ps1 | setup-project.ps1 |
|---|---|---|
| **対象** | `~/.claude/` (グローバル) | 各プロジェクトの `.claude/` |
| **方式** | シンボリックリンク / Junction | ファイルコピー |
| **実行頻度** | PC につき 1 回 | プロジェクトごとに 1 回 |
| **リポジトリ更新の反映** | 自動（リンクなので即時反映） | 手動（再実行してコピーし直す） |

## 新しい PC でのセットアップ

### 1. リポジトリをクローン

```powershell
cd C:\Users\<username>
git clone <repo-url> claude-code-shared
```

### 2. グローバル設定を適用

```powershell
# 開発者モードの有効化、または管理者権限で実行が必要
& C:\Users\<username>\claude-code-shared\setup-global.ps1
```

これにより以下のリンクが作成される:

- `~/.claude/skills/` → `global/skills/`（Junction）
- `~/.claude/CLAUDE.md` → `global/CLAUDE.md`（SymbolicLink）

### 3. 各プロジェクトに設定を適用

```powershell
cd C:\path\to\your-project
& C:\Users\<username>\claude-code-shared\setup-project.ps1

# テンプレート指定（project-templates/<name>/ 配下を使用）
& C:\Users\<username>\claude-code-shared\setup-project.ps1 -Template web-app
```

これによりプロジェクトの `.claude/` に以下がコピーされる:

- `CLAUDE.md` — プロジェクト固有に編集して使う雛形
- `settings.local.json` — 権限設定

## 既存の PC で再適用するとどうなるか

### グローバル設定 (`setup-global.ps1`) を再実行した場合

| 状態 | 動作 |
|---|---|
| 正しいリンクが既に存在 | **スキップ**（何もしない） |
| 別のリンク先を指している | 既存リンクを削除して正しいリンクを再作成 |
| リンクではなく通常のファイル/フォルダが存在 | `.bak` にリネームしてバックアップ → 新しいリンクを作成 |
| 何も存在しない | 新規にリンクを作成 |

**結論**: 何度実行しても安全。既存のリンクが正しければ何も変わらない。通常ファイルがあればバックアップされるのでデータは失われない。

### プロジェクト設定 (`setup-project.ps1`) を再実行した場合

| 状態 | 動作 |
|---|---|
| `.claude/` 内にファイルが存在しない | そのままコピー |
| `.claude/` 内にファイルが既に存在 | **上書き確認プロンプト**が表示される（y/N） |

**結論**: 既にプロジェクト固有にカスタマイズした `.claude/CLAUDE.md` がある場合、`N` を選べば上書きされない。テンプレートの更新を取り込みたいときだけ `y` で上書きする。

> **注意**: 上書きした場合、プロジェクト固有のカスタマイズは失われる。必要なら手動でバックアップしてから再適用すること。

## 日常の運用フロー

### グローバル設定を更新したい場合

`global/CLAUDE.md` や `global/skills/` を編集して commit/push するだけ。シンボリックリンクなので、全 PC で `git pull` すれば即反映される。

### プロジェクトテンプレートを更新したい場合

`project-templates/` を編集して commit/push する。ただし既存プロジェクトには自動反映されないため、必要に応じて各プロジェクトで `setup-project.ps1` を再実行する。

### 新しいスキルを追加したい場合

`global/skills/<skill-name>/SKILL.md` を作成して commit/push する。シンボリックリンク経由で全 PC に反映される。

## 前提条件

- Windows 10/11
- PowerShell 5.1 以上
- シンボリックリンク作成のため**開発者モード有効化**または**管理者権限**が必要（`setup-global.ps1` のみ）
