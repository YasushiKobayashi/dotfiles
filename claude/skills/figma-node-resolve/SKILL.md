---
name: figma-node-resolve
description: Storybook の story が指す Figma node-id が広すぎる/古い場合に、対象コンポーネントに対応する正しい子 node-id を解決して story の Figma URL を更新する。「Figma と story の紐付け直して」「figma の node 絞り込んで」「story の design URL 古い」と言われた時に使用。design-check の前段に挟む使い方も可。
argument-hint: <story-file-path> [--apply|--dry-run]
allowed-tools: mcp__figma-developer-mcp__get_figma_data, Glob, Grep, Read, Edit, Bash
---

# figma-node-resolve

Storybook の `parameters.design.url` が「親フレーム全体（編集画面まるごと等）」を指していて、対象コンポーネントを絞り込めていない状態を解消する skill。Figma の node 階層を walk し、対象コンポーネントに最もマッチする子 node-id を提案/反映する。

**本 skill のスコープ**:

- 入力 story file の Figma URL 解決と書き換えのみ
- **実装側のスタイル比較は行わない**（それは `/design-check` の責務）
- 解決後、後続で `/design-check` を回すのが想定フロー

## 関連 skill との関係 (SSOT 宣言)

本 skill は **Figma node-id マッチングロジックの SSOT** である。同じマッチング行為を扱う他 skill は本 skill の Step 3「マッチングルール」を参照すること。重複定義しない。

| skill            | 本 skill との関係                                                                                                                                                                                               |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/new-component` | 新規 story 生成後、画面 URL のまま埋めて生成完了。**ユーザーに本 skill 実行を提案**して node-id を絞り込ませる（インラインで解決ロジックを持たない）                                                            |
| `/design-check`  | 親 node-id しか story に書かれていない場合、本 skill のマッチングルール（priority A-D）に従って子 node を選定。書き換えはせず **比較目的で一時的に子 node を取得**する（permanent な書き換えは本 skill が担当） |
| 役割境界         | 「story file を書き換える permanent 操作」= 本 skill / 「比較のため一時的に子 node の style を取る」= design-check                                                                                              |

## 引数

**第 1 引数**: story file のパス（必須）

- 例: `front/src/ai-color-modules/src/template/SimulationDetail/AreaColorSelector.story.tsx`

**第 2 引数**: 反映モード（任意、default `--dry-run`）

- `--dry-run`: 候補と diff を提示して止める。書き換えはしない
- `--apply`: 第一候補で `Edit` ツールで自動書き換え

**指定された引数**: $ARGUMENTS

---

## タスク

### Step 1: story から現在の Figma URL を抽出

1. 指定 story file を `Read`
2. `parameters.design.url` から `fileKey` と `node-id` を正規表現で抽出
   - URL 形式: `https://www.figma.com/design/<fileKey>/...?node-id=<nodeId>...`
   - `node-id` は URL では `12345-6789` 形式、API では `12345:6789` 形式（ハイフン↔コロン）
3. `title: 'foo/bar/MyComponent'` から末尾セグメント `MyComponent` を「比較対象コンポーネント名」として抽出
4. story の decorator または render 関数の幅指定（例: `w-[240px]`, `w-60`）を **サイズヒント**として抽出（後続のサイズ近似 fallback で使用）

`parameters.design` が無い / `node-id` が抽出できない場合は **Step 2 をスキップして Step 3 から開始**（親 node-id 不明モード）。

### Step 2: Figma node 階層の取得（親 node-id がある場合）

Figma MCP が利用可能か確認:

1. **MCP 優先**: `mcp__figma-developer-mcp__get_figma_data(fileKey, nodeId, depth=4)` を実行
2. **MCP が無い / fail のとき REST API fallback**:

   ```bash
   curl -s -H "X-Figma-Token: $FIGMA_API_KEY" \
     "https://api.figma.com/v1/files/${FIGMA_FILE_KEY}/nodes?ids=${nodeId}&depth=4" \
     > /tmp/claude/figma_walk.json
   ```

   - `FIGMA_API_KEY` / `FIGMA_FILE_KEY` は環境変数 or プロジェクトの secret store から取得（agent が token を直接扱わない設計が望ましい）
   - プロジェクトに `mise run figma:fetch-node` 相当の wrapper task があればそれを優先（token を `.env.local` から自動読込できる）
   - depth は **4 から始めて**、ヒット node が無ければ 6、続けて 8 と段階拡張（403/429 回避のため）
   - 出力先は `/tmp/claude/figma_walk.json` 固定（後続 jq で再利用）
   - `FIGMA_API_KEY` 未設定エラーが出たら、token を発行して環境にセットするようユーザーに依頼

