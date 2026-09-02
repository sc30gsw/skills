# sc30gsw/skills

[English README](./README.md)

自分がメンテしているエージェント skill 集。中心は **maintain-project-skills**。コード、ディレクトリ構成、外の世界(モデル名の変更、ライブラリのバージョンアップ)が変わっても、プロジェクトが持つ skill を嘘のない状態に保つための定期パス。

## インストール

```bash
npx skills@latest add sc30gsw/skills --skill maintain-project-skills
```

Claude Code、Codex、Cursor など `SKILL.md` を読むホストで動く。CLI は skill を `.agents/skills/` に置き、使っているエージェントの skill ディレクトリへリンクする。エージェントを明示するなら `-a claude-code`(または `codex`、`cursor` など)を付ける。

## maintain-project-skills

skill はコードベースについての散文で、散文はコードベースが動いてもテストで落ちない。この skill はプロジェクトが持つ全 skill を、それが説明しているコードと突き合わせて読み直し、古くなった箇所を直し、修正を一つずつ確認し、確認できたものだけを 1 本の PR として出す。

### 2 つの仕事

```
/maintain-project-skills
```

**Review(見直し)。** 引数なし。owned skill 全部、mismatch 全種類。参照している path やコマンドがもう無い、説明している挙動をコードが否定している、外の世界に関する主張(モデル ID、ライブラリのバージョン)が確認できなくなっている、の 3 つ。

```
/maintain-project-skills Fable 5 → Fable 5.1
```

**Apply(変更の適用)。** 変化を 1 つ、普通の言葉で宣言する。skill はその変化の影響だけを owned skill 全体から辿って直す。他の例: `src/lib moved to packages/core`、`--legacy flag removed`。

### 1 回の実行で起きること

1. プロジェクト内の全 skill を列挙し、`skills-lock.json` があればそれを使って owned(自作)と third-party(upstream 由来)に分ける(`scripts/list-skills.sh`)。
2. owned skill が言及しているリンク、path、コマンド、識別子、slash command を全部確認する(`scripts/check-references.sh`)。
3. owned skill 1 つにつき read-only の inspector を 1 つ送り、コードと突き合わせて mismatch を根拠付きで報告させる。
4. 修正を適用し、確認する。reference check が通ること、skill が同梱する script は文書通りのコマンドで使い捨ての git worktree 内で動くこと。
5. PR を 1 本出す。commit は skill ごとに 1 つ。証拠は全部 PR 本文に貼る。

### 絶対にやらないこと

- プロダクトコードを編集しない。skill が説明する挙動をアプリがもうしていない場合、skill が古い(skill を直す)か、アプリの regression(報告する。skill の文言を変えて隠さない)のどちらか。
- third-party skill を編集しない。`npx skills add` で入れた skill は次の `npx skills update` で上書きされるので、手編集を検知して報告するだけにする。
- モデル ID やバージョンを記憶から書き換えない。外の世界の主張は、ドキュメント参照で確認できたとき、または change statement でユーザーが名指ししたときだけ直す。
- 確認できていない修正を出さない。trial run が今の環境で実行できなければ、その修正は revert して「Unconfirmed, reverted」として PR 本文に列挙する。

### 結果

毎回、次の 3 つのうち 1 つで終わり、どれかを明言する。

| 結果 | 意味 |
|---|---|
| `current` | owned skill 全部を見直し、直すものなし。branch も PR も作らない。 |
| `updated` | 確認済み修正の PR が 1 本。未確認の修正と app regression は PR 本文に記述し、適用しない。 |
| `halted` | 見直しが完了できなかった、または修正を安全に出せなかった。原因を明記する。 |

### クラウドエージェントでの挙動

Cursor Cloud Agents、Claude Code on the web などのサンドボックスは、ホストを判定するのではなく実際に試して対応する。worktree による隔離はまずリポジトリ外で試し、次にリポジトリ内 `.maintain-trial`(git 除外)で試し、どちらも無理なら trial run をスキップして該当修正を revert する。`gh` が未認証なら commit 済み branch で止まり、PR はプラットフォーム側に任せる。証拠はセッションと一緒に消える scratch ではなく PR 本文に置く。

### 設計メモ

skill が使う語彙(owned skill、mismatch、reference、confirmation、app regression など)は [CONTEXT.md](./CONTEXT.md) に固定してある。判断のうち 2 つは ADR として [docs/adr](./docs/adr) に記録した。third-party skill は絶対に編集しない、外の世界の主張はドキュメントの裏付けなしに書き換えない、の 2 つ。

## このリポジトリにある他のもの

`.agents/skills/` には [mattpocock/skills](https://github.com/mattpocock/skills) から自分用に入れた skill が入っていて、`skills-lock.json` で管理している。必要なものだけ `--skill` で指定して入れてほしい。

## クレジット

「エージェント向けドキュメントを定期的に見直すパス」という発想は、Lauren Tan の [pstack](https://github.com/cursor/plugins/tree/main/pstack) プラグインにある verification 系 skill から得た。ここにある設計、語彙、script は、任意のプロジェクト skill を対象にする汎用ケース向けに独立して書いたもの。

## ライセンス

[MIT](./LICENSE)
