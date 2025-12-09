# Long-Running Agent Harness Improvements

## Overview
Based on Anthropic's research on "Effective Harnesses for Long-Running Agents", this document summarizes the improvements made to the Personal Trainer App project structure.

**Source**: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents

---

## Key Changes Implemented

### 1. Granular Feature List (`features.json`)
**Problem**: High-level prompts lead to incomplete or buggy implementations.

**Solution**: Created `features.json` with 46 granular, testable features.

**Benefits**:
- Each feature has explicit verification steps
- Features are small enough to complete in one session
- Status tracking with `"passes": true/false` flag
- Prevents premature "project complete" declarations

**Example Feature**:
```json
{
  "id": "F020",
  "category": "Authentication - Domain",
  "description": "Create LoginTrainer use case",
  "verification": [
    "lib/features/auth/domain/usecases/login_trainer.dart exists",
    "Accepts email and password parameters",
    "Returns Either<Failure, Trainer>",
    "Calls authRepository.loginTrainer()",
    "Unit test verifies use case calls repository"
  ],
  "passes": false
}
```

### 2. Session-Based Progress Tracking (`claude-progress.txt`)
**Problem**: Agents have no memory across sessions.

**Solution**: Session log file updated after each session.

**Content**:
- Session date/time
- Goals for the session
- Features completed
- Blockers encountered
- Git commits made
- Next session plans

**Why**: Allows subsequent agent sessions to quickly understand context and continue from where previous session left off.

### 3. Environment Initialization Script (`init.sh`)
**Problem**: Time wasted on environment setup in each session.

**Solution**: Automated bash script that:
- Verifies Flutter installation and version
- Installs dependencies
- Creates environment file templates
- Initializes git if needed
- Lists available devices
- Provides next steps

**Usage**: Run at the start of every session to ensure consistent environment.

### 4. Mandatory Session Workflow (in `CLAUDE.md`)
**Problem**: Agents skip validation and work on multiple features simultaneously.

**Solution**: Enforced workflow pattern in CLAUDE.md:

```bash
# Every session MUST start with:
1. pwd                          # Verify directory
2. cat claude-progress.txt      # Read previous work
3. git log --oneline -10        # Check recent commits
4. ./init.sh                    # Setup environment
5. flutter analyze && flutter test  # Startup validation
6. Check features.json          # Select next feature
```

**One Feature Per Session Rule**:
- NEVER work on multiple features
- ALWAYS complete verification steps
- COMMIT immediately after completion
- UPDATE progress files

### 5. Startup Validation
**Problem**: Undocumented bugs compound over time.

**Solution**: Every session begins with:
```bash
flutter analyze    # Static analysis
flutter test       # Run existing tests
```

**Why**: Catches bugs immediately rather than discovering them later when they've cascaded into multiple features.

### 6. Session End Checklist (in `CLAUDE.md`)
**Problem**: Features marked complete without proper verification.

**Solution**: Mandatory checklist:
1. ✓ Feature verification steps completed
2. ✓ Tests written/updated
3. ✓ Git commit with descriptive message
4. ✓ Update features.json: `"passes": true`
5. ✓ Update claude-progress.txt
6. ✓ Push to remote (if appropriate)

### 7. Testing Automation Guidance
**Problem**: Agents declare features complete without testing when tools aren't provided.

**Solution**:
- Explicit testing requirements in `features.json` verification steps
- Unit test requirements for domain layer (80% coverage)
- Widget test requirements for all screens
- Integration test requirements for critical flows

**Research Finding**: When provided with browser automation tools (like Puppeteer), agents properly tested features. Applied this principle by making testing explicit and tool-based.

### 8. Git as Source of Truth
**Problem**: Conflicting information about what's been done.

**Solution**:
- Git commits serve as authoritative record
- Descriptive commit messages required
- One feature = one commit
- `git log` checked at session start

### 9. Structured Documentation Hierarchy
**Problem**: Unclear where to find information.

