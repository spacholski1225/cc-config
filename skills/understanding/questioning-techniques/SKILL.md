---
name: Questioning Techniques
description: Systematic methods for asking questions to understand legacy code, validate assumptions, and explain concepts
when_to_use: when trying to understand legacy code or explaining concepts to others, before making assumptions about how systems work
version: 1.0.0
languages: all
---

# Questioning Techniques

## Overview

Good questions reveal hidden assumptions, uncover root causes, and build accurate mental models. Bad questions confirm biases and miss critical details.

**Core principle:** Question everything, assume nothing. Especially question what seems "obvious."

## When to Use

Use questioning techniques when:
- Encountering unfamiliar code or systems
- Before making changes to legacy code
- Explaining complex concepts to others
- Validating assumptions about how something works
- Stuck and don't know what you don't know
- Someone says "it's obvious" or "everyone knows"

## The Question Frameworks

### Framework 1: Five Whys (Root Cause)

**Purpose:** Find root cause by asking "why" repeatedly.

**Process:**
1. State the problem
2. Ask "Why does this happen?"
3. For each answer, ask "Why?" again
4. Repeat 5 times (or until root cause found)
5. Root cause = thing you can actually fix

**Example:**
```
Problem: "The application crashes during peak traffic"

Why? → "The database connection pool runs out"
Why? → "We have a connection leak"
Why? → "Connections aren't returned after errors"
Why? → "Error handling doesn't include finally blocks"
Why? → "Original developer didn't know about connection lifecycle"

Root cause: Missing finally blocks in error handling
Fix: Add finally blocks to ensure connections are always returned
```

**Red flag:** If 5th "why" is "someone made a mistake" → keep going. You haven't found the process/system issue yet.

### Framework 2: What/Why/How/When

**Purpose:** Complete understanding of a concept or system.

| Question | Purpose | Example |
|----------|---------|---------|
| **WHAT** | Define the thing | "What is this component?" |
| **WHY** | Understand purpose | "Why does it exist?" |
| **HOW** | Understand mechanism | "How does it work?" |
| **WHEN** | Understand lifecycle | "When is it used?" |

**Example: Understanding authentication:**
```
WHAT:  What is JWT authentication?
       → Token-based stateless authentication

WHY:   Why do we use JWT instead of sessions?
       → Scalability: no server-side state needed

HOW:   How does JWT work?
       → Client sends credentials → Server validates → Returns signed token
       → Client includes token in subsequent requests → Server verifies signature

WHEN:  When is the token validated?
       → Every request (via middleware)
       When does it expire?
       → After 24 hours (configurable)
```

### Framework 3: First Principles

**Purpose:** Strip away assumptions and understand from ground truth.

**Process:**
1. Identify what you think you know
2. Question each assumption: "Is this fundamentally true, or did someone tell me?"
3. Strip away all non-fundamental assumptions
4. Rebuild understanding from fundamentals only

**Example:**
```
"We need to use microservices because everyone uses them"

First principles:
- Fundamental: Systems need boundaries to manage complexity
- Fundamental: Network calls are slower than in-process calls
- Fundamental: Distributed systems are harder to debug

Non-fundamental assumptions:
- "Microservices are best practice" (fashion, not fundamental)
- "Monoliths don't scale" (false - many scale fine)
- "We need to split everything" (not necessarily)

Conclusion: Start with monolith. Split only at actual pain points.
```

### Framework 4: Socratic Method

**Purpose:** Expose contradictions and refine thinking through dialogue.

**Technique:**
1. Partner makes a claim
2. Ask clarifying questions (not challenges)
3. Find edge cases where claim doesn't hold
4. Refine claim together

**Example dialogue:**
```
Partner: "This function is too complex, we need to break it up"

You: "What makes it complex?"
Partner: "It's 50 lines long"

You: "Is line count the measure of complexity?"
Partner: "Well, it also has nested loops"

You: "Are nested loops always bad?"
Partner: "Not always... but these are hard to follow"

You: "What makes them hard to follow?"
Partner: "The loop variables have unclear names"

Refined understanding: Problem isn't length or nesting - it's clarity.
Fix: Rename variables and add comments, don't restructure.
```

