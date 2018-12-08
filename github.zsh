# test

# checkout local
git-che(){
  # instead \r
  LF=$'\\\x0A'
  TEXT="+ CREATE NEW BRANCH"
  BRANCH=$(git branch -vv | sed '1s/^/'"$TEXT$LF"'/' | grep -v "^*" | fzf +m --prompt="LOCAL_BRANCHES > ")
  if [ $BRANCH  = $TEXT ]; then
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
    BASE_BRANCH=$(echo "develop\nmaster\n$CURRENT_BRANCH" | uniq | fzf --prompt="BASE_BRANCH > ")
    echo "\U1F4DD  new branch name?"
    read NEW
    echo "\U1F331 ---------------> checkout $BASE_BRANCH" && \ 
      git checkout $BASE_BRANCH && \
      echo "\U1F331 ----------------------------> pull $BASE_BRANCH" && \
      git pull origin $BASE_BRANCH && \
      echo "\U1F337 ---------------------------------------> checkout new branch" && \
      git checkout -b $NEW
  else
    BRANCH_NAME=$(echo $BRANCH | awk '{print $1}')
    REMOTE_BRANCH_COUNT=$(git branch -r | grep $BRANCH_NAME | wc -l)
    if [ $REMOTE_BRANCH_COUNT -eq 0 ]; then
      git checkout $BRANCH_NAME && \
        echo "\U1F337 ---------------------------------------> complite checkout"
    else
      git checkout $BRANCH_NAME && \
        echo "\U1F337 ---------------------------------------> complite checkout"
      git pull origin $BRANCH_NAME && \
        echo "\U1F337 ---------------------------------------> complite pull"
    fi
  fi
}

# checkout including remote branches
git-che-remote(){
  echo "\U1F34E git fetch"
  git fetch
  BRANCH=$(git branch -a | grep remotes/origin/SBATS | awk -F/ '{print $3}' | fzf +m --prompt="BRANCHES > ")
  echo "\U1F34E git checkout"
  git checkout -b $BRANCH origin/$BRANCH
}

# add and commit
git-add-cmt(){
  LF=$'\\\x0A'
  git diff --color-words  
  FILES=$(git status --short | sed '1s/^/ALL .'"$LF"'/' | fzf -m --prompt="SELECT_ADD_FILES (multi:tab) > " | tr '\n' ' ') 
  echo "\U1F4DD commit message? > "
  read MSG
  git add $(echo $FILES | awk '{print $2}') && \
    echo $FILES && \
    echo "\U1F374 ------------------> complite add" && \
    git commit -m $MSG && \
    echo "\U1F35D --------------------------------------->  complite commit"
}

# add each part and commit
git-add-cmt-part(){
  git add -p && \
  echo "\U1F374 ------------------> complite add"
  echo "\U1F4DD commit message? > "
  read MSG
  git commit -m $MSG && \
  echo "\U1F35D ---------------------------------------> complite commit"
}

# add and commit with jira number
git-add-cmt-with-jira-num(){
  LF=$'\\\x0A'
  FILES=$(git status --short | sed '1s/^/ALL .'"$LF"'/' | fzf -m --prompt="SELECT_ADD_FILES (multi:tab) > ")
  git add $(echo $FILES | awk '{print $2}')
  echo $FILES
  echo "\U1F374 ------------------> complite add"
  JIRA_NO=$(git symbolic-ref --short HEAD | sed -e "s/\(SBATS-[0-9]*\).*/\1/g") && \
    echo "\U1F4DD commit message after "$JIRA_NO"? > "
  read MSG
  git commit -m $JIRA_NO" "$MSG && \
    echo "\U1F35D ---------------------------------------> complite commit"
}

# add each part and commit with jira number
git-add-cmt-part-with-jira-number(){
  git add -p && \
    echo "\U1F374 ------------------> complite add"
  echo "\U1F4DD commit message? > "
  read MSG
  JIRA_NO=$(git symbolic-ref --short HEAD | sed -e "s/\(SBATS-[0-9]*\).*/\1/g") && \
    git commit -m $JIRA_NO" "$MSG && \
  echo "\U1F35D ---------------------------------------> complite commit"
}

# pull from base brach
git-pll(){
  LF=$'\\\x0A'
  CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
  BASE_BRANCH=$(git --no-pager reflog | awk '$3 == "checkout:"' | grep ".*to $CURRENT_BRANCH.*" | awk '{print $6}' | sed '1s/^/'"$CURRENT_BRANCH$LF"'/' | sort | uniq | fzf --prompt="BASE_BRANCH > ")
  echo "\U1F31F ---------------------------------------> pull origin/"$BASE_BRANCH"..."
  git pull origin $BASE_BRANCH
}

# push
git-psh(){
  BRANCH=$(git branch -vv | grep "*" | awk '{print $2}')
  echo "\U2728 ---------------------------------------> push origin/"$BRANCH"..." 
  git push origin $BRANCH
}

# check alias for git
git-alias(){
  cat ~/.zshrc | grep "alias" | grep "git " | awk -F"alias " '{print $2}'
} 

# check emoji unicode
emoji-uni(){
  cat emoji-unicode | fzf -m
}

# open pull request
git-opn-pr() {
  get-github-token
  REPO_URL=$(git remote -v | awk '{print $2}' | uniq | sed -e "s/.git\$//")
  # different the way to construct url which ssh or https authentication
  SSH_COUNT=$(echo $REPO_URL | grep git@ | grep -c '')
  echo $SSH_COUNT
  if [ $SSH_COUNT -eq 1 ] ; then
    echo "you use ssh auth"
    OWNER_AND_REPO=$(echo $REPO_URL | awk -F: '{print $2}')
    API_URL="https://api.github.com/repos/$OWNER_AND_REPO/pulls"
    echo $API_URL
    PR_NUMBER=$(curl -u :$GIT_TOKEN $API_URL | jq '.[] | .url, .head.ref' | sed -e "N;s/\n/,/g" | fzf | awk -F, '{print $1}' | awk -F/ '{print awk $NF}' | tr -d '\"')
    open -a Google\ Chrome "https://github.com/$OWNER_AND_REPO/pull/$PR_NUMBER"
  else
    echo "you use https auth"
    API_URL=$(echo $REPO_URL | sed -e "s/github.com/api.github.com\/repos/g")
    echo $API_URL"/pull"
    PR_NUMBER=$(curl -u :$GIT_TOKEN $API_URL/pulls | jq '.[] | .url, .head.ref' | sed -e "N;s/\n/,/g" | fzf | awk -F, '{print $1}' | awk -F/ '{print awk $NF}' | tr -d '\"')
    open -a Google\ Chrome $REPO_URL"/pull/"$PR_NUMBER
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

git-opn-pr-crnt() {
  get-github-token
  REPO_URL=$(git remote -v | awk '{print $2}' | uniq | sed -e "s/.git\$//")
  OWNER=$(echo $REPO_URL | awk -F/ '{print $4}')
  API_URL=$(echo $REPO_URL | sed -e "s/github.com/api.github.com\/repos/g")
  BRANCH=$(git symbolic-ref --short HEAD)
  ASSEMBLED_URL="${API_URL}/pulls?head=label:${OWNER}:${BRANCH}"
  PR_NUMBER=$(curl -u :$GIT_TOKEN $ASSEMBLED_URL | jq '.[] | .url, .head.ref' | sed -e "N;s/\n/,/g" | awk -F, '{print $1}' | awk -F/ '{print awk $NF}' | tr -d '\"')
  open -a Google\ Chrome $REPO_URL"/pull/"$PR_NUMBER
}
