PROMPT="%{$fg[cyan]%}%~%{$reset_color%}"
PROMPT+=" $(adam_git_status)
%(?:%{$fg_bold[green]%}%1{%} :%{$fg_bold[red]%}%1{%} )"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}[%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}] %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}]"
ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_DETAILED=1

ZSH_THEME_GIT_PROMPT_AHEAD=""
ZSH_THEME_GIT_PROMPT_BEHIND=""

adam_git_status() {
  local gitstatus
  gitstatus="$(command git status --porcelain -b 2> /dev/null)"

  local gitfiles
  gitfiles="$(tail -n +2 <<< "$gitstatus")"

  local branch remote added removed modified untracked ahead behind
  ahead=0
  behind=0
  if [[ "$gitstatus" =~ "^## ([^ ]+)(\.\.\.([^ ]+)?) \[(.*)\]" ]]; then
    branch=$match[1]
    remote=$match[3]

    local remote_statuses
    remote_statuses=("${(@s/,/)match[4]}")
    for remote_status in $remote_statuses; do
      if [[ $remote_status =~ "ahead ([0-9]+)?" ]]; then
        ahead=$match[1]
        continue
      fi
      if [[ $remote_status =~ "behind ([0-9]+)?" ]]; then
        behind=$match[1]
        continue
      fi
    done
  fi

  local remote_prompt
  if [[ -n $remote ]]; then
    remote_prompt=' '
    if [[ $ahead -eq 0 ]] && [[ $behind -eq 0 ]]; then
      remote_prompt+=''
      break
    fi

    if [[ $ahead -gt 0 ]]; then
      remote_prompt+="$fg[green]$ZSH_THEME_GIT_PROMPT_AHEAD$ahead"
    fi

    if [[ $behind -gt 0 ]]; then
      if [[ $remote_prompt -ne ' ' ]]; then
        remote_prompt+=' '
      fi
      remote_prompt+="$fg[red]$ZSH_THEME_GIT_PROMPT_BEHIND$behind"
    fi
  fi

  echo "%B$FG[240][%b$FG[123] $fg_bold[blue]$branch$reset_color$remote_prompt%B$FG[240]]%b$reset_color "
}
