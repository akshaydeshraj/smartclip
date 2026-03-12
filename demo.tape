Output demo.gif

Set Shell "bash"
Set FontSize 15
Set Width 850
Set Height 400
Set Theme "Catppuccin Mocha"
Set Padding 20

# -- Without smartclip --
Set TypingSpeed 0
Type "# ✗ pasting without smartclip"
Enter
Sleep 1.5s

# Simulate broken paste — each line runs separately
Type "curl"
Enter
Sleep 0.5s
Type "  -X POST"
Enter
Type '  -H "Content-Type: json"'
Enter
Type "  https://api.example.com"
Enter
Set TypingSpeed 60ms

Sleep 4s

# -- With smartclip --
Set TypingSpeed 0
Type ""
Enter
Type "# ✓ pasting with smartclip"
Enter
Sleep 1.5s

# The fixed one-liner lands in prompt — don't execute
Type 'curl -X POST -H "Content-Type: json" https://api.example.com'
Set TypingSpeed 60ms

Sleep 4s
