# Harness Workflow - User Guide

**Quick Start Guide for Long-Running Agent Development**

---

## 🎯 Core Concept

Work on **ONE feature at a time** with explicit verification. Each session is self-contained and documented.

---

## 📋 Session Workflow (5 Steps)

### **Step 1: Session Startup** (2 min)
```bash
# Verify location
pwd

# Read what was done before
cat claude-progress.txt

# Check recent work
git log --oneline -5

# Setup environment
./init.sh

# Validate current state
flutter analyze
flutter test
```

### **Step 2: Select Feature** (1 min)
```bash
# Open features.json
# Find first feature with "passes": false
# Read verification steps
```

**Example**:
```json
{
  "id": "F005",
  "description": "Set up Dio HTTP client with interceptors",
  "verification": [
    "lib/core/network/dio_client.dart exists",
    "Dio configured with base URL from environment",
    "AuthInterceptor adds Bearer token to requests"
  ],
  "passes": false  ← Work on this
}
```

### **Step 3: Implement Feature** (20-40 min)
```bash
# Create/edit files following Clean Architecture
# Write code for F005 only (don't jump to F006!)

# Example: Creating Dio client
touch lib/core/network/dio_client.dart
# ... implement DioClient class ...

# Write tests
touch test/core/network/dio_client_test.dart
# ... write unit tests ...
```

### **Step 4: Verify Feature** (5 min)
```bash
# Run verification steps from features.json

# Check 1: File exists?
ls lib/core/network/dio_client.dart  ✓

# Check 2: Dio configured?
grep "BaseOptions" lib/core/network/dio_client.dart  ✓

# Check 3: AuthInterceptor present?
grep "AuthInterceptor" lib/core/network/dio_client.dart  ✓

# Run tests
flutter test test/core/network/dio_client_test.dart  ✓

# If ALL checks pass, proceed. If ANY fail, fix before continuing.
```

### **Step 5: Session Cleanup** (3 min)
```bash
# Commit
git add lib/core/network/dio_client.dart test/core/network/
git commit -m "feat: implement Dio HTTP client with auth interceptor (F005)"

# Update features.json
# Change F005 "passes": false → "passes": true

# Update claude-progress.txt
echo "## Session 2 - $(date +"%Y-%m-%d")" >> claude-progress.txt
echo "- ✓ Completed F005: Dio HTTP client setup" >> claude-progress.txt
echo "- Git commit: $(git rev-parse --short HEAD)" >> claude-progress.txt
echo "- Next: F006 - Network connectivity checker" >> claude-progress.txt

# Push (optional but recommended)
git push
```

---

## 📖 Practical Example: Complete Session

**Goal**: Implement F020 - LoginTrainer Use Case

### 1. **Startup**
```bash
$ pwd
/home/user/personal-trainer-app

$ cat claude-progress.txt
Session 3 - 2025-12-10
- Completed F004, F005, F006
- Next: F020

$ git log --oneline -3
abc123d feat: implement network info checker (F006)
def456e feat: implement Dio client (F005)
...

$ ./init.sh
✓ Flutter 3.19.0
✓ Dependencies installed
✓ Ready to develop! 🚀

$ flutter analyze
No issues found!

$ flutter test
All tests passed!
```

### 2. **Select Feature**
```bash
# Open features.json, find F020:
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
  "passes": false  ← This is our target
}
```

### 3. **Implement**
```bash
# Create directory structure
mkdir -p lib/features/auth/domain/usecases
mkdir -p test/features/auth/domain/usecases

# Create use case
cat > lib/features/auth/domain/usecases/login_trainer.dart <<'EOF'
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/trainer.dart';
import '../repositories/auth_repository.dart';

class LoginTrainer {
  final AuthRepository repository;

  LoginTrainer(this.repository);

  Future<Either<Failure, Trainer>> call(String email, String password) async {
    return await repository.loginTrainer(email, password);
  }
}
EOF

# Create test
cat > test/features/auth/domain/usecases/login_trainer_test.dart <<'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// ... (full test implementation)

void main() {
  group('LoginTrainer', () {
    test('should call repository.loginTrainer', () async {
      // Test implementation
    });
  });
}
EOF
```

