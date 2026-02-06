---
description: Rebuild the standards index from all standard files
model: haiku
---

Rebuild the standards index by scanning all standard files.

**Process:**

1. **Scan Standards Directory:**
   - Traverse `agent-os/standards/` recursively
   - Find all standard files (*.md)
   - Parse frontmatter and content

2. **Build Index:**
   - Extract metadata from each standard:
     - Title and description
     - Category (opinionated, tribal, practical, anti-pattern)
     - File path
     - Areas/tags
   - Organize by category and area
   - Generate cross-references

3. **Validate:**
   - Check for duplicate standards
   - Verify required fields present
   - Flag incomplete or malformed standards
   - Report any issues found

4. **Update Index:**
   - Write to `agent-os/standards/index.yml`
   - Include metadata:
     - Version: "1.0"
     - Generated timestamp
     - Project name
     - Standard count
   - Structure by category and area
   - Include file paths for each standard

5. **Report:**
   - Total standards indexed
   - Breakdown by category
   - Breakdown by area
   - Any warnings or errors

**Index Format:**

```yaml
version: "1.0"
generated: 2026-02-06T17:30:00Z
project: project-name
standards:
  api:
    - file: api/rest-conventions.md
      title: REST API Conventions
      category: opinionated
    - file: api/error-handling.md
      title: API Error Handling
      category: practical
  database:
    - file: database/migration-standards.md
      title: Database Migration Standards
      category: tribal
```

Run this command after:
- Creating new standards with `/discover-standards`
- Modifying existing standard files
- Moving or renaming standards
- Deleting outdated standards
