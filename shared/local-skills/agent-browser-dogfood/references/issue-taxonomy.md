# Issue Taxonomy & Exploration Checklist

## Exploration Checklist
*   **Navigation:** Do all links work? Is the hierarchy logical?
*   **Forms:** Do inputs have proper validation? Are error messages clear?
*   **Performance:** Does the UI feel snappy? Are there long loading states without feedback?
*   **Visuals:** Are there typos, clipped text, or alignment issues?
*   **Console:** Are there unhandled exceptions or failed network requests?
*   **Workflows:** Can a user complete core tasks (e.g., sign up, checkout, create resource)?

## Severity Levels
*   🔴 **Critical:** App crash, data loss, security vulnerability, or complete blocker of a core workflow.
*   🟡 **High:** Significant functional bug or broken feature that has a workaround but severely impacts UX.
*   🔵 **Medium:** Minor functional bug, confusing UX, or significant visual regression.
*   ⚪ **Low:** Typos, minor alignment issues, or "nice-to-have" improvements.

## Documentation Requirements
*   **Interactive Issues:** Must include a reproduction video (`.webm`) and step-by-step screenshots.
*   **Static Issues:** Must include at least one annotated screenshot highlighting the issue.
*   **Console Errors:** Must include the error message and stack trace if available.
