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

## git-ch()
- 📝 select branch
- git checkout branch

- 📝 checkout new branch
- 📝 write new branch name
- 📝 select base branch
- git checkout base branch
- git pull base branch
- git checkout -b new branch

## git-ch-remote()
- git fetch
- 📝 select remote branch
- git checkout -b remote branch

## git-ad-cm()
- 📝 select add files
- git add select files
- 📝 write commit msg
- git commit -m "msg"


## git-ad-cm-hrmos()
- 📝 select add files
- git add select files
- 📝 write commit msg
- git commit -m SBATS-XXXX"msg"

## git-pl()

## git-psh()

## git-alias()

## git-open-pr()

## git-open-pr-current-branch()
