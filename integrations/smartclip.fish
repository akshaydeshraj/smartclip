# smartclip — fish integration
# Add to ~/.config/fish/config.fish: source /path/to/integrations/smartclip.fish

function _smartclip_paste
    set -l content (fish_clipboard_paste)
    if string match -q '*\n*' -- "$content"
        set -l fixed (printf '%s' "$content" | smartclip 2>/dev/null)
        if test $status -eq 0
            commandline -i -- "$fixed"
            return
        end
    end
    commandline -i -- "$content"
end

bind \cv _smartclip_paste
