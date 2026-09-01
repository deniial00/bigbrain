---
name: setup-bigbrain
description: Configure bigbrain's native OpenCode subagent models. Use when the user asks to configure bigbrain models.
---

# Setup bigbrain for OpenCode

OpenCode owns model selection. Do not create a second role-to-model router.

## Steps

1. Run `opencode models` when the CLI is available. Otherwise inspect the models exposed by the current OpenCode session. Never invent a model slug.
2. Read the effective OpenCode configuration and the installed `bigbrain` and `comment-sicko` agent definitions.
3. Ask whether the user wants those agents to inherit the parent model or pin a verified `provider/model` slug. Inheritance is the default.
4. Apply the choice through OpenCode's native `agent` configuration. Preserve unrelated configuration and existing permissions. Do not write Cursor rules or Cursor model names.
5. Validate the resulting OpenCode configuration, then report which agents inherit and which are pinned.

Multi-model panels use distinct native OpenCode agents or models only when the runtime exposes them. If one model is available, keep the independent review prompts and state that model diversity is reduced.
