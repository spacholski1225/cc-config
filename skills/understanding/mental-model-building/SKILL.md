---
name: Mental Model Building
description: Creating accurate internal representations of how complex legacy systems work through diagrams, analogies, and testing
when_to_use: when working with complex legacy system and need to build internal understanding of how it works before making changes
version: 1.0.0
languages: all
---

# Mental Model Building

## Overview

A mental model is your internal simulation of how a system works. Good models predict behavior accurately. Bad models lead to wrong predictions and broken code.

**Core principle:** Build models incrementally, test predictions, refine when wrong.

## When to Use

Build mental models when:
- System is too complex to hold entirely in working memory
- Need to explain system to others
- Making changes and want to predict impact
- Debugging and need to form hypotheses
- Before refactoring large components

## The Model Building Process

### Step 1: Start with Black Box

**Don't look inside yet. Observe external behavior.**

```
Input → [SYSTEM] → Output

Example:
POST /api/login → [Auth System] → JWT token
```

**Questions to answer:**
- What goes in?
- What comes out?
- What's the relationship?

**Test:** Can you predict output for given input?

### Step 2: Open One Layer

**Look inside, identify major components.**

```
POST /api/login → [Router] → [AuthController] → [JWT Service] → Token
```

**Questions:**
- What are the major pieces?
- How do they connect?
- What's the order of operations?

**Test:** Can you trace path through system?

### Step 3: Add Detail to Critical Paths

**Focus on what matters for your task.**

```
AuthController.login():
  1. Extract credentials from request
  2. Validate format → ValidationService
  3. Check against database → UserRepository
  4. Verify password → bcrypt.compare()
  5. Generate token → TokenService.generate()
  6. Return token
```

**Questions:**
- What happens at each step?
- What can fail?
- What are the dependencies?

**Test:** Can you predict where failures occur?

### Step 4: Test Your Model

**Make predictions, verify with code/experiments.**

**Predictions:**
- "If I pass invalid email, it fails at step 2"
- "If user doesn't exist, it fails at step 4"
- "If DB is down, it fails at step 3"

**Verification:**
```typescript
// Test prediction
test('invalid email fails early', () => {
  expect(() => AuthController.login({ email: 'not-an-email' }))
    .toThrow(ValidationError);
  // Passed! Model prediction correct.
});
```

### Step 5: Refine When Wrong

**Model predicted X, reality is Y → update model.**

**Example:**
```
My model: "Invalid email throws ValidationError"
Reality: "Invalid email returns 400 with error message"
Updated model: "Validation errors don't throw, they return 400 responses"
```

**Key insight:** Being wrong is good. It means you're learning.

## Model Representation Techniques

### 1. Boxes and Arrows

**For:** Data flow, component relationships

```
┌─────────┐    ┌──────────────┐    ┌──────────┐
│ Client  │───→│ Auth Service │───→│ Database │
└─────────┘    └──────────────┘    └──────────┘
                      │
                      ↓
                ┌───────────┐
                │   Redis   │
                │ (sessions)│
                └───────────┘
```

### 2. State Machines

**For:** Lifecycle, status transitions

```
[New] ──register──→ [Pending] ──verify──→ [Active]
                        │
                        └──timeout──→ [Expired]

[Active] ──ban──→ [Banned]
         ──delete──→ [Deleted]
```

### 3. Sequence Diagrams

**For:** Interactions over time

```
Client          API         Database      Email Service
  │              │              │               │
  ├─register────→│              │               │
  │              ├─validate────→│               │
  │              │←─ok──────────┤               │
  │              ├──────────────┼──send email──→│
  │←─token───────┤              │               │
```

### 4. Mental Analogies

**For:** Explaining complex concepts

**Example: Understanding event loop**
```
Mental model: Restaurant kitchen

- Orders (events) come in
- One chef (single thread) works on one order at a time
- Quick prep tasks done immediately (synchronous)
- Oven tasks delegated (async - libuv)
- Chef checks oven between orders (event loop)
```

**Test analogy:** If analogy predicts behavior, it's good. If not, refine.

### 5. Simplified Code

**For:** Understanding algorithms

