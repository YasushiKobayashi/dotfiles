# グローバル CLAUDE.md（全プロジェクト共通）

~/dotfiles/claude/CLAUDE.md が実体（dotfiles 管理）。`dotfiles_link.sh` で ~/.claude/CLAUDE.md に symlink される。
プロジェクト固有のルールは各リポジトリの CLAUDE.md / メモリに置き、ここには**マシン・ユーザー全体に効くものだけ**を書く（全セッションの固定ロードになるため薄く保つ）。

## 応答

- 日本語で応答する

## Git 運用

- push は**作業の区切りでまとめて 1 回**。commit ごとに push しない（CI コスト・bot コメント上書きの抑制）。明示指示か明確な理由（デプロイ確認・レビュー依頼）がない限り自発的に push しない
- 自分が作っていない差分は commit に含めない（pathspec で限定する）

## このマシンの sandbox 実行のクセ

- **Go 製 CLI（gh / buf / golangci-lint / terraform 等）の TLS 検証は sandbox 内で失敗しがち**。根本原因は macOS sandbox の `com.apple.trustd.agent` 遮断。対処は各プロジェクトの `.claude/settings.local.json` に `sandbox.enableWeakerNetworkIsolation: true` + `sandbox.network.allowedDomains`（iesapuri は 2026-08-07 設定済み）。それでも失敗する場合のみ `dangerouslyDisableSandbox: true` で再実行する
- sandbox 内ネットワークはプロキシ方式。`X-Proxy-Error: blocked-by-allowlist` の 403 は allowlist 層の遮断（trustd とは別レイヤ）。allowedDomains への追記で対処する
- `gh` / `git push` / `git fetch` 等のリモート系 git は sandbox 外実行が必要なマシン（iesapuri は PR #2408 マージ後 excludedCommands で自動化される）
