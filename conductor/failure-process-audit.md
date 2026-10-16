# エージェントの失敗プロセス監査

## 結論

繰り返しているのは、調査対象と完了条件を確定する前に、近くにある実行可能な作業へ置き換える失敗である。障害の調査が読書の続行、コミット状態の確認、別のループの調査、文書整理、スキル修正へ移り、元の依頼に必要な実行証拠が後回しになる。

`unfuck-yourself` の旧実装はこの問題をさらに固定化していた。2026-08-27 の作成依頼には実際に巨大なノートと頻繁な圧縮への対処が含まれていた。その例を、文書の計測・リファクタリング・縮小量の報告という固定手順にしたため、原因の候補と完了条件が文書管理だけに閉じた。元の依頼に文書整理がなかった、という説明は正しくない。

## 調査範囲と証拠の扱い

- 対象は session metadata の cwd が `.awesome-agent` と一致するローカル Codex 記録。2026-02、03、06、07、08、09 の親記録を対象に、実際の依頼、修正、スキル呼び出し、操作、結果、終了報告を確認した。子記録は親の証拠を補う場合だけ使用した。
- 大きな JSONL は意味のあるメッセージと操作列を抽出し、該当する因果列を原文レコードで確認した。全ファイルの全バイトを読んだという意味ではない。
- Codex の project index と保存済み rollout の一致を確認した。対応する Claude project directory は JSONL がなく、sessions index も空だった。別プロジェクトの Claude ファイルは開いていない。
- 親エージェントが以下の主要な操作・結果・修正列を直接再確認した。子エージェントの評価は証拠として自動採用していない。
- 当時の依頼変更と当時有効な権限で判定した。後日の制限を過去へ遡及適用しない。過去の依頼は現在の実行権限ではない。
- 生チャット、秘密情報、個別の private session identifier は保存していない。以下の日時と JSONL 行番号で元記録を特定できる。

## 証拠索引

`~/.codex/sessions/YYYY/MM/DD/rollout-YYYY-MM-DDTHH-MM-SS-*.jsonl` の日時部分を使用する。

| 参照 | 記録日時 | 決定的な JSONL 行 | 確認した内容 |
| --- | --- | --- | --- |
| A | 2026-02-19T16-38-04 | 137–149、199–256、276–289、308–338 | 隔離検証と実環境の混同、導入後の frontmatter 警告 |
| B | 2026-08-04T18-30-14 | 9–59、92–130、284–312、348–410、418–498 | 履歴保存、source-only 完了、修正の解釈反転 |
| C | 2026-08-05T11-35-07 | 9–60、64–123、127–167 | 引用された失敗の誤解、別タスクへの脱線、調査だけで停止 |
| D | 2026-08-17T19-14-09 | 47–62、288–307、427–454 | 重複タスク記録、誤ったループ、遅れた native state 確認 |
| E | 2026-08-18T18-02-41 | 356–380、390–510 | スキル内部に残った旧履歴スコープの修正 |
| F | 2026-08-27T13-22-59 | 11、56–209、301–324、494–598、618–690 | 読み込み連鎖、旧スキルの作成理由・固定手順・検証範囲 |
| G | 2026-09-08T15-27-23 | 89、154、160 | 今回のシナリオ評価、実ログ監査前の Goal 完了、追加修正 |
| H | 2026-08-07T01-10-32 | 7–47、97–132、279、351、559 | council の固定反復条件、model-output trust の修正 |

## 確認された失敗と原因

### 1. 失敗の引用を実行指示として扱い、調査対象を置き換える

- C: 不完全な読書を示すエージェントの文が提示された。応答はその読書の続行を開始した。調査を求める修正後は、前セッションのコミットと dirty state を確認する方向へ移った。再修正で初めて、提示された文が表している読書の失敗を調査した。
- D: 継続の失敗を調べる依頼に対して repository の shell runner を対象にした。built-in Goal continuation だと修正されてから `get_goal` を呼んだ。
- G: 今回も、実際の失敗列を調べる前にスキル修正と人工シナリオ評価へ置き換え、Goal を完了にした。
- 失敗段階: 要求解釈 → 調査対象選択 → 証拠収集。
- 原因: 引用・診断・実行の区別と、対象プロセスの native state 確認が操作開始より後になった。隠れた心理やモデル内部の動機は証明できない。
- 修正: 新スキルの最初に依頼種別と対象プロセスを確定し、実際の障害監査では raw execution records を instruction edit より先に読む手順を置いた。

### 2. スキルの読み込みや受領記録が、本来の作業を置き換える

