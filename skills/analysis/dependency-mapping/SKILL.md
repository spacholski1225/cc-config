---
name: Dependency Mapping
description: Map dependencies and coupling in legacy codebase to understand what breaks when you change something and identify refactoring risks
when_to_use: when you need to understand dependencies and coupling before making changes, or identifying what will break if you modify a component
version: 1.0.0
languages: all
---

# Dependency Mapping

## Overview

Before changing code, know what depends on it. Dependency mapping reveals the blast radius of your changes.

**Core principle:** Understand coupling before changing. High coupling = high risk. Map first, change second.

## When to Use

Map dependencies when:
- Before refactoring or removing components
- Planning to extract module/service
- Investigating why "simple" changes break things
- Onboarding to unfamiliar codebase
- Deciding what to test after changes

## Types of Dependencies

### 1. Direct Dependencies (Imports/Requires)

**What:** Code explicitly imports/requires another module

```typescript
import { UserService } from './services/user';  // Direct dependency

class OrderController {
  constructor(private userService: UserService) {}
  // OrderController depends on UserService
}
```

**Tools:**
```bash
# Find what imports this file
grep -r "import.*UserService" --include="*.ts"

# Find what this file imports
grep "^import" src/services/user.ts
```

### 2. Data Dependencies (Shared Database/State)

**What:** Components share data structures or database tables

```
UserService → users table ← AuthService
```

Both depend on `users` table structure. Schema change affects both.

**How to find:**
```bash
# Find all SQL queries against table
grep -r "FROM users" --include="*.ts"
grep -r "users\." --include="*.sql"
```

### 3. Temporal Dependencies (Order Matters)

**What:** Component A must run before Component B

```typescript
// Migrations must run in order
001_create_users.sql
002_add_email_to_users.sql  // Depends on 001 existing
```

**Red flag:** Race conditions if order not guaranteed

### 4. Runtime Dependencies (Services, APIs)

**What:** Code depends on external service being available

```typescript
class PaymentService {
  async charge() {
    await this.stripe.charge();  // Runtime dependency on Stripe API
  }
}
```

**Impact:** Service down = feature down

## Mapping Techniques

### Static Analysis (Code Structure)

**Tool: dependency-cruiser (JavaScript/TypeScript)**
```bash
npm install -g dependency-cruiser
depcruise --include-only "^src" --output-type dot src | dot -T svg > deps.svg
```

**Tool: madge (JavaScript)**
```bash
npm install -g madge
madge --image deps.png src/
```

**Tool: grep (any language)**
```bash
# What depends on UserService?
grep -r "UserService" --include="*.ts" src/

# What does UserService depend on?
grep "^import" src/services/UserService.ts
```

### Dynamic Analysis (Runtime Behavior)

**Technique: Add logging**
```typescript
class UserService {
  findById(id: string) {
    console.log(`UserService.findById called from ${new Error().stack}`);
    // ...
  }
}
```

Run application, see who calls what.

### Database Query Analysis

**Find shared tables:**
```bash
# Which files query users table?
grep -r "FROM users" --include="*.ts" --include="*.sql"

# Result shows coupling through data
```

### Git Co-change Analysis

**Technique: Files that change together**
```bash
# Files changed together with UserService
git log --format="" --name-only -- src/services/UserService.ts | \
  sort | uniq -c | sort -rn | head -20
```

Files that change together often = coupled.

## Visualizing Dependencies

### Simple Text Map

```
OrderController
  → UserService
      → Database (users table)
      → CacheService (Redis)
  → PaymentService
      → Stripe API
      → Database (payments table)
```

### Dependency Matrix

|  | UserService | PaymentService | EmailService |
|--|-------------|----------------|--------------|
| **OrderController** | ✓ | ✓ | ✓ |
| **UserController** | ✓ | | ✓ |
| **AdminController** | ✓ | ✓ | |

Row depends on columns.

### Layered Architecture

```
┌─────────────────────────────┐
│  Controllers (HTTP Layer)    │
├─────────────────────────────┤
│  Services (Business Logic)   │
├─────────────────────────────┤
│  Repositories (Data Access)  │
├─────────────────────────────┤
│  Database                    │
└─────────────────────────────┘
```

Violations: Controller → Repository directly (skips Service layer)

## Measuring Coupling

### Afferent Coupling (Ca): Who depends on me?

```
UserService is depended on by:
- OrderController
- AuthController
- AdminController

Ca = 3 (high coupling - many depend on it)
```

