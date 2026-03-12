# 進捗ログ

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
