---
allowed-tools: Bash(git add :*), Bash(git commit :*), Bash(git push :*), Bash(git push origin main), Bash(git branch)
description: Create commits following comitizen cenventions with simple one line messages. IMPORTANT The commit message must only file that are commited. Also, before proceed commit, identify irrelevant files, prompt user if he want to include them or not in the incomming commit.
---
1. If the current branch is the main, warn the user and ask for confirmation to proceed.
2. Identify unnecessary uncommited files.
3. Prompt user if he wants to include unnecessary files to incoming commit.
4. Add the desired files into a commit.
5. Commit following Comitizen, keep commit simple, concize and short.
6. Push.
