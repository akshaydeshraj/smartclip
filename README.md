# smartclip

Fix multi-line shell commands before they hit your terminal.

Copy a command from Stack Overflow, Claude, ChatGPT, or a README — paste it with Cmd+V — and smartclip silently joins the lines, strips prompt characters, and validates the syntax. No daemon, no polling, no background process. It hooks into your shell's paste mechanism and runs only when you paste.

## The problem

You copy this from a tutorial:

```
$ curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}' \
  https://api.example.com/endpoint
```

You paste it into your terminal and get:

```
zsh: command not found: -X
zsh: command not found: -H
```

smartclip fixes it before the shell sees it:

```
curl -X POST -H "Content-Type: application/json" -d '{"key": "value"}' https://api.example.com/endpoint
```

## What it fixes

| Pattern | Before | After |
|---------|--------|-------|
| Backslash continuations | `cmd \`<br>`  --flag` | `cmd --flag` |
| Pipe continuations | `cat file \|`<br>`  grep err` | `cat file \| grep err` |
| Operator continuations | `cmd1 &&`<br>`cmd2` | `cmd1 && cmd2` |
| Prompt prefixes | `$ git add .`<br>`$ git push` | `git add .; git push` |
| Indented arguments | `sudo cat`<br>`  /long/path` | `sudo cat /long/path` |
| Separate commands | `cd /tmp`<br>`git clone url`<br>`cd repo` | `cd /tmp; git clone url; cd repo` |
| Heredocs | Preserved as-is with newlines | |

## What it ignores

Prose, JSON, YAML, URL lists, and anything that doesn't look like a shell command. Detection uses a scoring heuristic — if confidence is low, your clipboard is untouched. Every fix is validated with `bash -n` before insertion; if the result has invalid syntax, the original is pasted unchanged.

## Install

### Homebrew (macOS / Linux)

```bash
brew install akshaydeshraj/smartclip
```

Then add to your shell config:

```bash
# zsh (~/.zshrc)
source "$(brew --prefix)/share/smartclip/integrations/smartclip.zsh"

# bash (~/.bashrc)
source "$(brew --prefix)/share/smartclip/integrations/smartclip.bash"

# fish (~/.config/fish/config.fish)
source (brew --prefix)/share/smartclip/integrations/smartclip.fish
```

### npm

```bash
npm install -g smartclip-cli
```

Then add to your shell config:

```bash
# zsh (~/.zshrc)
source "$(npm prefix -g)/lib/node_modules/smartclip-cli/integrations/smartclip.zsh"

# bash (~/.bashrc)
source "$(npm prefix -g)/lib/node_modules/smartclip-cli/integrations/smartclip.bash"

# fish (~/.config/fish/config.fish)
source (npm prefix -g)/lib/node_modules/smartclip-cli/integrations/smartclip.fish
```

### From source

```bash
git clone https://github.com/akshaydeshraj/smartclip.git ~/smartclip
cd ~/smartclip
./install.sh
```

Then add to your shell config:

```bash
# zsh (~/.zshrc)
source ~/smartclip/integrations/smartclip.zsh

# bash (~/.bashrc)
source ~/smartclip/integrations/smartclip.bash

# fish (~/.config/fish/config.fish)
source ~/smartclip/integrations/smartclip.fish
```

Restart your shell or `source` the config. That's it.

## Usage

**You don't do anything.** Paste normally with Cmd+V (or your terminal's paste). smartclip intercepts the paste, fixes it if needed, and inserts the result. You'll see a brief `smartclip: fixed` indicator when it transforms something.

For manual use:

```bash
# Fix clipboard in-place
smartclip fix

# Pipe mode (works anywhere)
pbpaste | smartclip | pbcopy        # macOS
xclip -o | smartclip | xclip       # Linux/X11
wl-paste | smartclip | wl-copy     # Linux/Wayland

# Filter stdin
echo "$ git status" | smartclip
```

## How it works

1. **Detect** — Score-based heuristic checks if the pasted text is a shell command (known commands, operators, prompts, flags, redirections). Threshold of 3 required to act.
2. **Fix** — Line-by-line state machine strips prompts, joins continuations, collapses separate commands.
3. **Validate** — `bash -n` syntax check on the result. If invalid, the original is returned unchanged.

Zero dependencies. Single bash script. Works in any terminal emulator.

## Run tests

```bash
./test.sh
```

## License

MIT
