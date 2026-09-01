# OpenCode compatibility

The bundled bigbrain resources come from the Cursor plugin. Preserve their engineering intent while translating runtime mechanics as follows.

## Native primitives

| Upstream wording | OpenCode behavior |
| --- | --- |
| Legacy mode or slash invocation | The already-loaded `bigbrain` skill. No slash command or sticky mode is required. |
| Invoke a named bigbrain skill | Load the named native OpenCode skill with the `skill` tool and follow it. |
| `Task` or dispatch an agent | Use OpenCode's native task/subagent mechanism. Use the bundled `bigbrain` subagent for implementation delegates that must inherit the full method. |
| `generalPurpose` | Use OpenCode's `general` subagent. Use `explore` for read-only repository exploration and `scout` for external source research. |
| `run_in_background: true` | Run independent tasks concurrently when the available task tool supports it. Otherwise run them sequentially without changing the review or verification bar. |
| `AskQuestion` | Use OpenCode's `question` tool only for a genuine product or preference decision that evidence cannot settle. |
| todolist / `TodoWrite` | Use OpenCode's native todo tool. Copy the selected playbook steps without silently dropping any. |
| Cursor model slug or `model:` argument | Never pass an unverified Cursor slug. Inherit OpenCode's configured model by default. Respect native per-agent model configuration when present. |
| Cursor MCP discovery | Inspect the tools available in the current OpenCode session. Do not assume a connector exists. |
| `.cursor/skills` | `.opencode/skills` for project-local installation or `~/.config/opencode/skills` for global installation. Every bundled workflow and principle is a direct native skill. |
| Cursor rules | `AGENTS.md` or OpenCode's `instructions` configuration. |

## Built-ins and companion plugins

bigbrain for OpenCode has no required companion plugin.

- Skill authoring uses the bundled Authoring a skill playbook plus OpenCode's Agent Skills format.
- CLI, TUI, browser, Electron, or IDE verification uses the real tools available in the session. If no driver exists, state the limitation and provide a concrete manual check. Never claim live verification that did not happen.
- Before commit, inspect the diff directly. Apply `no-comments` to code comments and `unslop` to prose. The Cursor-only `deslop`, `control-cli`, and `control-ui` dependencies are not required.
- PR monitoring uses the Babysit playbook and the repository tools or `gh` available in the environment. Cursor Bugbot-specific guidance applies only when those comments exist.

## Delegation and models

The `bigbrain` and `comment-sicko` agents are native files under `.opencode/agents/`. OpenCode owns their model and permission configuration. The port does not add a second model router.

For a multi-model panel, use distinct configured OpenCode agents or models when the runtime exposes them. If only one model is available, keep the independent prompts and disclose that model diversity was reduced. Ownership remains with the parent agent. Review every delegated result and verify the combined change.

## Precedence

Direct user instructions, repository instructions, OpenCode permissions, and safety constraints take precedence over autonomy language in the upstream resources.
