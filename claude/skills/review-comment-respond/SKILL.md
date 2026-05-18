---
name: review-comment-respond
description: GitHub PR のレビューコメントに体系的に対応する。コメントを取得し、指摘の妥当性とスコープを精査して対応要否を判断し、必要な修正とテスト追加を行い、各コメントに返信して resolve する。「レビュー対応して」「PR コメント対応」「レビュー指摘を直して」と言われた時に使用。
argument-hint: '[PR番号] [-- コメントID...]'
allowed-tools: Bash(gh:*), Bash(git:*), Bash(jq:*), Read, Edit, Write, Grep, Glob, AskUserQuestion, TodoWrite
---

# Review Comment Respond

## 概要

GitHub PR のレビューコメントを取りこぼしなく対応する。**「全件取得 → 精査 → スコープ判定 → 実装 + テスト → 返信 + resolve」** を 1 サイクルとして回す。

**コアな考え方**: レビューコメントは必ずしも正しくない。特に Gemini / CodeRabbit / Cursor / Claude review 等の AI レビュアーは diff の周辺しか見ておらず、現実のコード文脈で見ると誤指摘・既出対応・実現不可な提案が混じる。**「指摘されたから直す」ではなく「指摘が正しいか + 今この PR で直すべきか」を毎回精査する**。

一方で、工数や面倒さを理由に対応を見送るのは禁止。精査の結果「対応不要」と判断した場合は、その根拠コードや検証結果を返信に明記する。

**引数**: $ARGUMENTS
  - PR 番号未指定の場合は、現在のブランチに紐づく PR を使う
  - `-- コメントID...` の形でコメント ID を絞り込み可能（未指定なら全件）

---

## 現在の状態

- ブランチ: !`git branch --show-current`
- 紐づく PR: !`gh pr view --json number,title,url 2>/dev/null | jq -r '"#\(.number) \(.title)\n\(.url)"' || echo "PR 未作成"`
- リポジトリ: !`gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null`

---

## ワークフロー

### 1. コメントの取得（全件）

PR 番号と repo を確定させる。引数で明示されていなければ現在ブランチの PR を使用。

```bash
PR=<PR番号>
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
OWNER=${REPO%/*}
NAME=${REPO#*/}
```

レビューコメント（inline）とレビュースレッドの解決状態を GraphQL で一括取得する。**isResolved=false のスレッドのみ対応対象**。

```bash
gh api graphql -f query='
query($owner:String!, $name:String!, $pr:Int!) {
  repository(owner:$owner, name:$name) {
    pullRequest(number:$pr) {
      title
      body
      reviewThreads(first:100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          comments(first:50) {
            nodes {
              id
              databaseId
              body
              author { login }
              url
              diffHunk
            }
          }
        }
      }
    }
  }
}' -F owner="$OWNER" -F name="$NAME" -F pr="$PR" > /tmp/review-threads.json
```

加えて issue コメント（PR 全体への一般コメント）も取得して併せて確認する:

```bash
gh api "repos/$REPO/issues/$PR/comments" > /tmp/issue-comments.json
```

引数で特定コメント ID が指定されていればそれだけに絞る。未指定なら **未 resolve の全スレッド + 未対応の issue コメント** が対象。

PR の title / body も読み込んでおく。**「この PR のスコープ」は後段の判定で必要になる**。

### 2. コメント一覧の整理と TodoWrite 登録

取得結果をスレッド単位でリストアップし、`TodoWrite` に **1 スレッド 1 タスク** で登録する。タスクには以下を含める:

- スレッド ID / 該当ファイル:行
- コメント本文の要約（誰が何を指摘したか）
- レビュアー種別（人間 / AI bot: gemini-code-assist / coderabbit / cursor 等）

**この時点では一次判定をしない**。次の「精査」フェーズで初めて要対応かを決める。

`isOutdated=true` のスレッドも対象に含める（コードが既に変更済みでも、指摘内容が現状に当てはまるか確認が必要）。

### 3. 精査フェーズ（必須・最重要）

各スレッドに対し、以下 3 軸を **必ずこの順で** 検証する。途中で「対応不要」が確定したら以降の軸は飛ばしてよい。

#### 3-A. 事実認識の検証「コメントは現実のコードを正しく見ているか」

レビュアー（特に AI bot）は diff の前後だけを読んでいることが多く、以下の誤りを頻繁に起こす:

