# smartclip

[![npm](https://img.shields.io/npm/v/smartclip-cli)](https://www.npmjs.com/package/smartclip-cli)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Paste multi-line shell commands that actually work.**

<p align="center">
  <img src="demo.gif" alt="smartclip demo" width="800">
</p>

You copy a command from a README, Stack Overflow, or ChatGPT. You paste it. Your terminal chokes:

```
$ curl \
  -X POST \
  -H "Content-Type: application/json" \
  https://api.example.com
```
```
zsh: command not found: -X
zsh: command not found: -H
```

smartclip hooks into your shell's paste and silently fixes it:

```
curl -X POST -H "Content-Type: application/json" https://api.example.com
```

No daemon. No polling. No background process. ~100 lines of bash. It runs **only** when you paste.

## Why not just fix your terminal?

You might be thinking "bracketed paste mode solves this" — it doesn't. Bracketed paste prevents line-by-line *execution*, but the **content itself** still arrives malformed: broken continuations, stray `$` prompts, operators split across lines. That's a content problem, not a terminal problem.

## Install

```bash
brew install akshaydeshraj/smartclip         # homebrew
npm install -g smartclip-cli                  # npm
```

Then add one line to your shell config:

```bash
# pick your shell — zsh / bash / fish
source "$(brew --prefix)/share/smartclip/integrations/smartclip.zsh"
source "$(brew --prefix)/share/smartclip/integrations/smartclip.bash"
source (brew --prefix)/share/smartclip/integrations/smartclip.fish
```

<details>
<summary>npm or source install paths</summary>

**npm:**
```bash
source "$(npm prefix -g)/lib/node_modules/smartclip-cli/integrations/smartclip.zsh"
```

**From source:**
```bash
git clone https://github.com/akshaydeshraj/smartclip.git ~/smartclip
cd ~/smartclip && ./install.sh
source ~/smartclip/integrations/smartclip.zsh
```
</details>

Restart your shell. That's it. Paste with Cmd+V as usual.

## What it fixes

| Pattern | Example |
|---------|---------|
| `\` continuations | `docker run \`<br>`  -p 8080:80 \`<br>`  nginx` |
| Pipe / `&&` / `\|\|` splits | `cat log \|`<br>`  grep error` |
| `$` / `>` prompts | `$ git add .`<br>`$ git push` |
| Indented arguments | `sudo cat`<br>`  /very/long/path` |
| Separate commands | `cd /tmp`<br>`git clone url` |
| Heredocs | Preserved as-is |

**What it won't touch:** prose, JSON, YAML, URLs — anything that doesn't score high enough on the shell-command heuristic passes through unchanged.

## How it works

```
paste → detect → fix → validate → insert
```

1. **Detect** — Score-based heuristic (known commands, operators, prompts, flags, redirections). Below threshold? Pass through unchanged.
2. **Fix** — State machine joins continuations, strips prompts, collapses commands.
3. **Validate** — `bash -n` syntax check. Invalid result? Original is pasted instead.

The shell integration overrides zsh's `bracketed-paste` widget (or bash/fish equivalent). Your normal Cmd+V triggers it — no new keybindings, no muscle memory change.

## Manual use

```bash
smartclip fix                                # fix clipboard in-place
pbpaste | smartclip | pbcopy                 # pipe mode (macOS)
echo "$ git status" | smartclip              # stdin filter
```

## Contributing

```bash
./test.sh                                    # run the test suite
```

PRs welcome. The entire tool is a single file: [`smartclip`](smartclip).

## License

MIT
