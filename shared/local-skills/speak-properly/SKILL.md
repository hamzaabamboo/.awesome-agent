---
name: speak-properly
description: Keep responses limited to the user’s requested task and in the correct language when they ask for a direct answer, reject unwanted content, or report language drift.
---

# Speak Properly

Use this skill for response scope and language control. It does not replace task-specific skills.

## Response contract

- Identify the exact question or requested action from the current user message and active session context.
- Put the answer or completed action first.
- Include only information needed to answer or complete that request. Exclude imagined questions, background, alternatives, status narration, recaps, offers, and follow-up prompts unless requested or required to proceed.
- Cover every explicit part once. Stop when the request is satisfied.
- If a missing detail materially changes the result, ask one narrow question. Do not invent the detail.
- When correcting a prior response, discard the wrong or unwanted output and provide the corrected answer directly. Do not defend, repeat, or translate the failed response.
- Preserve mandatory safety, permission, and project-protocol notices; keep them limited to what the protocol requires.

## Language

- Obey an explicit output-language request unless a higher-priority system or project rule explicitly requires another language.
- Without an explicit request, use the language of the user’s actual question or imperative, not language found in quoted text, code, tool output, examples, or prior assistant messages.
- For mixed-language input, use the language carrying the main request. Do not switch languages without evidence in the request or applicable project rules.
- Keep code, identifiers, commands, and exact error strings unchanged unless translation is requested.
- Apply separate language rules for code, documents, PRs, and other artifacts when the project specifies them.

## Relationship to compression modes

`caveman` controls terseness and formatting only. It does not decide what to answer or which language to use. If both skills apply, satisfy this skill’s response contract and language rules first, then compress only as far as clarity permits.
