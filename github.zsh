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
    echo "\U1F331 ---------------> checkout $BASE_BRANCH" && git checkout $BASE_BRANCH && \
        echo "\U1F331 ----------------------------> pull $BASE_BRANCH" && git pull origin $BASE_BRANCH && \
	echo "\U1F337 ---------------------------------------> checkout new branch" && git checkout -b $NEW
  else
    BRANCH_NAME=$(echo $BRANCH | awk '{print $1}')
    echo "\U1F337 ---------------------------------------> checkout & pull" && git checkout $BRANCH_NAME && git pull origin $BRANCH_NAME
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
  git add $(echo $FILES | awk '{print $2}') && echo $FILES && \
    echo "\U1F374 ------------------> add" && \
    echo "\U1F35D ---------------------------------------> commit" && git commit -m $MSG
}

# add each part and commit
git-add-cmt-part(){
  git add -p && \
  echo "\U1F374 ------------------> add"
  echo "\U1F4DD commit message? > "
  read MSG
  git commit -m $MSG && \
  echo "\U1F35D ---------------------------------------> commit"
}

# add commit for hrmos
git-add-cmt-hrmos(){
  LF=$'\\\x0A'
  FILES=$(git status --short | sed '1s/^/ALL .'"$LF"'/' | fzf -m --prompt="SELECT_ADD_FILES (multi:tab) > ")
  git add $(echo $FILES | awk '{print $2}')
  echo "\U1F374 ------------------> add"
  echo $FILES
  JIRA_NO=$(git symbolic-ref --short HEAD | sed -e "s/\(SBATS-[0-9]*\).*/\1/g")
  git diff --cached | grep -e '^+' -e '^-' && \
  echo "\U1F4DD commit message after "$JIRA_NO"? > "
  read MSG
  echo "\U1F35D ---------------------------------------> commit"
  git commit -m $JIRA_NO" "$MSG
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
  API_URL=$(echo $REPO_URL | sed -e "s/github.com/api.github.com\/repos/g")
  PR_NUMBER=$(curl -u :$GIT_TOKEN $API_URL/pulls | jq '.[] | .url, .head.ref' | sed -e "N;s/\n/,/g" | fzf | awk -F, '{print $1}' | awk -F/ '{print awk $NF}' | tr -d '\"')
  open -a Google\ Chrome $REPO_URL"/pull/"$PR_NUMBER
}

get-github-token() {
  if test "${GIT_TOKEN}" = ""; then
    echo "\U1F4DD personal access token of github? (\U2714 check [repo])"
    read TOKEN
    echo -e "\e[31mplease add this text in .zshrc >> \"export GITHUB_TOKEN={personal_access_token?}\"\e[m"
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
