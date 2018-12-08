## WHAT'S github-convs
ストレスフリーなgithub使いになれるコマンドだよ。

`git checkout xx and git pull origin xx and git checkout -b new and ... `
is concore!!

## USAGE
Add line when you use zplug
```.zshrc
zplug "natsumisawa/github-convs"
```

if you don't use zplug, clone this repo and source github.zsh

its better write that source command to login shell for example .zshrc

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
