## WHAT'S github-convs
https://user-images.githubusercontent.com/21053284/50346232-11d51300-0575-11e9-9e13-7098c23289b3.gif

## USAGE
### setup
以下を事前にinstallする必要があります。

fzf: https://github.com/junegunn/fzf

Symbola: https://qiita.com/nyango/items/671a14ae2834c045fe27

#### zplugを使っている場合
```.zshrc
zplug "natsumisawa/github-convs"
```
#### 使っていない場合
```
source ~/your-path/github.zsh
```
## COMMANDS
`git-help`👍

🌷 git-che()
チェックアウト時にmasterに戻ってpullして新しいブランチを切って〜という手間を省けます。pullし忘れとか変なブランチから切っちゃった！とか無くなります。

🌷 git-che-remote()
リモートバージョン

🌷 git-add-cmt()

🌷 git-add-prt-cmt()
git add -pバージョン
部分ごとに確認してcommitできます。

🌷 git-pll()
pullすべき
# pull from base brach
you select $base_branch
git pull origin $base_branch

🌷 git-psh()
# push to current origin branch
git push origin current_branch

🌷 git-alias()
# check alias for git

🌷 git-opn-pr()
# open pull request
you select $branch
you can see $branch's PR

🌷 git-opn-pr-crnt()
# open pull request of current branch
you can see current branch's PR

