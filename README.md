# Agent Skills

Skills library for Claude Code focused on legacy code analysis, explanation, and safe refactoring.

## What is Agent Skills?

**Agent Skills** is a curated collection of proven techniques for working with existing codebases. While it includes general software development skills (TDD, debugging), the emphasis is on:

- **Analyzing legacy code** - Understanding code without documentation
- **Explaining concepts** - Making complex systems comprehensible
- **Safe refactoring** - Changing production code without breaking it
- **Building mental models** - Creating understanding of how systems work
- **Characterization testing** - Adding safety nets before changes

## Philosophy

**Understand before changing.** The code you're looking at is solving a problem. Understand the problem before changing the solution.

**Safety first.** Legacy code is production code. Tests, incremental changes, and rollback strategies come before speed.

**Document as you learn.** Reverse-engineering documentation helps everyone, including future you.

## Skills Library

### Analysis (`skills/analysis/`)
- **code-archaeology** - Reading and understanding unfamiliar legacy code
- **dependency-mapping** - Understanding coupling and dependencies
- **hotspot-analysis** - Finding problematic areas via git history
- **understanding-mechanisms** - Explaining how complex systems work
- **concept-extraction** - Making implicit concepts explicit

### Refactoring (`skills/refactoring/`)
- **characterization-testing** - Tests that document current behavior
- **strangler-fig-pattern** - Replacing systems piece by piece
- **seam-finding** - Finding safe refactoring boundaries
- **parallel-change** - Refactoring without downtime
- **safe-extraction** - Extracting functionality from monoliths

### Documentation (`skills/documentation/`)
- **reverse-engineering-docs** - Creating docs from code
- **explaining-patterns** - Documenting why patterns are used
- **architecture-discovery** - Reverse-engineering high-level architecture

### Safety (`skills/safety/`)
- **approval-testing** - Snapshot testing for complex outputs
- **safe-database-migrations** - Schema changes without downtime
- **rollback-strategies** - Quick recovery from deployment issues
- **feature-flags-for-legacy** - Safe feature deployment

### Understanding (`skills/understanding/`)
- **mental-model-building** - Creating internal understanding
- **questioning-techniques** - Systematic questioning methods
- **assumption-validation** - Testing what you think you know

### Testing (`skills/testing/`)
- **test-driven-development** - RED-GREEN-REFACTOR cycle
- **testing-anti-patterns** - Common testing pitfalls

### Debugging (`skills/debugging/`)
- **systematic-debugging** - 4-phase root cause process
- **root-cause-tracing** - Finding the real problem
- **verification-before-completion** - Ensuring fixes work

### Collaboration (`skills/collaboration/`)
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Batch execution with checkpoints

### Problem Solving (`skills/problem-solving/`)
- **when-stuck** - Dispatch to right technique
- **simplification-cascades** - Finding unifying simplifications

### Research (`skills/research/`)
- **tracing-knowledge-lineages** - Understanding why code exists

## Quick Start

### Finding Skills

```bash
# Show all skills
${AGENT_SKILLS_ROOT}/skills/using-skills/find-skills

# Search for specific topic
${AGENT_SKILLS_ROOT}/skills/using-skills/find-skills legacy
${AGENT_SKILLS_ROOT}/skills/using-skills/find-skills test
${AGENT_SKILLS_ROOT}/skills/using-skills/find-skills 'refactor|extract'
```

### Using Skills

When starting any task:

1. Run `find-skills` to check for relevant skills
2. If skill exists, use Read tool: `${AGENT_SKILLS_ROOT}/skills/category/skill-name/SKILL.md`
3. Announce you're using it
4. Follow what it says

### Example Workflow

```
User: "I need to refactor this legacy authentication module"

Claude: Let me check for relevant skills...
[Runs find-skills refactor]

I've found these skills:
- skills/refactoring/characterization-testing/SKILL.md
- skills/refactoring/seam-finding/SKILL.md
- skills/refactoring/strangler-fig-pattern/SKILL.md

I'm using the Characterization Testing skill to add safety net before refactoring.
[Reads and follows skill]
```

## Structure

```
agent-skills/
├── README.md
├── LICENSE
└── skills/
    ├── using-skills/      # How to use the system
    ├── analysis/          # Code analysis techniques
    ├── refactoring/       # Safe refactoring patterns
    ├── documentation/     # Reverse-engineering docs
    ├── safety/            # Risk mitigation
    ├── understanding/     # Building comprehension
    ├── testing/           # Testing fundamentals
    ├── debugging/         # Systematic debugging
    ├── collaboration/     # Team workflows
    ├── problem-solving/   # When stuck
    ├── research/          # Understanding history
    └── meta/              # Creating skills
```

## Contributing

To add or improve skills:

1. Follow `skills/meta/writing-skills/SKILL.md`
2. Test skills before deploying (TDD for documentation)
3. Commit changes to your fork
4. Submit pull request

## License

MIT License - see LICENSE file for details