- **diff だけ見て周辺の補正コードを見落とす**: 「初期値が壊れている」と言うが、実は次の useEffect で正しく上書きされる、など
- **古いコメントが新しい diff に当てはまっていない**: force push 後に古いスレッドが残ったケース
- **テストが既に存在するのに「テストを追加してください」と言う**: 別ファイルや別 describe block を見落としている
- **架空のシンボル / API を提案**: 存在しない関数名やプロパティを使うコードを提示してくる

**検証手順**:

1. 指摘対象のファイル全体（または当該関数全体）を Read で読む
2. 指摘の根拠となるコード（変数の流れ・呼び出し元・テスト）を Grep で確認する
3. 「指摘内容を再現するシナリオ」を頭の中（または最小コード片）で組み立てる
4. 再現できなければ **誤指摘** の可能性が高い

誤指摘が判明した場合は、**該当箇所のコード（ファイル:行）を引用しながら反証する返信** を書く（後述 5-d）。

> **過去事例**: PR #1781 で gemini-code-assist が「新規作成モードで初期値が壊れていて save イベントが飛ばない」と指摘したが、実コードでは `else` 分岐で空文字列を入れており指摘は誤り。コード片を引用して反証したら Gemini も「私の以前のコメントは誤りでした」と認めた。

#### 3-B. 技術的実現可能性の検証「提案は実際に動くか」

特に bot レビュアーは一般論ベースの提案をするため、プロジェクト固有の制約で **実装不可能** なケースがある。

**検証手順**:

1. 提案された方法を最小コストで試す（DB 系なら手元で migration 実行、CI 系なら一時ブランチで dry-run、ライブラリ系なら docs 参照）
2. ライブラリ / フレームワークの公式 docs で API の存在と挙動を確認
3. 動かない / 不可能な場合は **検証結果（エラーメッセージ、docs リンク、再現コマンド）を返信に書く**

> **過去事例**: PR #1796 で gemini-code-assist が「CREATE INDEX CONCURRENTLY を使え」と high priority で指摘。実際に Prisma 5.x の migrate engine が SQL 全体を transaction でラップする実装になっており、`COMMIT;/BEGIN;` trick も `cannot run inside a transaction block (P3018)` で失敗することを検証。検証結果を migration コメントと PR 返信に明記して不採用とした。

#### 3-C. 現 PR で対応すべきかの判定

事実認識・実現可能性が OK でも、**今この PR で対応すべきとは限らない**。以下の 3 分類に振り分ける:

| 分類 | 条件 | 対応 |
| --- | --- | --- |
| **要対応** | 現 PR が原因で生まれた問題、または現 PR のスコープに含まれる | 修正実装 + テスト追加 |
| **スコープ外** | 現 PR の趣旨と独立しており、別作業として切り出した方が PR が小さく保てる | 別 issue / TODO を作成し、その URL/ID をコメント返信に明記してから resolve |
| **議論・質問** | 設計判断の確認、情報提供の依頼 | 返信で回答（必要なら根拠コードを引用）|

**スコープ判定のチェック項目**（順に確認）:

1. **PR の title / description に書かれた目的に含まれるか**
2. **現 PR の diff が原因で生じた問題か**（=YES なら原則 PR 内で直す）
3. **指摘がこの PR より前から存在する問題か**（=YES なら別 issue 候補）
4. **修正により diff が大幅に拡大しレビュー負荷が逆に増えないか**

**禁止事項**:

- 工数を理由に「要対応」を「スコープ外」に降格させない
- 「LGTM」「nit」だけのコメントでも、返信と resolve をスキップしない
- スコープ外判定の場合は **必ず代替動線（別 issue / TODO コメント / 後続 PR への申し送り）を作成してから resolve する**
- 「精査の結果対応不要」の場合も **根拠を返信に書く** こと。返信なしで resolve しない

判断が割れる場合（特に「スコープ外」「精査の結果対応不要」に振り分けるコメント）は `AskUserQuestion` でユーザーに確認する。

> **過去事例**: PR #1781 で「計測ロジック単体のコンポーネントテスト追加」が指摘されたが、先行 PR でも未着手の領域で本 PR に閉じない。「Phase 2 として一括追加 PR でまとめる方針」と返信し、`docs/tracking.md` に Phase 2 候補として記載した上で resolve した。

### 4. 実装 + テスト追加（要対応のスレッドのみ）

