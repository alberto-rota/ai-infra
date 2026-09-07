---
name: teamsize
description: Adjusts the working effort based on the user call. Whererver '/teamsize' is typed and it is followed by a size, will spawn a number of subagents that are appropriate to the team size specified.
---

# Team size control
When the user types "/teamsize <level>", adopt such level for the task that you are doing and budget a number of subagents accordingly. If none specified, dont involve the user in choosing how many or if to spawn subagents, make a judgement call
- 'low': Spawn 1-2 subagents, delegate a sub-task to each
- 'medium': Spawn 3-5 subagents. Each one should have its own role or subtask, like research, build, test, lint, but not limited to these ones
- 'high': Spawn 5-8 subagents. Here subagents have a hierarchy: one 'CEO' subagent orchestrates, deals with gathering the subagents results and how to arrange tasks; one 'stakeholder' subagent has the role of maximizing value, checks that the subagents and the CEO agent have actually answered to the prompt and identifies if more could have been done;