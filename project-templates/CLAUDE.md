# Python / uv policy

- Python関連の作業では、必ず `uv` を使用すること
- `python`、`python3`、`pip`、`pip3` を直接実行しない
- Pythonの仮想環境が対象フォルダで未作成の場合は、まず `uv init` を使用してプロジェクトを初期化する
- 依存関係が必要な場合は `uv add <package>` を使用する
- Python実行: `uv run python ...`
- ツール実行: `uv run <tool> ...`（pytest、ruff、mypy等）
- pip互換ワークフローが明示的に必要な場合のみ `uv pip ...` を使用
- Bashコマンドを実行する前に、uvの等価コマンドに書き換えること
- Python関連の提案を行う際は、まずuvベースの手順を優先して提示すること