「要対応」に分類したコメントについて、修正を実装する。

**テスト追加は必須**:

- 既存テストが指摘内容を再現できるよう拡張、または新規ケースを追加する
- テストが書けない種類の変更（例: typo 修正、コメント文言、フォーマット、IaC / migration の宣言）は、その理由を返信に明記する
- テストが既に存在し、追加不要と判断する場合も、該当テストファイル:行を返信で引用する

**禁止: 「指摘どおりの修正」を盲目的に行うこと**

- 指摘が部分的に正しくても、提案された変更がプロジェクトの他の場所のスタイルと衝突するなら、**指摘の核心だけを汲んで実装方法はプロジェクトに揃える**
- 修正後に再度自分で軽く self-review（変数名漏れ・参照漏れ・型エラー・lint・型チェック）してから返信に進む

修正完了後にローカルでテスト実行・lint・型チェックを走らせ、緑であることを確認する。

### 5. 返信とスレッド resolve

**1 スレッドにつき必ず 1 返信 + 1 resolve**。

#### a. inline コメントへの返信

```bash
# in-reply-to にスレッドの最初のコメントの databaseId を指定する
gh api -X POST "repos/$REPO/pulls/$PR/comments" \
  -f body="$(cat <<'EOF'
<対応内容を 2-4 行で要約>

- 対応: <変更ファイル:行 への参照>
- テスト: <追加/拡張したテスト or "テスト不要の理由">
- 補足: <あれば。スコープ外の場合は別 issue URL、不採用の場合は検証結果>
EOF
)" \
  -F in_reply_to=<最初のコメントの databaseId>
```

#### b. スレッドの resolve

```bash
gh api graphql -f query='
mutation($threadId:ID!) {
  resolveReviewThread(input:{threadId:$threadId}) {
    thread { isResolved }
  }
}' -F threadId=<スレッドID>
```

#### c. issue コメント（PR 全体宛）への返信

inline スレッドではないので resolve API は無い。`gh api -X POST "repos/$REPO/issues/$PR/comments" -f body="..."` で返信のみ行う。

#### d. 返信テンプレート（分類別）

**要対応 → 修正済み**:
```
ご指摘ありがとうございます。<要約>を修正しました。
- 対応: path/to/file.ts:42-58 で <変更内容>
- テスト: path/to/file.test.ts に <ケース名> を追加
```

**精査の結果、誤指摘**:
```
ご指摘ありがとうございます。確認したところ、ご指摘の挙動は発生しないようです。

`path/to/file.ts:L42-L58` で <反証コード片を引用>
```ts
// 該当コード
```
<どう動くかを 1-2 行>

念のため <検証方法> でも確認しました。

このまま現状維持としますが、もし別の文脈でお気づきの点があれば再度ご指摘ください。
```

**精査の結果、技術的に不可能 / プロジェクト方針外**:
```
ご指摘ありがとうございます。検証した結果、本 PR では現状維持としたいです。

検証内容:
- <試した方法>
- <得られたエラー / docs リンク>

代替: <あれば、別アプローチや将来案を 1-2 行>
```

**スコープ外 → 別 issue 化**:
```
ご指摘ありがとうございます。本 PR の趣旨（<PR 目的を 1 行>）から外れるため別 issue として切り出しました: <issue URL>
理由: <現 PR の diff と独立 / 影響範囲が広い / 等>
```

**質問・議論への回答**:
```
<回答本文>。根拠: path/to/file.ts:L42 / docs/foo.md
```

**ポイント**:
- 反証する場合も口調は丁寧に。「ご指摘ありがとうございます」「確認したところ」「念のため」を使う
- コード引用はバッククォート 3 つの ```ts ``` ブロック + 言語指定で見やすく
- 行番号は `path/to/file.ts:L42-L58` 形式で書くと GitHub 上でクリック可能

### 6. 取りこぼしチェック（最終工程・必須）

すべての対応終了後、再度 GraphQL で `isResolved=false` のスレッドが残っていないか確認する。

```bash
gh api graphql -f query='
query($owner:String!, $name:String!, $pr:Int!) {
  repository(owner:$owner, name:$name) {
    pullRequest(number:$pr) {
      reviewThreads(first:100) {
        nodes { id isResolved path line comments(first:1){ nodes { author { login } body } } }
      }
    }
  }
}' -F owner="$OWNER" -F name="$NAME" -F pr="$PR" \
  | jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)'
```