### Step 3: 候補 node の選定（マッチングルール）

走査した tree の各 node を `(name, type, absoluteBoundingBox)` で評価し、以下の優先順位で候補を選ぶ:

1. **完全一致 (priority A)**: `node.name` が比較対象コンポーネント名と等しい
   - 例: コンポーネント名「OptionPanel」 ↔ node.name「OptionPanel」
2. **kebab/snake/PascalCase 正規化一致 (priority B)**: 大文字小文字とハイフン/アンダースコアを除去して比較
   - 例: 「LayerInlineMenu」 ↔ 「layer-inline-menu」 ↔ 「Menu / ellipsis」(後者は ×、`Menu` のみ部分一致 → C へ)
3. **意味的部分一致 (priority C)**: 比較対象名に含まれるキーワード（"Menu", "Panel", "Selector", "Dialog", "Item" 等）が node.name に含まれる
   - 例: 「LayerInlineMenu」 ↔ 「Menu / ellipsis」（Menu キーワードヒット）
4. **サイズ近似 fallback (priority D)**: 上 3 つで候補が出ないとき、Step 1 で抽出した story の幅ヒントと `absoluteBoundingBox.width` の差が ±30px 以内の node を候補化
5. **type フィルタ**: 候補は `FRAME` / `INSTANCE` / `COMPONENT` / `COMPONENT_SET` のみ。`VECTOR` / `TEXT` / `RECTANGLE` 等は除外

### Step 4: 候補提示

候補を以下の形式で出力:

```
## Figma node 解決候補

### 入力
- Story file: <path>
- 旧 node-id: <oldNodeId>（Figma 名: <oldName>, サイズ <w>x<h>）
- 比較対象コンポーネント名: <componentName>
- サイズヒント: <storyWidth>

### 候補（優先度順）
| 順位 | node-id | Figma 名 | type | サイズ | 一致根拠 |
|------|---------|---------|------|--------|---------|
| 1 | 13042-6166 | menu | FRAME | 240x638 | priority B (正規化一致) |
| 2 | ... | ... | ... | ... | ... |

### 推奨
- 第一候補 `<nodeId>` を採用
- 旧 → 新: `<oldNodeId>` → `<newNodeId>`
- 想定 diff: `parameters.design.url` の `node-id=<oldNodeId>` を `node-id=<newNodeId>` に置換
```

### Step 5: 反映（--apply 時のみ）

第一候補で story file の `parameters.design.url` を `Edit` ツールで書き換え。複数候補が同じ priority のときは **--apply でも書き換えず、ユーザーに選択を求める**（誤反映防止）。

## マッチングが失敗するケース

| ケース                                               | 対処                                                                                                                             |
| ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| 親 node が広すぎて候補が 50+ 件出る                  | type を `INSTANCE` のみに絞り込み、それでも多いなら priority A/B のみで再評価                                                    |
| Figma node 名が placeholder (Frame 28, Container 等) | priority A/B/C すべて 0 件になる → サイズ fallback (D) のみで候補化、警告を出す                                                  |
| Figma API が 403 (token 失効)                        | レスポンスに `Invalid token` を検出した場合は user に `FIGMA_API_KEY` の再発行 / 再設定を依頼し中断                              |
| story の `parameters.design` 自体が無い              | Step 2 スキップ。ユーザーに「親 node-id を教えてください」と聞く                                                                 |
| story が複数 component を render（template story）   | 比較対象コンポーネント名を聞き直す                                                                                               |

## 出力契約（後続 skill 連携用）

`--apply` 成功時、後続で `/design-check <story-file-path>` を呼ぶことを **末尾で必ず提案**。理由: node-id が変わると design-check の比較結果も変わるため、紐付け直後に diff 取得が自然。

## 設計判断の記録

- **`/design-check` に組み込まなかった理由**: design-check の責務は「実装 vs Figma の computed style 差分検出」(diff)。紐付け確立は前段階で、毎回やる作業ではない。混ぜると design-check の単一責任が壊れる。
- **`/new-component` に組み込まなかった理由**: new-component は新規ひな型生成。既存 story への再紐付けにも使いたいので独立 skill が必要。
