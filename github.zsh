# ==========================
# private funtion
# ==========================
pull-remote-branch(){
  REMOTE_BRANCH_COUNT=$(git branch -r | grep $1 | wc -l)
  if [ $REMOTE_BRANCH_COUNT -ne 0 ]; then
    echo "\n\U2B07 pull ${1}"
    git pull origin $1
  fi
}

checkout-new-branch() {
  CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
  BASE_BRANCH=$(echo "master\n$CURRENT_BRANCH" | uniq | fzf --prompt="BASE BRANCH > ")
  echo "\U1F4DD write new branch name"
  read NEW
  if test "${GITHUB_BRANCH_NAME_PREFIX}" = ""; then
    echo "\e[31mif you set \$GITHUB_BRANCH_NAME_PREFIX, you can select prefix and auto set to the new branch name.\e[m"
    echo "\e[31m\$echo 'export GITHUB_BRANCH_NAME_PREFIX=\"PREFIX\"' >> ~/.zshrc\e[m"
  else
    # ブランチ名のprefixを選べる
    PREFIX=$(echo $GITHUB_BRANCH_NAME_PREFIX | sed '1s/^/'"none$LF"'/' | fzf --prompt="BRANCH NAME PREFIX > ")
    if test "${PREFIX}" = "none"; then
      PREFIX=""
    fi
  fi
  try-checkout $BASE_BRANCH
  try-pull $BASE_BRANCH
  echo "\n\U1F331 checkout ${PREFIX}${NEW}"
  git checkout -b $PREFIX$NEW
}

try-checkout(){
  echo "\n\U1F331 checkout ${1}"
  git checkout $1
}

try-pull(){
  echo "\n\U2B07 pull ${1}"
  git pull origin $1
}

get-github-token() {
  if test "${GIT_TOKEN}" = ""; then
    echo "\U1F4DD personal access token of github? (\U2714 check [repo])"
    read TOKEN
    echo "\e[31mplease add this text in .zshrc >> \"export GIT_TOKEN={personal_access_token?}\"\e[m"
    echo "\e[31mif so you can run git-open-pr without authentication\e[m"
    export GIT_TOKEN=$TOKEN
  else
    echo "success to get your github access token!!"
  fi
}

EMOJI_LIST="🐛 バグ修正 \n👍 機能改善\n✨ 部分的な機能追加\n🎉 盛大に祝うべき大きな機能追加\n♻️ リファクタリング\n\
🚿 不要な機能・使われなくなった機能の削除\n💚 テストやCIの修正・改善\n👕 Lintエラーの修正やコードスタイルの修正\n🚀 パフォーマンス改善\n\
🆙 依存パッケージなどのアップデート\n🔒 新機能の公開範囲の制限\n👮 セキュリティ関連の改善"

# ==========================
# command
# ==========================

# checkout local branch
git-che(){
  # instead \r
  LF=$'\\\x0A'
  TEXT="+ CREATE NEW BRANCH"
  BRANCH=$(git --no-pager branch -vv --sort -authordate | sed '1s/^/'"$TEXT$LF"'/' | grep -v "^*" | fzf +m --prompt="LOCAL BRANCHES > ")
  if [ $BRANCH  = $TEXT ]; then
    checkout-new-branch
  else
    BRANCH_NAME=$(echo $BRANCH | awk '{print $1}')
    try-checkout $BRANCH_NAME
    pull-remote-branch $BRANCH_NAME
  fi
}

# checkout including remote branch
git-che-remote(){
  echo "\n\U1F465 fetch"
  git fetch
  LF=$'\\\x0A'
  TEXT="+ CREATE NEW BRANCH"
  BRANCH=$(git branch -r | awk -F/ '{print $2}' | sed '1s/^/'"$TEXT$LF"'/' | fzf +m --prompt="REMOTE BRANCHES > ")
  if [ $BRANCH  = $TEXT ]; then
    checkout-new-branch
  else
    BRANCH_NAME=$(echo $BRANCH | awk '{print $1}')
    echo "\n\U1F465 fetch"
    git fetch origin $BRANCH_NAME
    try-checkout $BRANCH_NAME
  fi
}

# add and commit
git-add-cmt(){
  LF=$'\\\x0A'
  git diff --color-words
  FILES=$(git status --short | sed '1s/^/ALL .'"$LF"'/' | fzf -m --prompt="SELECT_ADD_FILES (multi:tab) > " | tr '\n' ' ')
  EMOJI=$(echo $EMOJI_LIST | fzf -m --prompt="SELECT_PREFIX_EMOJI> " | cut -d ' ' -f 1)
  echo "\U1F4DD write commit message (quit ctr+C) >"
  read MSG
  echo "\n\U1F33F add ${FILES}"
  git add $(echo $FILES | awk '{print $2}')
  echo "\n\U1F490 commit"
  git commit -m $EMOJI$MSG
}

# add and commit and push
git-add-cmt-psh(){
  git-add-cmt && git-psh
}

