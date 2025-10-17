# Claude Commands

Slash commands for Claude that reference skills.

## Available Commands

### Collaboration
- `/brainstorm` - Interactive idea refinement using Socratic method
- `/write-plan` - Create detailed implementation plan
- `/execute-plan` - Execute plan in batches with review checkpoints

### Analysis
- `/archaeology` - Understand legacy code through systematic archaeology
- `/dependency-mapping` - Map dependencies and coupling to understand change impact

## Format

Each command is a markdown file with frontmatter and a reference to a skill:

```markdown
---
description: Brief description of what this command does
allowed-tools: Read, Bash, Grep, Glob
---

# Skill Name

Brief explanation of what will happen.

Read the skill file: @~/.claude/skills/category/skill-name/SKILL.md

Follow the workflow instructions.
```

When you run the command (e.g., `/brainstorm`), Claude loads and follows that skill.

## Creating Custom Commands

To add your own commands:

1. Create `your-command.md` in this directory
2. Add frontmatter and skill reference:
   ```markdown
   ---
   description: Your command description
   ---

   Read and follow: @~/.claude/skills/your-category/your-skill/SKILL.md
   ```
3. Copy to `~/.claude/commands/` - the command `/your-command` is now available

## Installation

Copy all command files to `~/.claude/commands/`:

```bash
cp cc-config/commands/*.md ~/.claude/commands/
```

Or symlink them for easier updates:

```bash
ln -sf /path/to/cc-config/commands/*.md ~/.claude/commands/
```
