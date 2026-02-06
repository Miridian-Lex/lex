---
description: Discover and document code patterns and standards
argument-hint: [area]
model: sonnet
---

Discover code patterns and standards for this project.

**Focus Area:** ${1:-general}

**Process:**

1. **Identify Scope:**
   - Choose focus area (api, database, components, auth, testing, infrastructure, or general)
   - Scan representative files in that area
   - Look for repeated patterns and conventions

2. **Pattern Analysis:**
   - **Opinionated patterns:** Team preferences and style choices
   - **Tribal knowledge:** Undocumented conventions developers follow
   - **Practical patterns:** Performance, security, or reliability practices
   - **Anti-patterns:** Issues that need correction

3. **Pattern Documentation:**
   - For each pattern found, document:
     - What: Clear description of the pattern
     - Why: Rationale and benefits
     - When: Where/when to apply it
     - How: Implementation example
     - Category: opinionated, tribal, practical, or anti-pattern

4. **Confirm and Save:**
   - Ask clarifying questions about patterns
   - Draft standards documentation
   - Save to `agent-os/standards/${1:-general}/` directory
   - Update `agent-os/standards/index.yml`

**Standards Format:**

Each standard file should include:
- Clear title and description
- Category classification
- Code examples showing correct usage
- Common mistakes to avoid
- References to related standards

After discovering standards, run `/index-standards` to update the index.
