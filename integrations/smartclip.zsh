# smartclip — zsh integration
# Add to ~/.zshrc: source /path/to/integrations/smartclip.zsh
# Overrides bracketed-paste so Cmd+V auto-fixes multi-line shell commands

smartclip-paste() {
  local before=$#LBUFFER
  zle .bracketed-paste
  local pasted="${LBUFFER:$before}"
  if [[ "$pasted" == *$'\n'* ]]; then
    local fixed
    fixed="$(printf '%s' "$pasted" | smartclip 2>/dev/null)"
    if (( $? == 0 )) && [[ "$fixed" != "$pasted" ]]; then
      LBUFFER="${LBUFFER:0:$before}${fixed}"
      zle -M "smartclip: fixed"
    fi
  fi
}
zle -N bracketed-paste smartclip-paste