**Solution**: Clear file structure:

**Project Management** (Read First):
- `features.json` - What to implement (SOURCE OF TRUTH)
- `claude-progress.txt` - Session log (UPDATE every session)
- `init.sh` - Environment setup (RUN every session)

**Documentation**:
- `plan.md` - Implementation plan
- `CLAUDE.md` - Development guidelines
- `doc/progress.md` - Milestone tracking
- `doc/decision.md` - ADRs
- `doc/bug.md` - Bug tracking

### 10. Protection Against Data Loss
**Problem**: Premature deletion of code/tests.

**Solution**:
- `.gitignore` configured for sensitive files only
- Warning in `features.json`: "Never remove or edit tests"
- Database migration warnings in CLAUDE.md
- Git revert strategy for problematic changes

---

## Research Findings Applied

### Two-Agent System
**Research**: Decompose into Initializer + Coding agents.

**Our Implementation**:
- `init.sh` acts as the "initializer" (run once per session)
- Development follows the "coding agent" pattern (incremental features)

### Incremental Execution
**Research**: Agents fail when attempting large-scale implementations.

**Our Implementation**: One feature per session rule enforced in CLAUDE.md

### Feature List Structure
**Research**: 200+ granular features with step-by-step verification.

**Our Implementation**: 46 features for MVP, each with explicit verification steps

### Error Detection
**Research**: Startup validation catches undocumented bugs.

**Our Implementation**: Mandatory `flutter analyze && flutter test` before starting work

### Self-Verification
**Research**: Agents need explicit testing tools.

**Our Implementation**: Testing requirements embedded in feature verification steps

---

## Comparison: Before vs. After

| Aspect | Before (Plan-Based) | After (Harness-Based) |
|--------|-------------------|---------------------|
| **Feature Granularity** | High-level phases | 46 granular features with verification |
| **Session Memory** | None | claude-progress.txt + git log |
| **Startup** | Ad-hoc | Automated with init.sh |
| **Validation** | Optional | Mandatory (analyze + test) |
| **Feature Completion** | Subjective | Explicit verification steps |
| **Testing** | Mentioned | Required with explicit steps |
| **Progress Tracking** | doc/progress.md | claude-progress.txt + features.json + doc/progress.md |
| **Session Scope** | Undefined | One feature per session |
| **Error Recovery** | Reactive | Proactive (startup validation) |

---

## Expected Outcomes

Based on Anthropic's research, these changes should result in:

1. **Fewer Bugs**: Startup validation catches issues early
2. **Better Continuity**: Progress tracking enables seamless session handoffs
3. **Complete Features**: Explicit verification prevents premature completion
4. **Incremental Progress**: One-feature-per-session prevents overwhelm
5. **Proper Testing**: Testing requirements embedded in features
6. **Clear State**: Git + progress files provide authoritative state

---

## Future Improvements (From Research)

The Anthropic article mentions unexplored improvements:

1. **Specialized Agents**:
   - Testing agent (QA)
   - Code cleanup agent (refactoring)
   - Documentation agent

2. **Enhanced Testing**:
   - Browser automation for Flutter (patrol/integration_test)
   - Visual regression testing
   - Performance benchmarking

3. **Conflict Resolution**:
   - Better offline sync conflict handling
   - Merge strategy automation

4. **Advanced Verification**:
   - E2E test automation
   - Security scanning integration
   - Accessibility compliance checks

---

## References

- **Original Article**: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- **Project Files**:
  - `features.json` - Feature list with verification
  - `claude-progress.txt` - Session log
  - `init.sh` - Environment setup
  - `CLAUDE.md` - Agent workflow section

---

## Conclusion

These improvements transform the project from a simple "plan document" approach into a structured harness optimized for long-running agent development. The key insight from Anthropic's research is that **agents need explicit structure, granular tasks, and verification mechanisms** to succeed across multiple sessions.

**Next Steps**: Follow the session workflow in CLAUDE.md, starting with feature F001 from features.json.
