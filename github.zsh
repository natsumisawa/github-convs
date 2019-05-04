# checkout local branch
git-che(){
  # instead \r
  LF=$'\\\x0A'
  TEXT="+ CREATE NEW BRANCH"
  BRANCH=$(git --no-pager branch -vv --sort -authordate | sed '1s/^/'"$TEXT$LF"'/' | grep -v "^*" | fzf +m --prompt="LOCAL_BRANCHES > ")
  if [ $BRANCH  = $TEXT ]; then
    checkout-new-branch
  else
    BRANCH_NAME=$(echo $BRANCH | awk '{print $1}')
    git checkout $BRANCH_NAME && \
      echo ":::::::::::::::: checkout\U1F337 ::::::::::::::::"
    pull-remote-branch $BRANCH_NAME
  fi
}

pull-remote-branch(){
  REMOTE_BRANCH_COUNT=$(git branch -r | grep $1 | wc -l)
  if [ $REMOTE_BRANCH_COUNT -ne 0 ]; then
    git pull origin $BRANCH_NAME && \
      echo ":::::::::::::::: pull\U1F337 ::::::::::::::::"
  fi
}

checkout-new-branch() {
  CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
  BASE_BRANCH=$(echo "master\n$CURRENT_BRANCH" | uniq | fzf --prompt="BASE_BRANCH > ")
  echo "\U1F4DD write new branch name"
  read NEW
  echo ":::::::::::::::: checkout\U1F331 ::::::::::::::::" && \
    git checkout $BASE_BRANCH && \
    echo "::::::::::::::::   pull\U1F331   ::::::::::::::::" && \
    git pull origin $BASE_BRANCH && \
    echo ":::::::::::::::: checkout\U1F337 ::::::::::::::::" && \
    git checkout -b $NEW
}

# checkout including remote branch
git-che-remote(){
  echo "::::::::::::::::  fetch\U1F34E  ::::::::::::::::"
  git fetch
  BRANCH=$(git branch -r | awk -F/ '{print $2}' | fzf +m --prompt="BRANCHES > ")
  echo ":::::::::::::::: checkout\U1F337 ::::::::::::::::"
  git checkout -b $BRANCH origin/$BRANCH || git checkout $BRANCH
}

EMOJI_LIST="🐛 バグ修正 \n👍 機能改善\n✨ 部分的な機能追加\n🎉 盛大に祝うべき大きな機能追加\n♻️ リファクタリング\n\
🚿 不要な機能・使われなくなった機能の削除\n💚 テストやCIの修正・改善\n👕 Lintエラーの修正やコードスタイルの修正\n🚀 パフォーマンス改善\n\
🆙 依存パッケージなどのアップデート\n🔒 新機能の公開範囲の制限\n👮 セキュリティ関連の改善"

# add and commit
git-add-cmt(){
  LF=$'\\\x0A'
  git diff --color-words
  FILES=$(git status --short | sed '1s/^/ALL .'"$LF"'/' | fzf -m --prompt="SELECT_ADD_FILES (multi:tab) > " | tr '\n' ' ')
  EMOJI=$(echo $EMOJI_LIST | fzf -m --prompt="SELECT_COMMIT_MSG_ EMOJI> " | cut -d ' ' -f 1)
  echo "\U1F4DD write commit message (quit ctr+C) >"
  read MSG
  git add $(echo $FILES | awk '{print $2}') && \
    echo $FILES && \
    echo "::::::::::::::::  add\U1F374  ::::::::::::::::" && \
    git commit -m $EMOJI$MSG && \
    echo ":::::::::::::::: commit\U1F35D ::::::::::::::::"
}

# add each part and commit
git-add-prt-cmt(){
  git add -p && \
  echo "::::::::::::::::  add\U1F374  ::::::::::::::::"
  EMOJI=$(echo $EMOJI_LIST | fzf -m --prompt="SELECT_COMMIT_MSG_ EMOJI> " | cut -d ' ' -f 1)
  echo "\U1F4DD write commit message (quit ctr+C) >"
  read MSG
  git commit -m $EMOJI$MSG && \
  echo ":::::::::::::::: commit\U1F35D ::::::::::::::::"
}

# pull from base brach
git-pll(){
  LF=$'\\\x0A'
  CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
  BASE_BRANCH=$(git --no-pager reflog | awk '$3 == "checkout:"' | grep ".*to $CURRENT_BRANCH.*" | awk '{print $6}' | sed '1s/^/'"$CURRENT_BRANCH$LF"'/' | sort | uniq | fzf --prompt="BASE_BRANCH > ")
  echo ":::::::::::::::: pull\U1F31F ::::::::::::::::"
  git pull origin $BASE_BRANCH
}

# push to current origin branch
# push to current origin branch
git-psh(){
  BRANCH=$(git branch -vv | grep "*" | awk '{print $2}')
  echo ":::::::::::::::: push\U2728 ::::::::::::::::"
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

get-github-token() {
  if test "${GIT_TOKEN}" = ""; then
    echo "\U1F4DD personal access token of github? (\U2714 check [repo])"
    read TOKEN
    echo -e "\e[31mplease add this text in .zshrc >> \"export GIT_TOKEN={personal_access_token?}\"\e[m"
    echo -e "\e[31mif so you can run git-open-pr without authentication\e[m"
    export GIT_TOKEN=$TOKEN
  else
    echo "success to get your github access token!!"
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

    \U1F337 git-add-prt-cmt()
    # add each part and commit
    git add -p
    you write \$commit_msg
    git commit -m \$commit_msg

    \U1F337 git-add-cmt-w-jira-num()
    # add and commit with jira number
    you select \$add_files
    git add \$add_files
    you write \$commit_msg
    git commit -m "SBAST-XXXX\$commit_msg"

    \U1F337 git-add-prt-cmt-w-jira-num()
    # add each part and commit with jira number
    git add -p
    you write \$commit_msg
    git commit -m  \"SBAST-XXXX\$commit_msg\"

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
