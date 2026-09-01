# Notice

This repository is an OpenCode port of [pstack](https://github.com/cursor/plugins/tree/main/pstack), created by Lauren Tan and distributed under the MIT License.

The vendored pstack snapshot is based on `cursor/plugins` commit `46125561306434d8a1d7745d540d8932ab0cd2a2`, pstack version `0.14.2`, retrieved on 2026-08-24. The original license is preserved in `LICENSE`.

Bigbrain adds the OpenCode compatibility map, native agent definitions, installer, validation scripts, and documentation. Upstream workflow and principle skills are retained as direct entries under `.opencode/skills/`; playbooks, references, and helper scripts remain with their owning skills. Cursor-specific runtime names are interpreted through the compatibility map. The optional Benny automation pack is preserved under `.opencode/skills/bigbrain/references/automations/` but is not registered automatically because OpenCode has no equivalent native event-automation package format.