**Instead of this:**
```typescript
function processUserData(user: User): ProcessedUser {
  const validated = this.validator.validate(user, this.schema);
  const enriched = this.enricher.enrich(validated, this.config);
  const transformed = this.transformer.transform(enriched);
  return this.serializer.serialize(transformed);
}
```

**Model as:**
```
processUserData(user):
  user → validate → enrich → transform → serialize → result
```

## Testing Your Mental Model

### Prediction Test

**Process:**
1. Make prediction based on model
2. Test in code/debugger
3. Compare prediction vs reality
4. If wrong → update model

**Example:**
```
Prediction: "Changing timeout to 5s will prevent race condition"
Test: Set timeout=5s, run test 100 times
Result: Still fails occasionally
Update model: "Timeout not the issue - it's a locking problem"
```

### Explanation Test

**Process:**
1. Explain system to someone else
2. They ask questions
3. Your model can't answer → gaps revealed
4. Fill gaps, re-explain

**Rubber duck debugging** is this: explaining reveals gaps in your model.

### Edge Case Test

**Process:**
1. Think of weird inputs
2. Predict what happens
3. Try it
4. Refine model

**Example:**
```
Input: What if user.email is null?
Prediction: "Validation catches it"
Reality: "Crashes with null pointer"
Model update: "Validation doesn't check null, only format"
```

## Checklist

- [ ] Started with black box (input/output behavior)
- [ ] Identified major components
- [ ] Traced critical paths in detail
- [ ] Created visual representation (diagram/state machine)
- [ ] Made predictions based on model
- [ ] Tested predictions with code/experiments
- [ ] Refined model when predictions wrong
- [ ] Can explain system to someone else
- [ ] Model handles edge cases

## Anti-Patterns

### ❌ Building Complete Model Before Testing

**Bad:** Study code for hours, build elaborate model, discover it's wrong
**Good:** Build small model → test → refine → expand → test → refine

Iterate rapidly.

### ❌ Ignoring When Model is Wrong

**Bad:** "My model says it should work this way" *ignores reality*
**Good:** "My model was wrong, let me update it based on what actually happened"

Reality > model. Always.

### ❌ Over-Detailed Models

**Bad:** Model every function, every variable
**Good:** Model critical paths, ignore boilerplate

Model what matters for your task.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "I'll build the model in my head" | External representations (diagrams) reveal gaps. Draw it. |
| "I understand it now" (after 10 minutes) | Understanding takes repeated testing and refinement. |
| "The model is complete" | Models are always incomplete. Expand as needed. |
| "I don't need diagrams" | Visual models reveal patterns text doesn't. |

## Example: Building Model of Authentication

**Iteration 1: Black box**
```
POST /login → 200 OK + JWT token
```

**Iteration 2: Components**
```
POST /login → API → Auth Service → Database
                                   → Token Service → JWT
```

**Iteration 3: Details**
```
API receives {email, password}
→ AuthService validates format
→ Database query: SELECT * FROM users WHERE email = ?
→ bcrypt.compare(password, user.hashed_password)
→ TokenService.generate(user.id) → JWT with 24h expiry
→ Return {token, user}
```

**Iteration 4: Failure modes**
```
- Invalid email format → 400 "Invalid email"
- User not found → 401 "Invalid credentials"
- Wrong password → 401 "Invalid credentials"
- Database down → 500 "Internal error"
```

**Test model:**
```typescript
test('model prediction: wrong password returns 401', async () => {
  const result = await login('user@example.com', 'wrong');
  expect(result.status).toBe(401);
  // Passes! Model accurate.
});
```

## Integration with Other Skills

- **skills/analysis/code-archaeology** - Build models while reading code
- **skills/understanding/questioning-techniques** - Questions reveal model gaps
- **skills/documentation/reverse-engineering-docs** - Document models for others
- **skills/debugging/systematic-debugging** - Models guide hypothesis formation

## Remember

- Start simple, add detail incrementally
- Test predictions against reality
- Refine when wrong (being wrong = learning)
- Draw it - visual models reveal gaps
- Models are tools, not truth
- Good enough model > perfect model later