**High Ca = Risky to change** (many things break)

### Efferent Coupling (Ce): Who do I depend on?

```
OrderController depends on:
- UserService
- PaymentService
- EmailService
- NotificationService

Ce = 4 (high coupling - depends on many)
```

**High Ce = Hard to test** (many dependencies to mock)

### Instability (I = Ce / (Ca + Ce))

```
UserService: Ca=5, Ce=2
I = 2/(5+2) = 0.28 (stable - more depended on than depending)

UtilityFunction: Ca=0, Ce=10
I = 10/(0+10) = 1.0 (unstable - all dependencies, no dependents)
```

**I near 0:** Stable (hard to change safely)
**I near 1:** Unstable (easy to change, low impact)

## Identifying Problem Areas

### 1. God Objects (High Ca)

```
UserService depended on by 50 files
```

**Problem:** Change breaks everything
**Solution:** Split into smaller services

### 2. Dependency Cycles

```
A → B → C → A  (cycle!)
```

**Problem:** Can't change one without others
**Solution:** Break cycle with interface/event

### 3. Shotgun Surgery

```
Change "user email format" requires editing:
- UserService.ts
- UserController.ts
- UserValidator.ts
- EmailService.ts
- NotificationService.ts
...20 more files
```

**Problem:** Single concept scattered across many files
**Solution:** Extract into single place

### 4. Wrong Layer Dependencies

```
Controller → Database directly (skipping Service layer)
```

**Problem:** Violates architecture, hard to test
**Solution:** Enforce layer boundaries

## Quick Analysis Commands

```bash
# Count dependencies (imports) per file
find src -name "*.ts" -exec sh -c \
  'echo "$(grep -c ^import "$1") $1"' _ {} \; | sort -rn

# Find files with >20 imports (high coupling)
find src -name "*.ts" -exec sh -c \
  'count=$(grep -c ^import "$1"); [ $count -gt 20 ] && echo "$count $1"' _ {} \;

# Find most-imported files (high Ca)
grep -rh "^import.*from" --include="*.ts" src/ | \
  sed "s/.*from ['\"]//;s/['\"].*//" | \
  sort | uniq -c | sort -rn | head -20
```

## Checklist

- [ ] Mapped direct dependencies (imports/requires)
- [ ] Identified data dependencies (shared tables/state)
- [ ] Found temporal dependencies (order requirements)
- [ ] Documented runtime dependencies (external services)
- [ ] Measured coupling (Ca, Ce for key components)
- [ ] Identified god objects (high Ca)
- [ ] Found dependency cycles
- [ ] Checked for wrong-layer violations
- [ ] Visualized dependency graph
- [ ] Estimated blast radius of planned changes

## Anti-Patterns

### ❌ Changing Without Mapping

**Bad:** "This looks simple" → Change → 10 things break
**Good:** Map dependencies → Understand impact → Change safely

### ❌ Ignoring Data Dependencies

**Bad:** "No code imports it, safe to change"
**Good:** "Check who queries this table first"

Data dependencies are invisible in import statements.

## Example: Planning UserService Refactor

**Step 1: Map dependencies**
```bash
# Who imports UserService?
grep -r "UserService" --include="*.ts" src/
# Result: 35 files depend on it (Ca = 35)

# What does UserService import?
grep "^import" src/services/UserService.ts
# Result: Depends on DB, Cache, Logger (Ce = 3)

# Instability: I = 3/(35+3) = 0.08 (very stable = risky to change!)
```

**Step 2: Analyze dependents**
```
Controllers: 12 files
Services: 15 files
Background jobs: 5 files
Tests: 3 files
```

**Step 3: Plan safe refactor**
```
Option A: Big-bang (risky - 35 files break)
Option B: Add interface, change implementation (safer - 0 files break)
Option C: Strangler fig pattern (safest - gradual migration)
```

**Decision:** Option C (strangler fig) due to high coupling.

## Integration with Other Skills

- **skills/refactoring/strangler-fig-pattern** - Replace highly-coupled components safely
- **skills/refactoring/seam-finding** - Dependencies reveal seams
- **skills/analysis/code-archaeology** - Understand why dependencies exist
- **skills/testing/test-driven-development** - Mock dependencies in tests

## Remember

- Map before changing
- High Ca = high risk
- Data dependencies are invisible
- Cycles = trouble
- Tools automate mapping
- Visualization reveals patterns
- Coupling metrics guide decisions
