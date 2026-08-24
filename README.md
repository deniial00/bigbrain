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
| Router | `.opencode/skills/bigbrain/SKILL.md` | Non-trivial engineering tasks |
| Core | Adapted pstack router as the internal `bigbrain-core` resource | After the router matches |
| Playbook | One of 23 original playbooks | After task classification |
| Workflows and principles | Original internal skill resources | Only when their triggers apply |
| Delegation | Native `bigbrain` and `comment-sicko` subagents | When a playbook delegates or reviews comments |

Only `bigbrain` is exposed through OpenCode's skill discovery. The other 44 skills and 21 principle leaves stay inside its resource tree. This avoids putting every skill description in the tool context while preserving direct, on-demand access.

No custom plugin or orchestrator is installed. [OpenCode already provides on-demand Agent Skills](https://opencode.ai/docs/skills/), [global and project instructions](https://opencode.ai/docs/rules/), and [native subagents](https://opencode.ai/docs/agents/). Those mechanisms cover the port cleanly.

OpenCode controls model selection. The bundled agents inherit the configured model by default. You can pin a native `provider/model` through OpenCode's normal agent configuration; the port never injects Cursor model slugs.

## Verify

```bash
./scripts/validate.sh
```

The validation checks discovery boundaries, upstream resource counts, agent frontmatter, idempotent installation, project installation, and uninstall safety.

## Upstream and scope

The vendored source tracks pstack `0.14.2` at `cursor/plugins` commit `46125561306434d8a1d7745d540d8932ab0cd2a2`. See [NOTICE.md](NOTICE.md) and [CHANGES.md](CHANGES.md).

The optional Benny automation pack is preserved under the skill resources for completeness, but the installer does not activate it. It targets Cursor's event automation runtime, for which OpenCode has no equivalent native package format.
