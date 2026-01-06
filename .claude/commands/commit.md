---
allowed-tools: Bash(git add :*), Bash(git commit :*), Bash(git push :*), Bash(git push origin main), Bash(git branch)
description: Create commits following comitizen cenventions with simple one line messages. IMPORTANT The commit message must only include files that are committed. Also, before proceed commit, identify irrelevant files, prompt user if he want to include them or not in the incoming commit. Also, identify if any of the ./.claude/rules/ files need to be updated before commit.
---
1. If the current branch is the main, warn the user and ask for confirmation to proceed.
2. Identify unnecessary uncommited files.
3. Update .claude/rules/ files if needed.
4. Prompt user if he wants to include unnecessary files to incoming commit.
5. Add the desired files into a commit.
6. Commit following Comitizen, keep commit simple, concise and short.
7. Push.