## Question Categories

### Understanding Questions

**Ask when:** You need to learn how something works

```
- "What does this function do?"
- "Why was this approach chosen?"
- "How does this interact with X?"
- "When does this code execute?"
- "What happens if input is null/empty/invalid?"
- "Where is this function called from?"
```

### Validation Questions

**Ask when:** You think you understand, need to verify

```
- "If I change X, will Y happen?"
- "Does this handle the case where...?"
- "Is my understanding correct that...?"
- "What breaks if I remove this line?"
- "Can you walk me through what happens when...?"
```

### Assumption Questions

**Ask when:** Something seems "obvious" or "everyone knows"

```
- "Why do we assume X is always true?"
- "What if this assumption is wrong?"
- "Has anyone verified this assumption recently?"
- "Under what conditions would this assumption break?"
- "Who told us this was the case?"
```

### Debugging Questions

**Ask when:** Something isn't working as expected

```
- "What did you expect to happen?"
- "What actually happened?"
- "What changed recently?"
- "Can you reproduce it reliably?"
- "What error message did you see?"
- "What were the values of key variables?"
```

## Techniques for Asking Better Questions

### 1. Make Questions Specific

**Bad:** "How does authentication work?"
**Good:** "What happens to the JWT token when a user logs out?"

Specific questions get specific answers. General questions get general (useless) answers.

### 2. Ask Open-Ended Questions

**Bad:** "Does this function handle errors?" (yes/no)
**Good:** "How does this function handle errors?" (explanation)

Open questions reveal thought process, not just facts.

### 3. Ask "What if" for Edge Cases

**Pattern:** "What if [unexpected input]?"

```
- "What if the file doesn't exist?"
- "What if two users do this simultaneously?"
- "What if the external API is down?"
- "What if the input is 10x larger than expected?"
```

### 4. Follow Up with "How do you know?"

**Pattern:** Challenge sources of knowledge

```
Partner: "This code handles all cases"
You: "How do you know?"
Partner: "We tested it"
You: "What did you test?"
Partner: "Uh... let me check the tests"
```

Often reveals gaps in knowledge or testing.

### 5. Silence is a Question

**Technique:** After someone explains, pause 3 seconds.

They'll often add: "Oh, and also..." revealing details they initially forgot.

## Checklist

- [ ] Used specific questions, not general ones
- [ ] Asked "why" repeatedly to find root cause
- [ ] Validated assumptions with "how do you know?"
- [ ] Explored edge cases with "what if"
- [ ] Asked open-ended questions for explanation
- [ ] Questioned things that seem "obvious"
- [ ] Stripped away assumptions to first principles
- [ ] Verified understanding by explaining back

## Anti-Patterns

### ❌ Leading Questions

**Bad:** "Don't you think this code is bad?"
**Good:** "What do you think about this code structure?"

Leading questions get the answer you want, not the truth.

### ❌ Asking Before Reading

**Bad:** *Immediately asks* "What does this do?"
**Good:** *Reads code first* "I see it does X and Y. Why does it also do Z?"

Read first, ask second. Shows respect and gets better answers.

### ❌ Yes/No Questions for Complex Topics

**Bad:** "Is this secure?"
**Good:** "What security considerations does this address?"

Binary questions hide complexity.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "That's obvious, no need to ask" | "Obvious" things are often wrong. Ask anyway. |
| "I don't want to look stupid" | Asking reveals intelligence. Assuming reveals ignorance. |
| "They'll think I should know this" | Better to ask than to break production because you assumed. |
| "I'll figure it out myself" | Questions save hours of investigation. |

## Integration with Other Skills

- **skills/analysis/code-archaeology** - Questions to ask while reading code
- **skills/understanding/mental-model-building** - Questions build mental models
- **skills/understanding/assumption-validation** - Questions test assumptions
- **skills/collaboration/brainstorming** - Socratic method for design

## Remember

- Question everything, especially "obvious" things
- Specific questions get specific answers
- Ask "why" 5 times to find root cause
- Validate assumptions with "how do you know?"
- Silence is a powerful question
- First principles > received wisdom
