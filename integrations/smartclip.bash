# smartclip — bash integration
# Add to ~/.bashrc: source /path/to/integrations/smartclip.bash
# Overrides bracketed-paste so Ctrl+Shift+V / paste auto-fixes multi-line shell commands

_smartclip_paste() {
  local content=""
  local char
  # Read until bracketed paste end sequence \e[201~
  while IFS= read -r -n 1 -t 1 char; do
    # Detect end of bracketed paste (simplified — read until timeout)
    content+="$char"
  done
  # Check for multi-line
  if [[ "$content" == *$'\n'* ]]; then
    local fixed
    fixed="$(printf '%s' "$content" | smartclip 2>/dev/null)"
    if [[ $? -eq 0 ]]; then
      content="$fixed"
    fi
  fi
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}${content}${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#content} ))
}

if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
  bind -x '"\e[200~": _smartclip_paste'
fi
