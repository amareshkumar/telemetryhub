# Branch Cleanup Guide - TelemetryHub

**Date:** December 23, 2025  
**Repo:** amareshkumar/telemetryhub  
**Total Remote Branches:** ~53

---

## 📋 Quick Actions

### 1. First: Merge PR #83
**URL:** https://github.com/amareshkumar/telemetryhub/pull/83  
**Branch:** `release-v4.1.0`  
**Purpose:** Updates CHANGELOG for v4.1.0 release

**Action:** Click "Merge pull request" button on GitHub

---

### 2. Preview What Will Be Deleted (Safe - No Changes)

```powershell
cd C:\code\telemetryhub
.\preview_branch_cleanup.ps1
```

This shows:
- ✅ Protected branches (never deleted)
- ✅ Active work branches (kept)
- ✅ Unmerged branches (kept)
- ❌ Deletable branches (merged into main)

**Nothing is actually deleted in preview mode!**

---

### 3. Delete Merged Remote Branches

```powershell
cd C:\code\telemetryhub
.\cleanup_remote_branches.ps1
```

You'll be asked to type `DELETE` to confirm.

**Safety:**
- ✅ Only deletes merged branches
- ✅ Local branches NOT affected
- ✅ Protected branches (main, backups) NOT deleted
- ✅ Active work (day17-clean, release-v4.1.0) NOT deleted

---

## 🛡️ What's Protected

### Never Deleted
- `main` - Primary branch
- `main-backup` - Backup branch
- `main-cleanup` - Cleanup branch
- `release-v4.1.0` - Active PR #83
- `day17-clean` - Current work

### Only Deletes
- Branches already merged into `main`
- Branches no longer needed (old day branches, experimental branches)

---

## 📊 Expected Results

**Before cleanup:** ~53 remote branches  
**After cleanup:** ~10-15 branches (active + protected only)

**Examples of what will be deleted:**
- Old day branches (day10, day11, day12, etc.) - already merged
- Experimental branches - already merged
- Hotfix branches - already merged

**Local branches:**
- ✅ All local branches stay intact
- ✅ You can still access old branches locally
- ✅ Only remote (GitHub) branches are cleaned

---

## 🔍 Verify Local Branches Are Safe

```powershell
# Before cleanup
git branch | Measure-Object
# Example: 25 branches

# After cleanup  
git branch | Measure-Object
# Should still be 25 branches!
```

---

## 📚 Learning: Why Clean Up Branches?

**Benefits:**
1. **Clarity:** Easier to see active work
2. **Organization:** GitHub UI less cluttered
3. **Professional:** Shows good repo hygiene
4. **Safety:** Merged branches are in main anyway

**Git Concept:**
- Remote branches are just pointers
- Deleting them doesn't lose commits
- Commits are safe in `main` after merge
- Local branches completely independent

---

## 🚨 Troubleshooting

### "Branch not found" error
**Cause:** Branch already deleted or doesn't exist  
**Action:** Safe to ignore, script continues

### "Permission denied" error
**Cause:** Not authenticated to GitHub  
**Action:** Run `gh auth login` or check GitHub credentials

### Want to undo?
**Can't undo remote deletion**, but:
1. Local branches still exist
2. Commits are in `main` history
3. Can recreate branch: `git checkout -b old-branch <commit-hash>`

---

## ✅ Checklist

- [ ] Merge PR #83 (release-v4.1.0)
- [ ] Run preview script (`preview_branch_cleanup.ps1`)
- [ ] Review list of branches to delete
- [ ] Run cleanup script (`cleanup_remote_branches.ps1`)
- [ ] Type `DELETE` to confirm
- [ ] Verify local branches intact: `git branch`

---

## 🎓 Interview Talking Point

**Question:** "How do you manage branches in a long-running project?"

**Answer:**
> "I regularly clean up merged branches to keep the repository organized. I use scripts to identify branches already merged into main, then delete only those from the remote while keeping local branches intact. This demonstrates good DevOps hygiene and makes it easier for team members to see active work. I always use `--merged` flag to ensure only safe branches are deleted."

---

## 📝 Notes

- This is a one-time cleanup to organize 53 branches
- Going forward: Delete branches after PR merge
- Use GitHub PR option: "Delete branch" after merge
- Keep `day##-clean` branches for major milestones