残っていれば原因を確認して再対応する。引数でコメントを絞り込んでいる場合は、対象外の未 resolve があっても良いが、その旨を最終報告に含める。

### 7. ユーザー向け最終報告

以下の形式でまとめてユーザーに報告する。

```
## レビュー対応サマリ

対象スレッド: N 件（要対応 X / 誤指摘・現状維持 W / スコープ外 Y / 議論 Z）

### 要対応 (X)
- <スレッド要約>: <変更ファイル>、テスト: <追加箇所>
- ...

### 誤指摘・現状維持 (W)
- <スレッド要約>: 反証根拠 = path/to/file.ts:L42

### スコープ外 (Y)
- <スレッド要約>: 別 issue #NNN に転記

### 議論・質問 (Z)
- <スレッド要約>: 返信のみ

未 resolve 残: 0 件（or N 件: <理由>）
```

---

## 注意事項

- **精査を飛ばさない**。特に AI bot レビュアーの指摘は、現実のコード文脈で再現するか必ず確認する
- **誤指摘なら反証する**。盲目的に修正すると、コードが余計に複雑になり後の保守者を困らせる
- **スコープ外判定の前にユーザー確認を取る**。「現 PR のスコープ」は機械的には決まらないため、自己判断で降格させない
- **テストなしで「対応済み」と返信しない**。テストが不要な根拠を返信に書くこと
- **resolve 前に返信を必ず投稿する**。返信なしの resolve は、レビュアーから見て何が行われたか追えなくなる
- **`gh pr review --approve` などレビュー状態を変える操作はしない**。これは PR 作者ではなくレビュアーの操作
- **コミットや push は本 skill では行わない**。ユーザーが `/commit` 等で別途実施する。実装変更まで完了したら一旦止まる
- inline コメント返信の `in_reply_to` には **スレッドの最初のコメントの `databaseId`（数値）** を指定する。`id`（base64 の Node ID）ではない

---

## AI レビュアー（bot）の典型的な誤り

過去の対応事例から観測されたパターン:

| パターン | 例 | 検証手順 |
| --- | --- | --- |
| **diff だけ見て周辺を見落とす** | 「初期値が壊れている」が、後段の useEffect で正しく上書きされる | 当該ファイル全体を Read |
| **架空の API / フラグを提案** | 存在しない Prisma preview feature 名を指定 | 公式 docs / 依存パッケージの型定義を確認 |
| **環境固有の制約を無視** | Prisma migrate で CONCURRENTLY を提案（実際は transaction wrap で不可） | 手元で実行 / docs / 既存 migration 履歴 |
| **テスト既存を見落とす** | 「テスト追加してください」だが既に別 describe にある | テストファイルを Read / Grep |
| **outdated な diff を指摘** | force push 後の古いスレッドが残存 | 現 HEAD のファイル内容を確認 |
| **一般論ベースの style nit** | プロジェクト独自規約と衝突する提案 | 周辺コード / CLAUDE.md / lint 設定を確認 |

これらは「却下してよい」のではなく「**毎回検証してから判定する**」が正しい。AI bot でも正しい指摘は多数あるため、最初から無視するのは禁止。

---

## よくある失敗

- **精査せず指摘どおり修正してしまう**: 後で「これ要らない変更だった」と revert する羽目になる。GRADING_MODEL を誤って変えてしまった事例のように、修正範囲を機械的に広げない
- **resolve だけして返信を忘れる**: レビュアー視点で対応内容が不明になる。必ず返信 → resolve の順
- **「nit」「typo」だけ無視する**: 軽微なコメントも分類対象に含める
- **スコープ外を口実に対応放棄**: 必ず別 issue や TODO を作成して動線を残す。動線なしの「別 PR で」は禁止
- **誤指摘に対し無言で resolve**: レビュアーは「修正されたかどうか分からないまま」になる。反証は丁寧に、コード引用付きで
- **テスト追加を後回し**: 修正と同じセッションで必ず追加する。「後で追加」と返信した時点で取りこぼす
- **issue コメントを見落とす**: review thread だけ見て PR 全体への一般コメントを見落とすケースが多い。両方確認する
- **修正後の self-review を省略**: 変数名漏れ・lint エラー・型エラーで CI が落ちて 2 巡目レビューが発生する。コミット前にローカル lint / typecheck を走らせる
