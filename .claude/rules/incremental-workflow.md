# Summary: Setting Up a Project with Claude Code Using the Incremental Workflow

This video explains a workflow for using AI agents (Claude Code) to build a project efficiently, inspired by real software engineering teams. The method focuses on overcoming AI context limitations and ensuring proper testing.

---

## Key Concepts
- **Problem with AI agents**: Limited context windows cause agents to forget progress in large tasks. Agents may also mark untested features as complete.
- **Solution**: Use an **initializing agent** and a **coding agent** workflow to manage projects incrementally, similar to how real dev teams work.

---

## Project Setup Steps

### 1. Initialize the Project
- Start with an empty project (e.g., Next.js).
- Create a `claude.md` file using the `init` command:
  - This file documents the codebase and contains an overview of the project.

### 2. Define Features
- Generate a **features JSON** in the project route:
  - Lists all features.
  - Includes corresponding **testing steps**.
  - All tests are initially marked as failing (`false`) to force proper testing.

### 3. Testing Setup
- Use **Puppeteer** to allow the agent to test the browser interface.
- Create:
  - An **init script** to start the dev server.
  - A **progress tracking file** (`progress.md`) to track project completion.

### 4. Development Guidelines
- Update `progress.md` after each run.
- Test each feature immediately after implementation.
- **Commit to Git regularly**:
  - Each commit must be in a mergeable state.
  - Write clear messages to track progress.
- Features list should not change except marking features as completed.

### 5. Coding Workflow
1. Implement features **one by one** from the features JSON.
2. Test each feature fully using Puppeteer.
3. Update JSON fields from `false` to `true` when feature passes tests.
4. Update `progress.md` with completed features.
5. Commit changes and verify the commit was successful.
6. Resume from the next feature if the session terminates.

### 6. Benefits
- Incremental development ensures progress is tracked and recoverable.
- Reduces risk of marking untested features as complete.
- Allows AI to understand the project via Git logs and progress files.
- Improves context usage compared to one-shot approaches.

---

## Summary
This workflow enables AI agents to build complex projects incrementally, with proper testing and version control, ensuring a reliable and resumable development process. It is inspired by real-world software team practices and addresses the context window limitations of AI agents.

