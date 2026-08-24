---
name: bigbrain
description: Automatically route non-trivial software-engineering work through bigbrain's rigorous playbooks, workflow skills, engineering principles, delegation, and verification. Use before planning or editing for features, bug fixes, refactors, performance work, investigations, prototypes, reviews, or multi-step engineering tasks. Skip casual questions and truly trivial one-step edits unless the user asks for rigor.
license: MIT
compatibility: opencode
metadata:
  upstream: cursor/plugins/pstack@46125561306434d8a1d7745d540d8932ab0cd2a2
  port: bigbrain
---

# Bigbrain for OpenCode

This is the native OpenCode entry point. No slash command or sticky mode is required.

For a matching task:

1. Read `references/opencode.md`.
2. Read `references/skills/bigbrain-core/SKILL.md` in full before planning or changing files.
3. Let that router select exactly one playbook. Read only the selected file under `references/skills/bigbrain-core/playbooks/`.
4. When the router names another bigbrain skill, read its file at `references/skills/<skill-name>/SKILL.md` only when its trigger applies.
5. When a principle shapes a decision, read its leaf file at `references/skills/principle-<name>/SKILL.md`. Do not preload all principle leaves.

Paths inside a resource are relative to that resource's directory. Cursor-specific mechanics in upstream-derived resources always resolve through `references/opencode.md`; the compatibility map overrides the old tool or path name without changing the engineering rule.

Do not load every file in `references/`. Progressive disclosure is part of the design.