### 4. **Verify**
```bash
# Verification Step 1: File exists?
$ ls lib/features/auth/domain/usecases/login_trainer.dart
lib/features/auth/domain/usecases/login_trainer.dart  ✓

# Verification Step 2: Accepts email and password?
$ grep "String email, String password" lib/features/auth/domain/usecases/login_trainer.dart
Future<Either<Failure, Trainer>> call(String email, String password)  ✓

# Verification Step 3: Returns Either<Failure, Trainer>?
$ grep "Either<Failure, Trainer>" lib/features/auth/domain/usecases/login_trainer.dart
Future<Either<Failure, Trainer>> call  ✓

# Verification Step 4: Calls repository?
$ grep "repository.loginTrainer" lib/features/auth/domain/usecases/login_trainer.dart
return await repository.loginTrainer(email, password);  ✓

# Verification Step 5: Unit test exists and passes?
$ flutter test test/features/auth/domain/usecases/login_trainer_test.dart
✓ All tests passed!  ✓

# ALL 5 CHECKS PASSED ✓
```

### 5. **Cleanup**
```bash
# Commit
$ git add lib/features/auth/domain/usecases/ test/features/auth/domain/usecases/
$ git commit -m "feat: implement LoginTrainer use case (F020)"
[main 789xyz1] feat: implement LoginTrainer use case (F020)
 2 files changed, 45 insertions(+)

# Update features.json (change F020 passes to true)
# Edit with your editor or use sed:
$ sed -i 's/"id": "F020",.*"passes": false/"id": "F020",\n    "passes": true/' features.json

# Update claude-progress.txt
$ cat >> claude-progress.txt <<EOF

## Session 4 - 2025-12-10 14:30
**Goal**: Implement LoginTrainer use case (F020)

**Completed**:
- ✓ Created LoginTrainer use case in domain layer
- ✓ All 5 verification steps passed
- ✓ Unit test written and passing

**Git Commits**:
- 789xyz1: feat: implement LoginTrainer use case (F020)

**Next Session**:
- F021: Create SendMagicLink use case
EOF

# Push
$ git push
```

**Session Complete! ✓** (30 minutes total)

---

## ⚠️ Common Mistakes

### ❌ **DON'T DO THIS**
```bash
# Working on multiple features at once
# Implementing F020, F021, F022 in one session
git commit -m "feat: add all auth use cases"
# Result: Incomplete features, hard to debug
```

### ✅ **DO THIS**
```bash
# One feature per session
# Complete F020 fully
# Verify all steps
git commit -m "feat: implement LoginTrainer use case (F020)"
# Result: Complete, tested, verified feature
```

---

### ❌ **DON'T DO THIS**
```bash
# Skip verification steps
# "It looks good, ship it!"
# Update features.json without checking
```

### ✅ **DO THIS**
```bash
# Run ALL verification steps
ls lib/features/auth/domain/usecases/login_trainer.dart  ✓
grep "Either<Failure, Trainer>" ...  ✓
flutter test test/.../login_trainer_test.dart  ✓
# Only then update features.json
```

---

### ❌ **DON'T DO THIS**
```bash
# Skip session startup
# Start coding immediately
# Forget to update progress files
```

### ✅ **DO THIS**
```bash
# Always start with:
pwd
cat claude-progress.txt
git log --oneline -5
./init.sh
flutter analyze && flutter test
# Then code
```

---

## 🎓 Pro Tips

### **Tip 1: Session Time Budget**
- Startup: 2 min
- Feature selection: 1 min
- Implementation: 20-40 min
- Verification: 5 min
- Cleanup: 3 min
- **Total: 30-50 min per feature**

