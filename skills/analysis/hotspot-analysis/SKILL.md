---
name: Hotspot Analysis
description: Use git history and bug tracking to find problematic code areas that change frequently or have many bugs, focus refactoring efforts on real problems
when_to_use: when identifying problematic areas in legacy codebase, deciding where to focus refactoring efforts, or understanding which code is actually unstable
version: 1.0.0
languages: all
---

# Hotspot Analysis

## Overview

Not all legacy code is equal. Some files are stable and fine. Others are "hotspots" - frequently changing, bug-prone, painful to work with. Hotspot analysis uses data (git history, bugs) to find the real problems, not the "looks ugly" problems.

**Core principle:** Focus on data, not opinions. Refactor what breaks, not what looks bad.

## When to Use

Use hotspot analysis when:
- Deciding where to focus refactoring effort
- Limited time/budget for improvements
- Debating which technical debt to address
- Onboarding and want to know "dangerous" areas
- Planning sprint work (avoid hotspots or fix them)

## Types of Hotspots

### 1. Change Hotspots (Frequently Modified)

**What:** Files that change in many commits

**Why it matters:** Frequent changes = either:
- Business logic that evolves often (natural)
- Poorly designed code that keeps breaking (problem)

**How to find:**
```bash
# Files changed most often (last year)
git log --since="1 year ago" --format="" --name-only | \
  sort | uniq -c | sort -rn | head -20

# Example output:
# 145 src/services/UserService.ts
#  89 src/controllers/OrderController.ts
#  67 src/utils/validation.ts
```

### 2. Bug Hotspots (Frequent Bug Fixes)

**What:** Files with many bug-fixing commits

**How to find:**
```bash
# Commits with "fix" or "bug" in message
git log --grep="fix\|bug" --format="" --name-only | \
  sort | uniq -c | sort -rn | head -20

# More precise: require ticket reference
git log --grep="BUG-[0-9]+" --format="" --name-only | \
  sort | uniq -c | sort -rn | head -20
```

**Why it matters:** Bugs keep appearing = fundamental design problem

### 3. Complexity Hotspots (Hard to Understand)

**What:** Files with high cyclomatic complexity or many lines

**How to find:**
```bash
# Lines of code per file
find src -name "*.ts" -exec wc -l {} + | sort -rn | head -20

# Functions with many parameters (complexity proxy)
grep -rn "function.*(.*, .*, .*, .*, .*)" src/ | wc -l
```

**Why it matters:** Complex + frequently changed = disaster

### 4. Coupling Hotspots (Many Dependencies)

**What:** Files that many others depend on (from dependency-mapping)

```bash
# Most imported files
grep -rh "^import.*from" --include="*.ts" src/ | \
  sed "s/.*from ['\"]//;s/['\"].*//" | \
  sort | uniq -c | sort -rn | head -20
```

**Why it matters:** High coupling + frequent changes = widespread breakage

### 5. Ownership Hotspots (Many Authors)

**What:** Files touched by many different developers

```bash
# Number of unique authors per file
git log --format="%an" --follow -- path/to/file.ts | \
  sort -u | wc -l

# For all files:
for file in $(find src -name "*.ts"); do
  authors=$(git log --format="%an" --follow -- "$file" | sort -u | wc -l)
  echo "$authors $file"
done | sort -rn | head -20
```

**Why it matters:** Many authors = lack of ownership, knowledge fragmentation

## Analysis Techniques

### Technique 1: Change Frequency Heatmap

**Goal:** Visualize which files change most

```bash
# Generate change frequency data
git log --since="1 year ago" --format="" --name-only | \
  grep "\.ts$" | sort | uniq -c | sort -rn > changes.txt

# Top 10 hotspots
head -10 changes.txt
```

**Interpretation:**
- >100 changes/year: Hotspot (investigate)
- 20-100: Active (normal)
- <20: Stable (good)

### Technique 2: Churn vs Complexity

**Goal:** Find files that are both complex AND change frequently (worst combination)

```bash
# Complexity (lines of code)
find src -name "*.ts" -exec wc -l {} + > complexity.txt

# Churn (change frequency)
git log --since="1 year ago" --format="" --name-only | \
  grep "\.ts$" | sort | uniq -c > churn.txt

# Join data (manual or script)
# High churn + high complexity = REFACTOR NOW
```

### Technique 3: Temporal Coupling

**Goal:** Files that change together (coupled through time)

```bash
# For each commit, get files changed together
git log --format="%H" --since="1 year ago" | while read commit; do
  git show --format="" --name-only $commit | \
    while read file1; do
      git show --format="" --name-only $commit | \
        while read file2; do
          [ "$file1" != "$file2" ] && echo "$file1 $file2"
        done
    done
done | sort | uniq -c | sort -rn | head -20
```

**Interpretation:** Files that change together often should probably be in same module.

### Technique 4: Code Age

**Goal:** Find old, untouched code vs frequently changed code

```bash
# Last modification date per file
for file in $(find src -name "*.ts"); do
  last_change=$(git log -1 --format="%ai" -- "$file")
  echo "$last_change $file"
done | sort

# Old files (>2 years unchanged): Probably stable, don't touch
# Recently changed files: Active areas
```

## Prioritizing Refactoring

### The Refactoring Priority Matrix

| | Low Complexity | High Complexity |
|---|---|---|
| **High Churn** | Refactor (annoying) | REFACTOR NOW (disaster) |
| **Low Churn** | Leave alone (fine) | Leave alone (stable) |

**Focus area:** High churn + high complexity

**Examples:**
```
High churn + high complexity:
  UserService.ts (150 changes, 800 lines) → REFACTOR NOW

Low churn + high complexity:
  CryptoUtils.ts (5 changes, 1000 lines) → Leave alone (stable library code)

High churn + low complexity:
  FeatureFlags.ts (200 changes, 50 lines) → Annoying but manageable

Low churn + low complexity:
  DateFormatter.ts (3 changes, 30 lines) → Perfect, don't touch
```

