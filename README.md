## こんな感じで動きます
https://user-images.githubusercontent.com/21053284/50346232-11d51300-0575-11e9-9e13-7098c23289b3.gif

## 使い方
以下を事前にinstallする必要があります。

fzf: https://github.com/junegunn/fzf

Symbola: https://qiita.com/nyango/items/671a14ae2834c045fe27

#### zplugを使っている場合
```.zshrc
zplug "natsumisawa/github-convs"
```
#### 使っていない場合
```
$ git clone https://github.com/natsumisawa/github-convs
$ source ~/your-path/github.zsh
```

## COMMANDS
`git-help`👍

🌷 git-che()
チェックアウト時にmasterに戻ってpullして新しいブランチを切って〜とかを全部やってくれます。pullし忘れとか変なブランチから切っちゃった！とか無くなります。

🌷 git-che-remote()
リモートバージョン

🌷 git-add-cmt()
変更ファイルを選ぶだけで、addしてcommitを自動でやってくれます。プレフィックス絵文字も選べます。

🌷 git-add-prt-cmt()
git add -pバージョン
部分ごとに確認してcommitできます。

🌷 git-pll()
pullすべきブランチの一覧から選んでpullできます。変なブランチからpullしちゃった！という事故が防げます。

🌷 git-psh()
現在のブランチにpushできます。

🌷 git-opn-pr()
PR一覧から見たいPRを選択、ChromeでPRが開けます。

🌷 git-opn-pr-crnt()
現在のブランチのPRをこのコマンド一発で開けます。PRを開く手間を省けます。めっちゃ便利じゃない？
