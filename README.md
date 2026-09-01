# Bigbrain for OpenCode

A native OpenCode port of [Lauren Tan's pstack](https://github.com/cursor/plugins/tree/main/pstack). Bigbrain keeps pstack's playbooks, workflow skills, engineering principles, and verification discipline, without Oh My OpenCode or a slash command.

## Install

```bash
git clone https://github.com/deniial00/bigbrain.git
cd bigbrain
./install.sh
```

Restart OpenCode. The default install is global and uses symlinks, so keep the checkout in place. Pull updates in the checkout when you want a newer version.

To install a copy into one repository instead:

```bash
./install.sh --project /path/to/repository
```

To remove a managed installation:

```bash
./install.sh --uninstall
```

The installer refuses to overwrite or remove an existing skill or agent it did not create.

## Architecture

| Layer | OpenCode mechanism | Loaded when |
| --- | --- | --- |
| Activation | A small managed block in global or project `AGENTS.md` | Every session |
| Router | Native `bigbrain` skill | Non-trivial engineering tasks |
| Playbook | One of 23 original playbooks | After task classification |
| Workflows and principles | 43 additional native OpenCode skills | Only when their triggers apply |
| Delegation | Native `bigbrain` and `comment-sicko` subagents | When a playbook delegates or reviews comments |

All 44 pstack-derived skills are direct entries under `.opencode/skills/`, matching the upstream plugin structure. OpenCode exposes only each skill's name and description during discovery. It loads the full `SKILL.md` body on demand through the native skill tool. The 21 principle leaves and workflow bodies therefore remain progressively disclosed while every skill can also be invoked directly.

No custom plugin or orchestrator is installed. [OpenCode already provides on-demand Agent Skills](https://opencode.ai/docs/skills/), [global and project instructions](https://opencode.ai/docs/rules/), and [native subagents](https://opencode.ai/docs/agents/). Those mechanisms cover the port cleanly.

OpenCode controls model selection. The bundled agents inherit the configured model by default. You can pin a native `provider/model` through OpenCode's normal agent configuration; the port never injects Cursor model slugs.

## Inspect loaded skills

Run `/details` in the OpenCode TUI to show tool executions. A skill was loaded only when a `skill` tool call with its name appears. Presence in the available-skills list means the skill was discovered, not loaded.

For a previous session, list and export it as JSON, then inspect its `skill` tool calls:

```bash
opencode session list
opencode export <session-id> > session.json
```

See [OpenCode's TUI commands](https://opencode.ai/docs/tui/) and [CLI session export](https://opencode.ai/docs/cli/).

## Verify

```bash
./scripts/validate.sh
```

The validation checks all native skill frontmatter and discovery paths, upstream resource counts, agent frontmatter, idempotent installation, project installation, and uninstall safety.

## Upstream and scope

The vendored source tracks pstack `0.14.2` at `cursor/plugins` commit `46125561306434d8a1d7745d540d8932ab0cd2a2`. See [NOTICE.md](NOTICE.md) and [CHANGES.md](CHANGES.md).

The optional Benny automation pack is preserved under the skill resources for completeness, but the installer does not activate it. It targets Cursor's event automation runtime, for which OpenCode has no equivalent native package format.
