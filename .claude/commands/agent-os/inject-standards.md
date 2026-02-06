---
description: Apply relevant standards to current work
argument-hint: [standard-path]
model: sonnet
---

Inject relevant standards into the current context.

**Mode:** ${1:+explicit}${1:-auto-suggest}

**Auto-Suggest Mode (no arguments):**

1. **Context Analysis:**
   - Identify the file or code currently being worked on
   - Analyze the type of work (feature, refactor, fix)
   - Determine relevant areas (api, database, components, etc.)

2. **Standard Matching:**
   - Search `agent-os/standards/` for applicable standards
   - Match based on file patterns, code structure, and work type
   - Prioritize most relevant standards

3. **Application:**
   - Present relevant standards with context
   - Explain how they apply to current work
   - Suggest specific code changes if applicable
   - Reference standard files for details

**Explicit Mode (with standard path):**

Apply the specified standard directly:
- Load standard from `agent-os/standards/$1`
- Explain the standard
- Show how to apply it to current context
- Provide code examples

**Standards Application:**

For each injected standard:
- Show the standard name and category
- Explain why it's relevant
- Provide concrete examples
- Suggest actionable changes if applicable

Available standards can be found in:
- `agent-os/standards/index.yml` (index)
- `agent-os/standards/*/` (standard files)

Use `/discover-standards` to find more patterns.
Use `/index-standards` to rebuild the index.
