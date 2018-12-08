## WHAT'S github-convs
ストレスフリーなgithub使いになれるコマンドだよ。

`git checkout xx and git pull origin xx and git checkout -b new and ... `
ってとってもノンコア。

## USAGE
zplugをお使いの方は、こちらを追記ください。
```.zshrc
zplug "natsumisawa/github-convs"
```
※ちょくちょくメンテしているので定期的なzplugのupdate希望

zplugを使っていない方は、このレポジトリをcloneして、
`source github.zsh`
でgithub-convsのコマンドが使えるようになります。
.bashrcなり.zshrcなり、ログインシェルに `source ?/github.zsh` をかいておくと便利。

※この方法だとupdate情報は追随できない

※定期的なpull希望

## COMMAND
### git-che()
- 📝 select branch
- git checkout branch

- 📝 checkout new branch
- 📝 write new branch name
- 📝 select base branch
- git checkout base branch
- git pull base branch
- git checkout -b new branch

### git-che-remote()
- git fetch
- 📝 select remote branch
- git checkout -b remote branch

### git-add-cmt()
- 📝 select add files
- git add select files
- 📝 write commit msg
- git commit -m "msg"

### git-add-cmt-part()
- git add -p
- 📝 write commit msg
- git commit -m "msg"

### git-add-cmt-with-jira-num()
- 📝 select add files
- git add select files
- 📝 write commit msg
- git commit -m SBATS-XXXX"msg"

### git-add-cmt-part-with-jira-number()
- git-add-cmt-part() + git-add-cmt-with-jira-num()

### git-pll()

### git-psh()

### git-alias()

### git-opn-pr()

### git-opn-pr-crnt()
