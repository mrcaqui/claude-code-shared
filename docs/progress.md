# 進捗ログ

## 2026-03-13

#### 1. releaseスキルの進捗ログ記載ルールを厳格化

**Issue**

- 進捗ログへの追記時に、別の日付の配下に項目を追記したり、連番が正しく付与されない問題。

**Changes**

- 日付形式を `YYYY/MM/DD` から `YYYY-MM-DD`（ISO 8601）に変更。
- 本日の日付セクションが存在しない場合は新規作成し、他の日付の配下には追記しないルールを明記。
- 日付内の連番は昇順（1, 2, 3…）で付与し、既存項目をリナンバーしないルールを追加。

**Changed files**

- global/skills/release/SKILL.md

## 2026/03/12

#### 1. execplan-specスキルのトリガー条件を修正

**Issue**

- 「見えている計画書を実装して」「計画書をCodexレビューして」といったプロンプトでもexecplan-specスキルが読み込まれてしまう問題。

**Changes**

- descriptionから「実装」関連のトリガー条件を除外し、計画の新規作成・設計・更新時のみ発火するよう限定。
- 「トリガーしないケース」を明示的に記載（実装指示・レビュー依頼）。
- `.gitignore`の`.claude/`除外パターンを`.claude/*`に簡略化。

**Changed files**

- global/skills/execplan-spec/SKILL.md
- .gitignore

## 2026/03/09

#### 1. setup-project.ps1 に使い方を追記

**Changes**

- `setup-project.ps1` のコメントブロックに `.NOTES` セクションを追加し、呼び出し方（対象プロジェクトに cd してからスクリプトパスを指定）を記載。

**Changed files**

- setup-project.ps1