# add each part and commit
git-add-prt-cmt(){
  echo "\n\U1F33F add"
  git add -p
  EMOJI=$(echo $EMOJI_LIST | fzf -m --prompt="SELECT_PREFIX_EMOJI> " | cut -d ' ' -f 1)
  echo "\U1F4DD write commit message (quit ctr+C) >"
  read MSG
  echo "\n\U1F490 commit"
  git commit -m $EMOJI$MSG
}

git-ign(){
  FILE=$(git status --short | fzf --prompt="SELECT_IGNORE_FILE > ")
  FILE_NAME=$(echo $FILE | awk '{print $2}')
  git diff $FILE_NAME && echo $FILE_NAME >> .git/info/exclude
}

git-ign-ls(){
  cat .git/info/exclude
  echo "if you wanna cancel ignore-files, rewrite this file. >> .git/info/exclude"
}

# pull from base brach
git-pll(){
  LF=$'\\\x0A'
  CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
  BASE_BRANCH=$(git --no-pager reflog | awk '$3 == "checkout:"' | grep ".*to $CURRENT_BRANCH.*" | awk '{print $6}' | sed '1s/^/'"$CURRENT_BRANCH$LF"'/' | sort | uniq | fzf --prompt="BASE_BRANCH > ")
  try-pull $BASE_BRANCH
}

# push to current origin branch
git-psh(){
  BRANCH=$(git branch -vv | grep "*" | awk '{print $2}')
  echo "\n\U2B06 push ${BRANCH}"
  git push origin $BRANCH
}

# check alias for git
git-alias(){
  cat ~/.zshrc | grep "alias" | grep "git " | awk -F"alias " '{print $2}'
}

# open pull request
git-opn-pr() {
  get-github-token
  REPO_URL=$(git remote -v | awk '{print $2}' | uniq | sed -e "s/.git\$//")
  # different the way to construct url which ssh or https authentication
  if echo $REPO_URL | grep git@ ; then
    # ssh
    OWNER_AND_REPO=$(echo $REPO_URL | awk -F: '{print $2}')
    API_URL="https://api.github.com/repos/$OWNER_AND_REPO/pulls"
    echo $API_URL
    PR_NUMBER=$(curl -u :$GIT_TOKEN $API_URL | jq '.[] | .url, .head.ref' | sed -e "N;s/\n/,/g" | fzf | awk -F, '{print $1}' | awk -F/ '{print awk $NF}' | tr -d '\"')
    open -a Google\ Chrome "https://github.com/$OWNER_AND_REPO/pull/$PR_NUMBER"
  else
    # https
    API_URL=$(echo $REPO_URL | sed -e "s/github.com/api.github.com\/repos/g")
    echo $API_URL"/pull"
    PR_NUMBER=$(curl -u :$GIT_TOKEN $API_URL/pulls | jq '.[] | .url, .head.ref' | sed -e "N;s/\n/,/g" | fzf | awk -F, '{print $1}' | awk -F/ '{print awk $NF}' | tr -d '\"')
    open -a Google\ Chrome $REPO_URL"/pull/"$PR_NUMBER
  fi
}

# open pull request of current branch
git-opn-pr-crnt() {
  get-github-token
  REPO_URL=$(git remote -v | awk '{print $2}' | uniq | sed -e "s/.git\$//")
  BRANCH=$(git symbolic-ref --short HEAD)
  if echo $REPO_URL | grep git@ ; then
    open -a Google\ Chrome "https://github.com/${OWNER_AND_REPO}/pull/${BRANCH}"
  else
    open -a Google\ Chrome "${REPO_URL}/pull/${BRANCH}"
  fi
}

# help
git-help(){
  message="
    \U1F337 git-che()
    # checkout local branch
    if you select \$branch
      git checkout \$branch
    if you select + CREATE NEW BRANCH
      write \$new_branch_name
      select \$base_branch
      git checkout \$base_branch
      git pull \$base_branch
      git checkout -b \$new_branch_name

    \U1F337 git-che-remote()
    # checkout including remote branch
    git fetch
    you select \$remote_branch
    git checkout -b \$remote_branch

    \U1F337 git-add-cmt()
    # add and commit
    you select \$add_files
    git add \$add_files
    you write \$commit_msg
    git commit -m \$commit_msg

    \U1F337 git-add-cmt-psh()
    # add and commit and push
    you select \$add_files
    git add \$add_files
    you write \$commit_msg
    git commit -m \$commit_msg
    git push origin current_branch

    \U1F337 git-add-prt-cmt()
    # add each part and commit
    git add -p
    you write \$commit_msg
    git commit -m \$commit_msg

    \U1F337 git-pll()
    # pull from base brach
    you select \$base_branch
    git pull origin \$base_branch

    \U1F337 git-psh()
    # push to current origin branch
    git push origin current_branch

    \U1F337 git-alias()
    # check alias for git

    \U1F337 git-opn-pr()
    # open pull request
    you select \$branch
    you can see \$branch's PR

    \U1F337 git-opn-pr-crnt()
    # open pull request of current branch
    you can see current branch's PR
  "
  echo $message
}
