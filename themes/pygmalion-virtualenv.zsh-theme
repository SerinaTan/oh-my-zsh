# Yay! High voltage and arrows!


function _virtualenv_prompt_info {
    if [[ -n "$(whence virtualenv_prompt_info)" ]]; then
        if [ -n "$(whence pyenv_prompt_info)" ]; then
            if [ "$1" = "inline" ]; then
                ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX=%{$fg[blue]%}"::%{$fg[red]%}"
                ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX=""
                virtualenv_prompt_info
            fi
            [ "$(pyenv_prompt_info)" = "${PYENV_PROMPT_DEFAULT_VERSION}" ] && virtualenv_prompt_info
        else
            virtualenv_prompt_info
        fi
    fi
}

prompt_setup_pygmalion(){
#  ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}"
#  ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
#  ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}%{$reset_color%}"
#  ZSH_THEME_GIT_PROMPT_CLEAN=""

  base_prompt='$(_virtualenv_prompt_info)%{$fg[magenta]%}%n%{$reset_color%}%{$fg[cyan]%}@%{$reset_color%}%{$fg[yellow]%}%m%{$reset_color%}%{$fg[red]%}:%{$reset_color%}%{$fg[cyan]%}%0~%{$reset_color%}%{$fg[red]%}|%{$reset_color%}'
  post_prompt='%{$fg[cyan]%}⇒%{$reset_color%}  '

  base_prompt_nocolor=$(echo "$base_prompt" | perl -pe "s/%\{[^}]+\}//g")
  post_prompt_nocolor=$(echo "$post_prompt" | perl -pe "s/%\{[^}]+\}//g")

  precmd_functions+=(prompt_pygmalion_precmd)
}

git_info() {

# Exit if not inside a Git repository
  ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return

# Git branch/tag, or name-rev if on detached head
    local GIT_LOCATION=${$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD)#(refs/heads/|tags/)}

  local AHEAD="%{$fg[red]%}⇡NUM%{$reset_color%}"
    local BEHIND="%{$fg[cyan]%}⇣NUM%{$reset_color%}"
    local MERGING="%{$fg[magenta]%}⚡︎%{$reset_color%}"
    local UNTRACKED="%{$fg[red]%}●%{$reset_color%}"
    local MODIFIED="%{$fg[yellow]%}●%{$reset_color%}"
    local STAGED="%{$fg[green]%}●%{$reset_color%}"

    local -a DIVERGENCES
    local -a FLAGS

    local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_AHEAD" -gt 0 ]; then
      DIVERGENCES+=( "${AHEAD//NUM/$NUM_AHEAD}" )
        fi

        local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
        if [ "$NUM_BEHIND" -gt 0 ]; then
          DIVERGENCES+=( "${BEHIND//NUM/$NUM_BEHIND}" )
            fi

            local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
            if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
              FLAGS+=( "$MERGING" )
                fi

                if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
                  FLAGS+=( "$UNTRACKED" )
                    fi

                    if ! git diff --quiet 2> /dev/null; then
                      FLAGS+=( "$MODIFIED" )
                        fi

                        if ! git diff --cached --quiet 2> /dev/null; then
                          FLAGS+=( "$STAGED" )
                            fi

                            local -a GIT_INFO
                            GIT_INFO+=( "\033[38;5;15m±" )
                            [ -n "$GIT_STATUS" ] && GIT_INFO+=( "$GIT_STATUS" )
                            [[ ${#DIVERGENCES[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)DIVERGENCES}" )
                              [[ ${#FLAGS[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)FLAGS}" )
                                GIT_INFO+=( "\033[38;5;15m$GIT_LOCATION%{$reset_color%}" )
                                  echo "${(j: :)GIT_INFO}"

}


prompt_pygmalion_precmd(){
  local gitinfo=$(git_info)
  local gitinfo_nocolor=$(echo "$gitinfo" | perl -pe "s/%\{[^}]+\}//g")
  local exp_nocolor="$(print -P \"$base_prompt_nocolor$gitinfo_nocolor$post_prompt_nocolor\")"
  local prompt_length=${#exp_nocolor}

  local nl=""

  if [[ $prompt_length -gt 40 ]]; then
    nl=$'\n%{\r%}';
  fi
  PROMPT="$base_prompt$gitinfo$nl$post_prompt"
}

prompt_setup_pygmalion


