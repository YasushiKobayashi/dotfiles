---
name: amazon-receipts-download
description: Amazon.co.jp の注文の領収書（明細書／適格請求書 PDF、無ければ印刷可能な注文概要を PDF 化）を、ユーザーが Chrome で開いた「注文の詳細」タブから一括保存し、Dropbox の月別フォルダへ移動する。「amazonの領収書DLして」「4月進めて」「開いたので同様に」と言われた時に使用。
argument-hint: '[MM（保存先の月。省略時は注文日から判断）]'
allowed-tools: Bash, Read, mcp__claude-in-chrome__tabs_context_mcp, mcp__claude-in-chrome__browser_batch, mcp__claude-in-chrome__javascript_tool, mcp__claude-in-chrome__tabs_close_mcp, mcp__claude-in-chrome__computer
---

# Amazon 領収書一括ダウンロード

**対象月**: $ARGUMENTS

## 前提（このマシン固有）

- ユーザーが Claude の Chrome タブグループ内で **注文履歴** タブと、対象月の **注文の詳細** タブ群を開いておく（ログイン・タブを開く操作はユーザーが行う）
- Chrome の既定ダウンロード先は **`~/Desktop`**
- 保存先: `~/Library/CloudStorage/Dropbox/会計資料/各種領収書/amazon/<YY>/<MM>/`（例 `amazon/26/04`。YY/MM は半角 2 桁）
- ファイル名: `amazon_<注文日YYYYMMDD>_<注文番号>.pdf`
- `~/Desktop` / Dropbox へのアクセスは sandbox 外 (`dangerouslyDisableSandbox: true`) が必要

## 手順

1. `tabs_context_mcp` でタブ一覧を取得。URL が `/your-orders/order-details` のタブを対象にする
   - **注文履歴タブ (`/your-orders/orders`) は触らない・閉じない**
   - レビューページなど注文詳細以外のタブは処理対象外（最後に閉じてよい）
2. `collect.js`（このスキルのディレクトリ）を Read し、その内容を `javascript_tool` の `text` として各注文詳細タブで実行する
   - `browser_batch` に **4〜6 タブずつ** まとめる（1 回に多すぎると CDP 45 秒タイムアウトに当たる）
   - 戻り値: `PDF <name>` = 請求書 PDF を保存 / `HTML <name>` = 注文概要 HTML を保存（後で PDF 化）/ `NONE` / `NG` は要調査
3. 全タブ終わったら `finalize.sh <DEST>` を実行（timeout は長め、10 分程度）
   - Desktop の `amazon_*.html` → headless Chrome で PDF 化 → `%%EOF` で完全性チェック → DEST へ `mv -n`
   - `ID MISMATCH` / `INCOMPLETE` が出たら報告して該当ファイルを再取得
4. 保存を確認した注文詳細タブを `tabs_close_mcp` で閉じる
5. 注文日・注文番号・取得元（請求書 PDF / 注文概要から変換）の表で報告

## ハマりどころ（実際に踏んだもの）

- **PDF ビューアのダウンロードボタンは効かない**（クリックしても保存されない）。`fetch` → Blob → `<a download>` で保存する
- **「領収書等」ポップオーバーは遅延ロード**。クリックしないと `/documents/download/.../invoice.pdf` リンクが DOM に無い
- **デジタル注文 (`D01-`) でも請求書 PDF があることがある**。印刷リンクが見えた瞬間に判定せず、最低 2 秒 PDF リンクを待つ（collect.js 実装済み）
- **javascript_tool の戻り値に URL クエリ文字列を含めると `[BLOCKED: Cookie/query string data]`** になる。パスだけ・ファイル名だけ返す
- 注文概要 HTML は `<script>` を除去し `<base href="https://www.amazon.co.jp/">` を足さないと headless 変換でスタイル・画像が崩れる
- headless Chrome の `--print-to-pdf` は書き出し後にプロセスが終わらないことがある → ファイル出現を待って kill（finalize.sh 実装済み）
- ユーザーが途中で Desktop のファイルを Dropbox に移動していることがある。「ファイルが消えた」と慌てず `find` / `mdfind` で所在確認する
