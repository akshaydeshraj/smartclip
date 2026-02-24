#!/usr/bin/env bash
set -uo pipefail

SMARTCLIP="$(cd "$(dirname "$0")" && pwd)/smartclip"
passed=0
failed=0

run_test() {
  local name="$1"
  local input="$2"
  local expected="$3"
  local expect_rc="${4:-0}"  # expected exit code

  local actual rc
  actual="$(printf '%s' "$input" | "$SMARTCLIP" 2>/dev/null)" && rc=0 || rc=$?

  if [[ "$actual" == "$expected" && "$rc" == "$expect_rc" ]]; then
    echo "  PASS: $name"
    (( passed++ ))
  else
    echo "  FAIL: $name"
    if [[ "$actual" != "$expected" ]]; then
      echo "    expected output: $(printf '%q' "$expected")"
      echo "    actual output:   $(printf '%q' "$actual")"
    fi
    if [[ "$rc" != "$expect_rc" ]]; then
      echo "    expected rc: $expect_rc"
      echo "    actual rc:   $rc"
    fi
    (( failed++ ))
  fi
}

echo "=== SmartClip Tests ==="
echo ""

# ── Pass-through tests (should NOT transform) ───────────────────
echo "-- Pass-through tests --"

run_test "single line command" \
  "git status" \
  "git status" \
  1

run_test "empty input" \
  "" \
  "" \
  1

run_test "prose text" \
  "Hello world
This is just some regular text
Nothing to see here really" \
  "Hello world
This is just some regular text
Nothing to see here really" \
  1

run_test "JSON blob" \
  '{
  "name": "test",
  "version": "1.0.0"
}' \
  '{
  "name": "test",
  "version": "1.0.0"
}' \
  1

# ── Transformation tests ────────────────────────────────────────
echo ""
echo "-- Transformation tests --"

run_test "prompted commands (\$ prefix)" \
  '$ git add .
$ git commit -m "fix"
$ git push' \
  'git add .; git commit -m "fix"; git push' \
  0

run_test "backslash continuations" \
  'curl \
  -X POST \
  -H "Content-Type: json" \
  http://example.com' \
  'curl -X POST -H "Content-Type: json" http://example.com' \
  0

run_test "pipe continuations" \
  'cat file.txt |
  grep error |
  wc -l' \
  'cat file.txt | grep error | wc -l' \
  0

run_test "&& continuations" \
  'mkdir -p build &&
cd build &&
cmake ..' \
  'mkdir -p build && cd build && cmake ..' \
  0

run_test "|| continuations" \
  'test -f config.yml ||
echo "missing config"' \
  'test -f config.yml || echo "missing config"' \
  0

run_test "separate commands (no operators)" \
  'cd /tmp
git clone https://example.com/repo.git
cd repo' \
  'cd /tmp; git clone https://example.com/repo.git; cd repo' \
  0

run_test "mixed operators and separate commands" \
  '$ mkdir -p /tmp/test &&
$ cd /tmp/test
$ echo "hello"' \
  'mkdir -p /tmp/test && cd /tmp/test; echo "hello"' \
  0

run_test "leading > prompt" \
  '> echo hello
> echo world' \
  'echo hello; echo world' \
  0

run_test "docker run with backslash" \
  'docker run \
  -v /host:/container \
  -p 8080:80 \
  --name myapp \
  nginx:latest' \
  'docker run -v /host:/container -p 8080:80 --name myapp nginx:latest' \
  0

run_test "pipe at start of next line" \
  'cat /var/log/syslog
  | grep error
  | sort
  | uniq -c' \
  'cat /var/log/syslog | grep error | sort | uniq -c' \
  0

# ── Summary ─────────────────────────────────────────────────────
echo ""
echo "=== Results: $passed passed, $failed failed ==="
[[ "$failed" -eq 0 ]] && exit 0 || exit 1
