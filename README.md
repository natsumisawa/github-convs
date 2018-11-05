# github-convs
github便利コマンド集

# Usage
Add line when you use zplug
```.zshrc
zplug "natsumisawa/github-convs"
```

zshじゃなくても使えるよ
簡単に使うなら、cloneしたものをログインシェルでsourceされるように書くとか、cloneしてきてそのファイルsourceしてみて使ってみるとか

## ノンコアステップ
- 作業ブランチからベースブランチにチェックアウト
- 最新をpull
- 新しいブランチを作成

👇
-  git-ch()を打って選択するだけ！

## git-che()
- 📝 select branch
- git checkout branch

- 📝 checkout new branch
- 📝 write new branch name
- 📝 select base branch
- git checkout base branch
- git pull base branch
- git checkout -b new branch

## git-che-remote()
- git fetch
- 📝 select remote branch
- git checkout -b remote branch

## git-add-cmt()
- 📝 select add files
- git add select files
- 📝 write commit msg
- git commit -m "msg"

## git-add-cmt-part()
- git add -p
- 📝 write commit msg
- git commit -m "msg"

## git-add-cmt-with-jira-num()
- 📝 select add files
- git add select files
- 📝 write commit msg
- git commit -m SBATS-XXXX"msg"

## git-add-cmt-part-with-jira-number()
- git-add-cmt-part() + git-add-cmt-with-jira-num()

## git-pll()

## git-psh()

## git-alias()

## git-opn-pr()

## git-opn-pr-crnt()
