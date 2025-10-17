#!/usr/bin/env bash
# SessionStart hook for cc-config

set -euo pipefail

# Set environment variables
export CC_CONFIG_ROOT="${HOME}/.claude"
export CC_SKILLS_ROOT="${CC_CONFIG_ROOT}/skills"

# Run find-skills to show all available skills
find_skills_output=$("${CC_SKILLS_ROOT}/using-skills/find-skills" 2>&1 || echo "Error running find-skills")

# Read using-skills content
using_skills_content=$(cat "${CC_SKILLS_ROOT}/using-skills/SKILL.md" 2>&1 || echo "Error reading using-skills")

# Escape outputs for JSON
find_skills_escaped=$(echo "$find_skills_output" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}')
using_skills_escaped=$(echo "$using_skills_content" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}')

# Log to file for debugging
echo "Hook executed at $(date)" >> /tmp/claude-hook-debug.log

# Output context injection as JSON
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<EXTREMELY_IMPORTANT>\n🎯 SessionStart hook executed successfully at $(date '+%Y-%m-%d %H:%M:%S')\n\nYou have cc-config skills available.\n\n**The content below is from skills/using-skills/SKILL.md - your introduction to using skills:**\n\n${using_skills_escaped}\n\n**Tool paths (use these when you need to search for or run skills):**\n- find-skills: ${CC_SKILLS_ROOT}/using-skills/find-skills\n- skill-run: ${CC_SKILLS_ROOT}/using-skills/skill-run\n\n**Skills live in:** ${CC_SKILLS_ROOT}/ (you can edit any skill)\n\n**Available skills (output of find-skills):**\n\n${find_skills_escaped}\n</EXTREMELY_IMPORTANT>"
  }
}
EOF

exit 0