### Bug Density Priority

```bash
# Bugs per 1000 lines of code
bugs=$(git log --grep="fix\|bug" --format="" --name-only -- src/UserService.ts | wc -l)
lines=$(wc -l < src/UserService.ts)
density=$((bugs * 1000 / lines))

echo "Bug density: $density bugs per 1000 LOC"
```

**Thresholds:**
- >10 bugs/1000 LOC: Critical (needs refactoring)
- 5-10: High (watch closely)
- <5: Normal

## Visualizing Hotspots

### Simple Text Report

```
HOTSPOT ANALYSIS REPORT
=======================

TOP 10 CHANGE HOTSPOTS:
1. UserService.ts (145 changes)
2. OrderController.ts (89 changes)
3. PaymentProcessor.ts (67 changes)
...

TOP 10 BUG HOTSPOTS:
1. PaymentProcessor.ts (23 bugs)
2. UserService.ts (18 bugs)
3. AuthController.ts (12 bugs)
...

COMPLEXITY + CHURN (Worst combination):
1. PaymentProcessor.ts (67 changes, 800 lines, 23 bugs) → CRITICAL
2. UserService.ts (145 changes, 650 lines, 18 bugs) → CRITICAL
```

### Code City Visualization

**Concept:** Buildings represent files
- Height = Complexity (lines of code)
- Color = Change frequency (red = hot, blue = cold)
- Size = File size

**Tools:**
- CodeScene (commercial)
- code-maat (open source)

## Quick Commands

```bash
# Hotspot analysis one-liner
git log --since="1 year ago" --format="" --name-only | \
  grep -v "^$" | sort | uniq -c | sort -rn | head -20

# Bug hotspots
git log --grep="fix\|bug\|BUG-" --format="" --name-only | \
  sort | uniq -c | sort -rn | head -20

# Recent hotspots (last 3 months)
git log --since="3 months ago" --format="" --name-only | \
  sort | uniq -c | sort -rn | head -10

# Authors per file (knowledge concentration)
for f in src/**/*.ts; do
  echo "$(git log --format="%an" -- "$f" | sort -u | wc -l) $f"
done | sort -rn | head -20
```

## Checklist

- [ ] Identified change hotspots (most frequently modified files)
- [ ] Found bug hotspots (files with most bug fixes)
- [ ] Measured complexity for hotspots (LOC, cyclomatic complexity)
- [ ] Combined churn + complexity (found worst areas)
- [ ] Analyzed temporal coupling (files that change together)
- [ ] Checked code age (stable vs volatile areas)
- [ ] Calculated bug density per file
- [ ] Prioritized refactoring efforts based on data
- [ ] Created hotspot report for team

## Anti-Patterns

### ❌ Refactoring Based on "Ugly Code"

**Bad:** "This code looks bad, let's refactor it"
**Good:** "This code changes weekly and causes bugs, let's refactor it"

Ugly but stable code is fine. Ugly + volatile code is problematic.

### ❌ Ignoring Low-Churn Complexity

**Bad:** "This 2000-line function needs refactoring!"
**Good:** "Has it changed in 3 years? No? Leave it alone."

If complex code is stable, refactoring adds risk with no benefit.

### ❌ Refactoring Everything

**Bad:** "Let's refactor all technical debt!"
**Good:** "Let's refactor the top 3 hotspots that cause 80% of bugs"

Focus on 20% of code that causes 80% of problems (Pareto principle).

## Example: Real Hotspot Analysis

**Codebase:** E-commerce platform, 100k LOC, 3 years old

**Analysis:**
```bash
# Change hotspots (last year)
git log --since="1 year ago" --format="" --name-only | \
  sort | uniq -c | sort -rn | head -10
```

**Results:**
```
145 src/services/UserService.ts
 89 src/controllers/OrderController.ts
 67 src/payment/PaymentProcessor.ts
 45 src/utils/validation.ts
 34 src/auth/AuthService.ts
```

**Bug analysis:**
```bash
git log --grep="BUG-" --format="" --name-only | \
  sort | uniq -c | sort -rn | head -5
```

**Results:**
```
23 src/payment/PaymentProcessor.ts
18 src/services/UserService.ts
12 src/auth/AuthService.ts
```

**Complexity:**
```bash
wc -l src/payment/PaymentProcessor.ts  # 812 lines
wc -l src/services/UserService.ts     # 650 lines
```

**Conclusion:**
```
CRITICAL HOTSPOTS (refactor immediately):
1. PaymentProcessor.ts
   - 67 changes/year
   - 23 bugs
   - 812 lines
   - Bug density: 28 bugs/1000 LOC (CRITICAL)

2. UserService.ts
   - 145 changes/year (most changed file!)
   - 18 bugs
   - 650 lines
   - Bug density: 27 bugs/1000 LOC (CRITICAL)

Action: Focus sprint on refactoring these 2 files.
Expected impact: Eliminate 60% of bugs, improve velocity.
```

## Integration with Other Skills

- **skills/analysis/dependency-mapping** - Understand coupling of hotspots
- **skills/refactoring/strangler-fig-pattern** - Safely replace hotspots
- **skills/refactoring/characterization-testing** - Test hotspots before refactoring
- **skills/research/tracing-knowledge-lineages** - Understand why hotspots exist

## Remember

- Data > opinions
- Refactor what breaks, not what looks bad
- High churn + high complexity = priority target
- Stable code can be ugly (it's fine)
- Focus on 20% causing 80% of problems
- Git history reveals the truth
- Bug density more important than absolute bug count
