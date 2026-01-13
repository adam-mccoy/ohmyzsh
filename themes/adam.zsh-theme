ZSH_THEME_GIT_PROMPT_EQUAL=""
ZSH_THEME_GIT_PROMPT_AHEAD=""
ZSH_THEME_GIT_PROMPT_BEHIND=""

adam_git_status() {
  local gitstatus
  gitstatus="$(command git status --porcelain -b 2> /dev/null)"

  if [[ $? -eq 128 ]]; then
    return 1
  fi

  local statuslines
  statuslines=("${(@f)${gitstatus}}")

  local branch remote ahead behind
  ahead=0
  behind=0
  if [[ "$statuslines[1]" =~ "^## ([^ .]+)(\.\.\.([^ ]+))?( \[(.*)\])?$" ]]; then
    branch=$match[1]
    remote=$match[3]

    local remote_statuses
    remote_statuses=("${(@s/,/)match[5]}")
    for remote_status in $remote_statuses; do
      if [[ $remote_status =~ "ahead ([0-9]+)" ]]; then
        ahead=$match[1]
        continue
      fi
      if [[ $remote_status =~ "behind ([0-9]+)" ]]; then
        behind=$match[1]
        continue
      fi
    done
  fi

  local remote_prompt
  if [[ -n $remote ]]; then
    local remote_status
    if [[ $ahead -eq 0 ]] && [[ $behind -eq 0 ]]; then
      remote_status="$fg_bold[blue]$ZSH_THEME_GIT_PROMPT_EQUAL"
    fi

    if [[ $ahead -gt 0 ]]; then
      remote_status="$fg[green]$ZSH_THEME_GIT_PROMPT_AHEAD$ahead"
    fi

    if [[ $behind -gt 0 ]]; then
      remote_status="${remote_status}${remote_status:+ }$fg[red]$ZSH_THEME_GIT_PROMPT_BEHIND$behind"
    fi
    remote_prompt=" $remote_status"
  fi

  local branch_status_prompt i_a i_m i_r w_a w_m w_r
  for line in "${statuslines[2,-1]}"; do
    if [[ $line =~ "^\?\?" ]]; then
      ((w_a++))
      continue
    fi
    if [[ $line =~ "^A." ]]; then
      ((i_a++))
    fi
    if [[ $line =~ "^M." ]]; then
      ((i_m++))
    fi
    if [[ $line =~ "^.M" ]]; then
      ((w_m++))
    fi
    if [[ $line =~ "^D." ]]; then
      ((i_r++))
    fi
    if [[ $line =~ "^.D" ]]; then
      ((w_r++))
    fi
  done

  if [[ $((i_a+i_m+i_r)) -gt 0 ]]; then
    local index_status
    if [[ $i_a -gt 0 ]]; then
      index_status="+$i_a"
    fi
    if [[ $i_m -gt 0 ]]; then
      index_status="${index_status}${index_status:+ }~$i_m"
    fi
    if [[ $i_r -gt 0 ]]; then
      index_status="${index_status}${index_status:+ }$i_r"
    fi
    branch_status_prompt=" $fg[green]$index_status$reset_color"
  fi

  if [[ $((w_a+w_m+w_r)) -gt 0 ]]; then
    local wc_status
    if [[ $w_a -gt 0 ]]; then
      wc_status="+$w_a"
    fi
    if [[ $w_m -gt 0 ]]; then
      wc_status="${wc_status}${wc_status:+ }~$w_m"
    fi
    if [[ $w_r -gt 0 ]]; then
      wc_status="${wc_status}${wc_status:+ }$w_r"
    fi
    branch_status_prompt="${branch_status_prompt} %{%B%F{240}%}${branch_status_prompt:+| }%{$reset_color%}$fg[red]$wc_status$reset_color"
  fi

  echo "%{%B%F{240}%}[%{%b%F{123}%} %{$fg_bold[blue]%}$branch%{$reset_color%}$remote_prompt$branch_status_prompt%B%F{240}]%b%{$reset_color%} "
}

PROMPT="%{$fg[cyan]%}%~%{$reset_color%} "
PROMPT+='$(adam_git_status)'
PROMPT+="
%(?:%{%B%F{240}%}%1{%} :%{$fg_bold[red]%}%1{%} )"

