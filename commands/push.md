---
description: Sync the local repo state to the remote, whatever it takes, with as few disruptions as possible to the repo and branch states
agent: build
---

The repo you are working in must be pushed to the remote. Add, commit with the "Update <datetime>" and push. Create the upstream branch if it does not exist. If the local is behind of the origin, or if anything would cause merge conflicts to be resolved, make sure that it does not happend but the new changes here get pushed to the remote. If adding takes a long time or if by default the commit is too big to be pushed, ask the user what do to, preferrably with a multiple choice question"