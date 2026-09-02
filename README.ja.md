# sc30gsw/skills

[English README](./README.md)

自分がメンテしているエージェント skill 集。中心は **maintain-project-skills**。コード、ディレクトリ構成、外の世界(モデル名の変更、ライブラリのバージョンアップ)が変わっても、プロジェクトが持つ skill を嘘のない状態に保つための定期パス。

## インストール

```bash
npx skills@latest add sc30gsw/skills --skill maintain-project-skills
```

Claude Code、Codex、Cursor など `SKILL.md` を読むホストで動く。CLI は skill を `.agents/skills/` に置き、使っているエージェントの skill ディレクトリへリンクする。エージェントを明示するなら `-a claude-code`(または `codex`、`cursor` など)を付ける。

## maintain-project-skills

skill はコードベースについての散文で、散文はコードベースが動いてもテストで落ちない。この skill はプロジェクトが持つ全 skill を、それが説明しているソースと突き合わせて読み、修正を一つずつ証明し、証明できたものだけを 1 本の PR として出す。

### 2 つのモード

```
/maintain-project-skills
```

**Audit(監査)。** 引数なし。owned skill 全部、drift 全分類。引用している path やコマンドがもう無い、説明している挙動がソースと食い違う、外の世界に関する主張(モデル ID、ライブラリのバージョン)が検証できなくなっている、の 3 つ。

```
/maintain-project-skills Fable 5 → Fable 5.1
```

**Propagate(伝播)。** 変化を 1 つ、普通の言葉で宣言する。skill はその変化の影響だけを owned skill 全体から探して直す。他の例: `src/lib moved to packages/core`、`--legacy flag removed`。

### 1 回の実行で起きること

1. プロジェクト内の全 skill を列挙し、`skills-lock.json` があればそれを使って owned(自作)と vendored(upstream 由来)に分ける(`scripts/list-skills.sh`)。
2. owned skill が引用しているリンク、path、コマンド、識別子を全部確認する(`scripts/check-citations.sh`)。
3. owned skill 1 つにつき read-only の subagent を 1 つ起動し、ソースと突き合わせて drift を根拠付きで報告させる。
4. 修正を適用し、証明する。citation check が通ること、skill が同梱する script は隔離した git worktree で dry-run が通ること。
5. PR を 1 本出す。commit は skill ごとに 1 つ。証拠は全部 PR 本文に貼る。

### 絶対にやらないこと

- プロダクトコードを編集しない。skill が説明する挙動をアプリがもうしていない場合、skill が古い(skill を直す)か、アプリの regression(報告する。docs で隠さない)のどちらか。
- vendored skill を編集しない。`npx skills add` で入れた skill は次の `npx skills update` で上書きされるので、手編集を検知して報告するだけにする。
- モデル ID やバージョンを記憶から書き換えない。外の世界の事実は、ドキュメント参照で確証が取れたとき、または change statement でユーザーが名指ししたときだけ直す。
- 証明できていない修正を出荷しない。dry-run が今の環境で走らなければ、その修正は revert して「Unproven, held back」として PR 本文に列挙する。

### 結果

毎回、次の 3 つのうち 1 つで終わり、どれかを明言する。

| 結果 | 意味 |
|---|---|
| `clean` | owned skill 全部をカバーし、出荷するものなし。branch も PR も作らない。 |
| `changed` | 証明済み修正の PR が 1 本。未証明の修正と product gap は PR 本文に列挙し、適用しない。 |
| `blocked` | カバーが完了できなかった、または修正を安全に出荷できなかった。何が阻んだかを明記する。 |

### クラウドエージェントでの挙動

Cursor Cloud Agents、Claude Code on the web などのサンドボックスは、ホストを判定するのではなく能力を probe して対応する。worktree による隔離はまずリポジトリ外で試し、次にリポジトリ内 `.maintain-dryrun`(git 除外)で試し、どちらも無理なら dry-run をスキップして該当修正を保留する。`gh` が未認証なら commit 済み branch で止まり、PR はプラットフォーム側に任せる。証拠はセッションと一緒に消える scratch ではなく PR 本文に置く。

### 設計メモ

skill が使う語彙(owned skill、drift、citation、proof、product gap など)は [CONTEXT.md](./CONTEXT.md) に固定してある。判断のうち 2 つは ADR として [docs/adr](./docs/adr) に記録した。vendored skill は絶対に編集しない、外部事実はドキュメントの裏付けなしに書き換えない、の 2 つ。

## このリポジトリにある他のもの

`.agents/skills/` には [mattpocock/skills](https://github.com/mattpocock/skills) から自分用に vendored した skill が入っていて、`skills-lock.json` で管理している。必要なものだけ `--skill` で指定して入れてほしい。

## クレジット

maintain-project-skills は Lauren Tan の [pstack](https://github.com/cursor/plugins/tree/main/pstack) プラグインにある `maintain-verification-skill` を汎用化したもの。原典はプロダクトを実際に動かして証明する。この skill は skill をソースと突き合わせて読み、同梱物を動かして証明する。

## ライセンス

[MIT](./LICENSE)
