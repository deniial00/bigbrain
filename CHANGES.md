# Port changes

Compared with upstream pstack `0.14.2`:

- One OpenCode skill named `bigbrain` is discoverable. Other workflows and all principle leaves are internal resources.
- A 44-word managed bootstrap activates bigbrain automatically for non-trivial engineering work.
- `poteto-agent` became the native OpenCode subagent `bigbrain`; Comment Sicko became a read-only OpenCode subagent.
- Cursor tool names, model slugs, paths, built-ins, and companion-plugin assumptions resolve through one compatibility map.
- OpenCode owns model selection. No custom orchestration or role-to-model layer was added.
- No slash command is required. The adapted upstream router remains the core resource behind the `bigbrain` entry skill.
- The optional Benny automation sources are retained but not installed or activated.
