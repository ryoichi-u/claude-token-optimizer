# Claude Token Optimizer

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) のトークン消費を分析・削減するスラッシュコマンド集。

Claude Code のトークン消費は、`CLAUDE.md`、スラッシュコマンド定義、エージェント定義、ツール登録、実行時のデータ注入など多岐にわたります。このツールキットはそれらすべての無駄を特定し、削減を支援します。

## クイックスタート

最短はClaude Codeのプラグインマーケットプレイス経由:

```
/plugin marketplace add ryoichi-u/claude-token-optimizer
/plugin install claude-token-optimizer@claude-token-optimizer
```

または従来通りインストールスクリプトでも可能（全選択肢は[インストール](#インストール)参照）:

```bash
git clone https://github.com/ryoichi-u/claude-token-optimizer.git
cd claude-token-optimizer
./install.sh --target ~/your-project
```

Claude Code で:

```
/token-audit          # トークン消費の可視化
/optimize-context     # CLAUDE.md の圧縮
/tool-diet            # 未使用ツールの検出
/prompt-slim          # コマンド定義ファイルの圧縮
/context-guard        # 実行時データ注入リスクの検出
```

## コマンド一覧

### `/token-audit` — トークン消費の可視化

`CLAUDE.md`、`.claude/commands/`、`.claude/agents/` を全スキャンし、カテゴリ別のトークン消費をテーブル表示。最大ファイルにはセクション別の内訳も表示。

### `/optimize-context` — CLAUDE.md 圧縮（学習型）

7つの圧縮テクニック（重複除去、テーブル圧縮、セクション分離 等）を適用。過去の最適化結果を学習ログに記録し、次回以降の精度を向上。

**実績**: 本番モノレポで 348行 → 113行（66%削減）

### `/tool-diet` — 未使用ツールの検出

`settings.local.json` の登録ツールと、コマンド・CLAUDE.md での実際の使用を突合。未使用ツール1つあたり約200トークンの削減効果。

### `/prompt-slim` — コマンド定義ファイルの圧縮

スラッシュコマンドの `.md` ファイルは呼び出すたびにコンテキストに注入されます。冗長な説明や重複例を圧縮し、動作を変えずにサイズを削減。

### `/context-guard` — データ注入リスクの検出

コマンドや CLAUDE.md 内の、実行時に大量トークンを消費するパターンを検出: 無制限のファイル読み込み、全件ループ、フィルタなしの生データ注入 等。

## インストール

### 方法0: Claude Code プラグイン（推奨）

[Claude Code プラグインシステム](https://docs.anthropic.com/en/docs/claude-code/plugins)経由でインストール。clone もコピーも不要、`/plugin update` でワンコマンド更新可能:

```
/plugin marketplace add ryoichi-u/claude-token-optimizer
/plugin install claude-token-optimizer@claude-token-optimizer
```

5つのコマンドが即座に利用可能になります。

### 方法1: インストールスクリプト

```bash
./install.sh --all --target ~/your-project    # 全コマンドをインストール
./install.sh --pick --target ~/your-project   # 選択してインストール
./install.sh --list                           # 利用可能なコマンドを表示
```

### 方法2: 手動コピー

`commands/` から `.claude/commands/` に必要なファイルをコピー:

```bash
cp commands/token-audit.md ~/your-project/.claude/commands/
```

## トークン推定方式

| コンテンツ種別 | 係数 | 根拠 |
|-------------|------|------|
| 英語テキスト | ×0.75 | 平均約4文字/トークン |
| 日本語混在テキスト | ×2.3 | マルチバイトエンコーディング + トークナイザ分割 |
| ツール定義 | 約200/ツール | 経験的平均値（スキーマJSON含む） |

言語はファイルごとにマルチバイト文字比率から自動判定。

## テクニックリファレンス

[docs/techniques.md](docs/techniques.md) に全テクニックのカタログを収録:

- **静的最適化**: CLAUDE.md 圧縮（7テクニック）
- **実行時最適化**: 事前フィルタリング、段階的処理、サンプリング、モデル選択
- **ツール最適化**: 未使用ツール削除、MCP サーバー選択

## FAQ

**Q: 圧縮でプロジェクトが壊れない？**
A: 情報の削除は行いません。移動・圧縮・簡略化のみです。`/optimize-context` は変更前に必ず確認を求め、`git checkout` でいつでも元に戻せます。

**Q: トークン推定の精度は？**
A: 近似値です。実際のトークナイザとは差がありますが、相対比較（どのファイルが大きいか、変更でどれだけ減るか）は最適化の判断に十分な精度です。

**Q: 5つ全部必要？**
A: いいえ。まず `/token-audit` で現状を把握し、必要に応じて追加してください。各コマンドは独立しています。

## ライセンス

MIT