- C: GYST を継続中と書きながら turn を終了した。次の調査要求では履歴復旧とコミット確認へ移った。`task_complete` event は turn 終了の記録であり、それ単体を虚偽の「GYST 完了」宣言とは判定しない。問題は必要な実行を残して応答を終えたことと、次の対象選択である。
- F: GYST が広い instruction/reference/note stack を読み込んだ後、ユーザーが latest-state の短い修正へ境界を変更した。旧ルールが広い読み込みを要求していた事実と、そのルール自体が高コストだった問題を分ける。
- 失敗段階: スキル実行、作業再開、完了判定。
- 原因: 呼び出し・読み込み・必要手順の実施・結果検証を別状態として追っていなかった。
- 修正: 各 invocation について request、当時の skill、required step、実際の操作と結果、未実施事項、終了報告、後続修正を連結する監査手順を追加した。

### 3. 文書サイズを原因と成果の両方にしてしまう

- F: 作成要求は大きなノートと圧縮の問題を含んでいた。旧スキルは原因候補を append-only status、duplicate rules、stale receipts 等に限定し、修復を文書リファクタリングに固定した。
- 同じ記録の検証はサイズ、生成物一致、リンク、既存テストである。それらは実在する検証だが、将来の圧縮や脱線が解消した証拠ではない。
- 失敗段階: 因果分析 → 修復選択 → 完了条件。
- 原因: 観測された一種類の症状を一般的な原因モデルにした。文書が短くなることと、要求した作業が正しく進むことを同一視した。
- 修正: 原因・寄与条件・失敗段階・検出漏れを先に特定し、文書構造との因果関係がある場合だけ整理する。サイズとコンテキスト消費からモデル内部の失敗原因を断定しない。

### 4. 一部だけ更新したルールが、古いスコープを再導入する

- B: current-session と historical review の解釈が複数回反転した。その後、ユーザーが明示的に二週間・全スキルの方針を要求した。したがって二週間というルールの存在自体を無断の創作とは扱わない。
- E: 後の修正で project scope は狭まったが、description、procedure、completion gate には二週間の履歴読書が残っていた。実際の patch はこれらをまとめて修正している。
- 失敗段階: 修正の統合、skill discovery、instruction precedence。
- 原因: 変化する要件の反映が一つの文言変更に留まり、呼び出し条件から終了条件まで同じ契約として確認されなかった。
- 修正: description、手順、completion gate、caller、generated target を一つの契約として点検する。過去の強い表現や頻度で、後の明示的な修正を上書きしない。

### 5. source・生成物・導入先・利用時の検証を取り違える

- A: 最初の offline test は正しく隔離検証と説明されていた。その後の会話は利用可能な状態を示唆したが、ユーザーの不動作報告後に初めて live paths の欠落を確認した。
- A: 実環境への sync とリンク確認後にも、利用時に missing YAML frontmatter が出た。ディレクトリ形状とリンクの検証だけで skill format が正しいと説明していた。
- B: 新規スキルの source validation で停止し、実際に表示されないとの修正後に sync した。
- 失敗段階: acceptance definition、利用先検証、終了報告。
- 原因: 検証した層より広い導入・利用可能性を結論にした。
- 修正: 検証結果はその対象層に限定する。今回の validator と sync は構造・生成結果の証拠であり、将来の agent compliance の証拠ではない。

### 6. 調査記録が新しいスコープ違反と情報汚染を作る

- B: 履歴を読む許可はあったが、raw text と引用を repo-owned artifacts に保存した。修正後に削除処理と git status 確認を行った。履歴読書の許可と保存・公開の許可は別である。
- D: 競合する current records の存在を認識した直後に、別の current document を作成した。プロセスの問題を調べる作業が product documentation の変更に移った。後の制限を遡及適用せず、要求された調査対象と実際の保存先の不一致として扱う。
- 失敗段階: 証拠保存、canonical authority、修復先選択。
- 原因: 手順を実行した証明を残すことが優先され、既存の canonical record と保存範囲が確認されなかった。
- 現在の残存欠陥: `refresh-procedure.md` は引き続き raw quotes と append-only tranche notes を要求していた。今回、neutral findings、evidence locators、canonical record、抽出物の即時削除へ変更した。

### 7. 反復条件とモデルの判定が、元の完了条件を置き換える

