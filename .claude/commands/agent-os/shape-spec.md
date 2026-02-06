---
description: Create implementation specification based on standards
argument-hint: [feature-description]
model: sonnet
---

Generate a shape spec (implementation specification) for a feature, guided by project standards.

**Feature:** $ARGUMENTS

**Process:**

1. **Requirements Gathering:**
   - Clarify feature requirements and scope
   - Identify affected components and areas
   - Determine integration points
   - Ask questions about edge cases and constraints

2. **Standards Review:**
   - Load relevant standards from `agent-os/standards/`
   - Identify applicable patterns and practices
   - Note any anti-patterns to avoid
   - Reference related specifications

3. **Specification Creation:**

   Create a structured spec including:

   **Overview:**
   - Feature description and purpose
   - User-facing behavior
   - Success criteria

   **Architecture:**
   - Components to modify or create
   - Data models and schemas
   - API endpoints or interfaces
   - Integration points

   **Standards Compliance:**
   - Applicable standards from `agent-os/standards/`
   - Patterns to follow
   - Anti-patterns to avoid
   - Code style requirements

   **Implementation Plan:**
   - Step-by-step tasks
   - File changes required
   - Testing requirements
   - Migration or deployment notes

   **Validation:**
   - Acceptance criteria
   - Test scenarios
   - Performance considerations
   - Security review points

4. **Save Specification:**
   - Save to `agent-os/specs/[feature-name].md`
   - Link to relevant standards
   - Include code examples
   - Document decision rationale

**Output:**

Produce a comprehensive, standards-compliant specification that can guide implementation without ambiguity.

Use `/discover-standards` to establish patterns first.
Use `/inject-standards` during implementation to apply patterns.