### **Tip 2: When Verification Fails**
```bash
# If ANY verification step fails:
1. Don't update features.json
2. Fix the issue
3. Re-run verification
4. Only mark "passes": true when ALL steps pass
```

### **Tip 3: Complex Features**
```bash
# If a feature seems too big (>1 hour):
1. Break it into sub-features
2. Add to features.json with new IDs (F020a, F020b)
3. Work on one sub-feature at a time
```

### **Tip 4: Debugging**
```bash
# If tests fail during startup validation:
1. Check git log - what was the last working commit?
2. Check claude-progress.txt - what was completed last?
3. Run: git diff HEAD~1
4. Fix before implementing new features
```

### **Tip 5: Context Switching**
```bash
# Returning after days/weeks?
1. Read claude-progress.txt (recent sessions)
2. Read features.json (what's done/remaining)
3. git log --oneline -10 (recent work)
4. ./init.sh (reset environment)
5. flutter analyze && flutter test (validate state)
# Now you're caught up! Resume work.
```

---

## 📊 Quick Reference

### **Session Checklist**
```
□ pwd - verify directory
□ cat claude-progress.txt - read previous work
□ git log --oneline -5 - check commits
□ ./init.sh - setup environment
□ flutter analyze - validate code
□ flutter test - run tests
□ Select ONE feature from features.json
□ Implement feature following Clean Architecture
□ Run ALL verification steps
□ Write/update tests
□ git commit with feature ID
□ Update features.json: "passes": true
□ Update claude-progress.txt with summary
□ git push
```

### **File Priority**
1. **features.json** - What to build (read first)
2. **claude-progress.txt** - What was done (update every session)
3. **CLAUDE.md** - How to build (reference as needed)
4. **plan.md** - Why we're building (context)

### **Key Commands**
```bash
# Startup
./init.sh && flutter analyze && flutter test

# Check status
cat claude-progress.txt | tail -20
git log --oneline -5

# Verify feature
flutter test test/path/to/feature_test.dart

# Commit
git add . && git commit -m "feat: description (F0XX)"

# Update progress
echo "- ✓ Completed F0XX: description" >> claude-progress.txt
```

---

## 🎯 Success Metrics

You're doing it right if:
- ✓ Each session completes 1 feature (occasionally 2 if simple)
- ✓ All verification steps pass before committing
- ✓ claude-progress.txt is updated after every session
- ✓ Git history shows descriptive commits with feature IDs
- ✓ Tests are passing before and after your work
- ✓ features.json accurately reflects completed work

You need to adjust if:
- ✗ Working on 3+ features per session (too broad)
- ✗ Committing without verification (quality issues)
- ✗ Skipping startup validation (compounding bugs)
- ✗ Not updating progress files (lost context)
- ✗ Verification steps failing but marked "passes": true (broken features)

---

## 📞 Need Help?

**Q: Feature verification is failing, what do I do?**
A: Don't mark it as complete. Fix the issue, re-verify, then commit.

**Q: Can I work on multiple features if they're related?**
A: Only if they're sub-features of one main feature. Keep scope tight.

**Q: What if I find a bug in a previous feature?**
A: Log it in `doc/bug.md`, fix it as a separate commit, update features.json if needed.

**Q: Session ran over 1 hour, is that okay?**
A: Feature might be too large. Break it down into sub-features next time.

**Q: Can I skip startup validation if I just ran it?**
A: If it's the same session, yes. But always run it at the START of a new session.

---

## 🚀 Next Steps

1. **Read this guide** ✓
2. **Run**: `./init.sh`
3. **Open**: `features.json`
4. **Find**: First feature with `"passes": false`
5. **Implement**: Following the 5-step workflow
6. **Repeat**: One feature at a time until project complete

**Good luck! 🎉**

---

**Reference**: Based on [Anthropic's Long-Running Agent Harness Research](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