- H の実際の旧 council source は、二回連続の全員 clean を唯一の成功条件とし、約五回で未収束でも報告後に継続するよう要求していた。ユーザーは二回の要求をしていないと修正した。
- 同じ source は finding の棄却を別モデルの confirmer に委ね、再度指摘された finding は再棄却できないとしていた。後続の修正で、各 claim を primary artifact と実際の結果で確認する gate が追加された。
- 失敗段階: 反復制御、証拠の採用、停止条件。
- 原因: 非決定的な reviewer の出力と固定した連続回数が、要求された成果物の検証を支配していた。source に runtime proof の項目は存在したため、「証拠確認の規則が一切なかった」とは言えない。個々の claim を採用する段階の検証が不足していた。
- 修正: 今回の audit skill は continuation trigger、停止条件、各 round の実変更、再開の根拠、要求された反復回数を追跡する。現在の council は別作業で既に修正されており、今回その変更は上書きしていない。

## 呼び出し調査の補足

| 記録 | 確認した呼び出し・対象 | 判定範囲 |
| --- | --- | --- |
| Feb19 16:38 | skill-creator / skill-installer の利用宣言、Codex sync | A の構造・導入・利用層の違いを確認 |
| Feb19 22:24 | skill invocation は確認されず、commit/push の依頼列 | 当時の明示的な権限と結果を確認。新たな主要原因には採用せず |
| Mar27 14:13 / 16:25 | superpowers の読込、setup isolation の修正列 | source coupling と live apply の問題を補助確認。他プロジェクトは現在開いていない |
| Mar27 15:30 | skill-creator、Ralph skill 作成 | current-agent 対応等の修正列を読んだ。remote 成功は現在再検証していない |
| Jun18 / Jun19 | using-superpowers、skill-installer、verification-before-completion | 履歴分析・setup repair の依頼と操作列。通常の foreground 継続を誤検出から除外 |
| Jul08 | implicit GYST、pxpipe/caveman setup | proxy process と installer の失敗・修正を確認。現在の機器・system への変更権限には転用しない |
| Jul23 | skill-creator、GYST、un-dumb-yourself 作成・修正 | GYST chaining の後続修正と、実 compaction crossing が未検証との明示を確認 |
| Jul24 / Jul29 | skill-creator、GYST、un-dumb-yourself、prove-it-in-pr / handoff 作成 | source/load/action の列と明示された検証限界を確認。source の対象名と実呼出しを区別 |
| Aug04 / Aug05 | skill-creator、what-did-i-say、GYST、stop-inventing 作成 | B/C の依頼変更と操作列を直接確認 |
| Aug06 13:04 / 16:46 | GYST、skill-installer、Matt bootstrap の依頼 | 前者は過去障害の修正記録、後者は当時指定された bootstrap 導入。後日の全パッケージ要求を遡及しない |
| Aug07 / Aug17 / Aug18 | council source 修正、GYST、what-did-i-say source 修正 | D/E/H。source 編集だけではその skill の全手順を実行したとは数えない |
| Aug27 / Sep08 | GYST、what-did-i-say、skill-creator、unfuck-yourself | F/G。今回の人工シナリオは実ログ監査を代替しなかった |

## 除外した誤検出・未証明事項

- 稼働中の foreground process に対する一回の結果確認は、それだけでは polling 違反ではない。
- instruction repair で browser を使わなかったこと自体は欠陥ではない。
- catalog にある skill 名、source edit の対象名、injected metadata だけでは skill procedure の実行を証明しない。
- D の重複ファイル削除は assistant report のみで、今回確認した操作列に削除結果が見つからない。削除済みと断定しない。他プロジェクトを開いて補完していない。
- 実圧縮境界、内部 reasoning、別プロジェクトの元障害の全履歴は未確認。利用可能な記録からの推論と区別する。
- June の子監査で変化した agreement と archive metadata は、依頼された acceptance と子監査独自の条件を十分分離できず、主要な確定原因には採用しなかった。

## 今回の変更と検証境界

- `unfuck-yourself`: 実ログ優先、invocation ごとの要求・読み込み・実施・結果の連結、証拠の分類、反復する原因機構の比較、当時の権限による判定を追加。
- GYST route と core profile: full failure/process audit への経路を整合。文書整理への固定経路を除去。
- `refresh-procedure.md`: standing-demand 抽出と failure audit を区別。user-only corpus は agent behavior の証拠にならないことを明記。raw quote 保存と append-only receipt を撤去。
- 実際の Aug17 記録を使った read-only replay を実施し、親が元操作列と照合した。子出力の過剰推論は除外した。これは監査方法の確認であり、元の稼働環境の修復や将来の無再発を証明しない。
- 構造・生成物の最終検証は canonical task record に記録する。今回 commit、push、外部公開、他プロジェクト変更は行わない。
