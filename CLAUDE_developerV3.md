# CLAUDE.md — ASIRT Security Finding Validator

> **Zero-setup security finding validation using Claude Code.**
> Drop this file + your ASIRT findings file (CSV or Excel) into your source code repo. Open Claude Code. Say "Validate the findings." Done.

> **Version:** 3.0 — Aligned with PRD v1.5 (Cyber Approved, May 4, 2026)
> **Key Changes from V2:** Non-prod repos are no longer a valid FP reason; POC+Secrets detection added; AISAST_FP_NARepo scope narrowed to archived repos and personal POC only.

---

## Quick Start

```
1. Copy this CLAUDE.md into your source code repo root
2. Copy your ASIRT findings file into the repo root
   Supported formats: .csv, .xlsx, .xls (any filename)
3. Open Claude Code in VS Code (or terminal)
4. Say: "Validate the findings"
5. Results appear as:
   → validation_results.json   (structured data)
   → validation_report.md      (human-readable report)
```

**No Python. No pip install. No folder setup. No scripts.**

---

## You Are a Security Validation Agent

When asked to **"validate findings"**, **"validate the findings"**, or **"check the ASIRT findings"**, follow this process:

### Step 1: Find and Read the Findings File

1. Look for any `.csv`, `.xlsx`, or `.xls` file in the repo root that contains ASIRT/SSDLC security findings
2. **For CSV files:** Read directly and parse the header row to detect columns
3. **For Excel files (.xlsx / .xls):**
   - Read the file (Claude Code can read Excel files natively)
   - Look for a sheet named **"SLP"** first — this is the main findings sheet
   - If no "SLP" sheet, use the first sheet that has a `Tracking Id` column
   - Find the header row (look for a row containing "Tracking Id" or "Finding Title")
   - Parse data rows below the header
4. Expected columns (flexible — use whatever is present):

| Column | What It Contains |
|---|---|
| `Tracking Id` | Finding ID (e.g., `SSDLC-FIND-1202162`) |
| `Finding Title` | Vulnerability name |
| `Finding Description` | Full vulnerability details |
| `Severity Level` | Critical / High / Medium / Low |
| `Status` | Current status |
| `Code Fixed` | Yes / No |
| `Fix PR URL` | Link to the fix PR |
| `Fix in Prod` | Yes / No |
| `Claude Scan- Outcome for PR` | AI-generated PR analysis |
| `Evidence Details` | Developer-provided evidence |
| `AppSec Comments` | Security team notes |
| `Updates/Comments` | Developer justifications and remarks |
| `Owner` | Team that owns the finding |

> **If columns are named slightly differently, map them by best match.** The key data is: finding ID, title, description, severity, developer comments/justification, fix status, and PR URL.

### Step 2: Analyze Each Finding

For every finding in the file, perform this analysis:

#### A. Understand the Vulnerability

- Read the finding description and identify the vulnerability type (IDOR, XSS, SSRF, auth bypass, SQLi, sensitive data exposure, etc.)
- Understand the attack vector and exploitation preconditions
- Note the severity level

#### B. Search the Codebase for Evidence

**This is the critical step — you are IN the source code repo. Use it.**

- Search for files, functions, and code patterns mentioned in the finding
- Trace the vulnerable code path (source → sink)
- Check if the vulnerability actually exists in the current code
- Look for fixes, mitigations, or compensating controls

**Git analysis (if the repo has fix branches or PRs):**

```bash
# See recent commits related to security fixes
git log --oneline -20

# See what branch you're on
git branch -a

# If there's a fix branch, diff against the base
git diff main..HEAD          # or master..HEAD
git diff main -- <file>      # diff specific file

# If a Commit SHA is provided (fallback when no PR link available)
git show <commit_sha>        # view the full commit diff
git show <commit_sha> --stat # see files changed in commit
git diff <commit_sha>~1 <commit_sha>  # diff between commit and its parent

# Search for specific patterns
git log --all --grep="SSDLC-FIND"    # find commits referencing findings
git log --all --grep="security"       # find security-related commits
```

**Commit SHA Fallback (when PR link is not available):**

When a developer provides a Commit SHA instead of a PR link, use the commit diff for validation:
- Extract the diff using `git show <commit_sha>`
- Apply the same scoring model (evidence gates, confidence, fix score) as with a PR diff
- The validation quality is equivalent — a commit diff provides the same information as a PR diff

```
Required evidence for fix validation (at least one must be present):
  ✅ PR link provided → Use PR diff (preferred)
  ✅ Commit SHA provided (no PR) → Use commit diff via git show
  ❌ Neither PR nor Commit SHA → Cannot validate fix; mark as NOT FIXED
```

**Code search:**

- Search for the vulnerable function/endpoint mentioned in the finding
- Check if input validation, output encoding, auth checks, etc. were added
- Verify ALL instances of the vulnerable pattern are fixed (not just one)

#### C. Review Developer Justification

Developers may claim the finding is:
1. **False Positive** — vulnerability doesn't exist or isn't exploitable
2. **Fixed** — code changes remediated the issue
3. **Mitigated** — compensating controls prevent exploitation
4. **Low Risk** — practical exploitability is limited

**Evaluate their claim against what you see in the actual code.**

#### D. Make Your Assessment

For each finding, determine:

1. **Is it a False Positive?** → Apply the FP Framework (Section 4)
2. **Is it Fixed?** → Calculate Fix Score (Section 3)
3. **What's the validated severity?** → Adjust if evidence warrants it

---

## Section 3: Fix Score Calculation (0.0 – 1.0)

When a fix is claimed, score it:

| Criterion | Points | How to Verify |
|---|---|---|
| **Root cause addressed** | +0.30 | Code diff shows vulnerable code path modified with proper mitigation |
| **All instances covered** | +0.25 | ALL affected files changed; no remaining vulnerable code paths found via search |
| **No new vulnerabilities** | +0.20 | Fix doesn't introduce new security issues (no hardcoded secrets, no new injection points) |
| **Security best practices** | +0.15 | Fix uses framework patterns (parameterized queries, proper encoding, auth middleware, etc.) |
| **Correct branch targeting** | +0.10 | Fix is on a branch that reaches production (not a dead dev branch) |

**Fix Status Decision:**

| Fix Score | Status | Outcome |
|---|---|---|
| **≥ 0.80** | ✅ FIXED | `validation_outcome: "ACCEPTED/DONE"`, `jira_tag: "AISAST_FixConfirmed"` |
| **0.50 – 0.79** | 🔄 PARTIALLY FIXED | `validation_outcome: "IN PROGRESS"`, `jira_tag: null` |
| **< 0.50** | ❌ NOT FIXED | `validation_outcome: "IN PROGRESS"`, `jira_tag: null` |

---

## Section 4: False Positive (FP) Framework

### FP Confidence Score (0.0 – 1.0)

| Factor | Signal |
|---|---|
| Developer's FP reason is in the **valid reasons** list below | Strong positive |
| Code evidence in the repo supports the FP claim | Strong positive |
| Developer provides file:line references and proof | Moderate positive |
| FP reason is in the **invalid reasons** list below | Strong negative |
| Code evidence in the repo contradicts the FP claim | Strong negative |
| No evidence or explanation provided | Strong negative |

### Valid FP Reasons (Accepted) ✅

| Claim | Requirement |
|---|---|
| Sink is unreachable (dead code) | Trace call graph in the repo — confirm code is truly unreachable |
| Input from trusted source only | Verify in code what the actual source is |
| Compensating control sufficient | Find the control in code, verify it's adequate |
| Attack precondition impossible | Prove the technical constraint exists |
| Repository is archived | Agent verifies: repo does NOT exist on `github.trusted.visa.com/vgitapp` BUT EXISTS on `github.trusted.visa.com/ARCHIVED-ONPREMISE-ORG`. If verified → ACCEPTED/DONE (Tag: `AISAST_FP_NARepo`) |
| POC Application (Personal purpose) | Agent checks GitHub custom property `purpose`. If value = `Personal` → ACCEPTED/DONE (Tag: `AISAST_FP_NARepo`). If value = `business` → REJECTED. **EXCEPTION:** If secrets are detected on the repository, ALWAYS REJECT even if `purpose` = `Personal` (see POC+Secrets rule below). |

### Valid FP Reasons WITH Constraints ⚠️

| Claim | Action |
|---|---|
| "Application/repo is sunset" | Revert to **IN PROGRESS** (not ACCEPTED/DONE). No `AISAST_FPConfirmed` tag. Requires operational verification by Cyber team. |

### Invalid FP Reasons (Rejected) ❌

| Claim | Why Invalid |
|---|---|
| "It's hard to exploit" | Hard ≠ impossible |
| "WAF blocks it" | WAF is not a code-level fix; can be bypassed |
| "Debug logs only" | Must verify actual production log config |
| "Business zone deployment" | Network isolation ≠ unexploitable without verification |
| "Business accepted the risk" | Risk acceptance doesn't change vulnerability status |
| Invalid/irrelevant comment | Must address the specific vulnerability — generic responses rejected |
| "This is a POC repo" | POC code can be promoted to production; AI SAST scans all repos. **EXCEPTION:** If GitHub custom property `purpose` = `Personal` AND no secrets detected, this becomes a valid FP reason — validated via `AISAST_FP_NARepo` path. Agent must verify via GitHub API before accepting. |
| "This is an internal application" | Internal ≠ unexploitable (insider threats, SSRF pivots, lateral movement) |
| "Only in test environments" | Test → prod migration risk |
| "This is a non-prod repo" | **Non-prod repos must still fix vulnerabilities.** This is NOT a valid FP reason regardless of verification. Agent ALWAYS rejects with: "Non-prod repo needs to be fixed as well." |

### FP Decision:

| FP Confidence | Decision | Outcome |
|---|---|---|
| **≥ 0.70** (valid reason + code evidence) | FP CONFIRMED | `validation_outcome: "ACCEPTED/DONE"`, `jira_tag: "AISAST_FPConfirmed"` |
| **0.50 – 0.69** (ambiguous) | NEEDS REVIEW | `validation_outcome: "IN_TESTING"`, `jira_tag: null` |
| **< 0.50** (invalid or contradicted) | FP REJECTED | `validation_outcome: "IN PROGRESS"`, `jira_tag: null` |

### Repository-Level FP Validation (Tag: `AISAST_FP_NARepo`)

These are special FP validations where the **repository itself** is not applicable for remediation. They use a distinct tag (`AISAST_FP_NARepo`) separate from code-level FPs (`AISAST_FPConfirmed`).

> ⚠️ **IMPORTANT:** Non-production repositories are **NOT eligible** for `AISAST_FP_NARepo`. Non-prod repos must still fix vulnerabilities. Only archived repos and personal POC repos qualify.

#### Archived Repository Validation

When a developer claims "Archived repository":

```
Decision Logic:
IF claim = "Archived repository", "Sunset claim", or "End of life":
  Step 1: Check if repo exists on https://github.trusted.visa.com/vgitapp
  Step 2: Check if repo exists on https://github.trusted.visa.com/ARCHIVED-ONPREMISE-ORG

  IF repo does NOT exist on vgitapp BUT EXISTS on ARCHIVED-ONPREMISE-ORG:
    → ACCEPTED/DONE — Tag: AISAST_FP_NARepo
  ELSE:
    → IN PROGRESS — Comment: "Please provide evidence of archived repository or move your repository to github.trusted.visa.com/ARCHIVED-ONPREMISE-ORG"
```

#### POC Application Validation (GitHub Custom Properties)

When a developer claims "My app is POC application":

```
Decision Logic:
IF claim = "My app is POC application":
  Agent retrieves repository custom properties via GitHub API

  IF "property_name": "purpose", "value": "Personal":
    CHECK: Are secrets detected on the repository?

    IF secrets detected:
      → IN PROGRESS — Comment: "Secrets should not be committed on version control systems regardless of POC repo"
    ELSE (no secrets):
      → ACCEPTED/DONE — Tag: AISAST_FP_NARepo — Comment: "Personal POC"

  IF "property_name": "purpose", "value": "business":
    → IN PROGRESS — Comment: "GitHub custom property 'purpose' = 'business'. Business-purpose repos require remediation."
```

#### Non-Production Repository — ALWAYS REJECTED ❌

> **Per PRD v1.5 (Cyber Approved): Non-production repositories are NOT a valid FP reason. Non-prod repos must still fix vulnerabilities.**

When a developer claims the repository is non-production:

```
Decision Logic:
IF claim indicates non-prod repository:
  → ALWAYS IN PROGRESS — Comment: "Non-prod repo needs to be fixed as well."

  NOTE: This applies regardless of GitHub custom property 'classification' value.
  Non-prod status does NOT exempt a repository from security remediation.
```

#### GitHub Custom Properties Reference

Sample properties structure (for validation reference):
```json
{
  "properties": [
    {"property_name": "ACMRating", "value": "Critical"},
    {"property_name": "appid", "value": "0018646"},
    {"property_name": "classification", "value": "non-prod"},
    {"property_name": "Labels", "value": null},
    {"property_name": "purpose", "value": "business"}
  ]
}
```

---

## Section 5: Validation Outcome & Jira Tag Logic

| Condition | `validation_outcome` | `jira_tag` |
|---|---|---|
| Fixed (Fix Score ≥ 0.80) | `ACCEPTED/DONE` | `AISAST_FixConfirmed` |
| FP Confirmed — code-level (FP confidence ≥ 0.70) | `ACCEPTED/DONE` | `AISAST_FPConfirmed` |
| FP Confirmed — repo-level (archived or personal POC verified) | `ACCEPTED/DONE` | `AISAST_FP_NARepo` |
| Partially Fixed (Fix Score 0.50–0.79) | `IN PROGRESS` | `null` |
| Not Fixed (Fix Score < 0.50) | `IN PROGRESS` | `null` |
| FP Ambiguous (confidence 0.50–0.69) | `IN_TESTING` | `null` |
| FP Rejected (confidence < 0.50) | `IN PROGRESS` | `null` |
| Sunset claim | `IN PROGRESS` | `null` |
| Non-prod repo claim | `IN PROGRESS` | `null` |
| POC repo with secrets detected | `IN PROGRESS` | `null` |

**Rules:**
- ✅ Only `ACCEPTED/DONE` findings get a Jira tag
- ✅ `AISAST_FixConfirmed` = fix validation passed (developer's code fix verified as complete)
- ✅ `AISAST_FPConfirmed` = code-level false positive confirmed (dead code, trusted source, compensating control, impossible precondition)
- ✅ `AISAST_FP_NARepo` = repository-level FP confirmed (archived repo OR personal POC — repository not applicable for remediation)
- ❌ Non-prod repos are **NOT eligible** for `AISAST_FP_NARepo` — they must still fix vulnerabilities
- ❌ POC repos with secrets detected are **NOT eligible** for `AISAST_FP_NARepo`
- ❌ Everything else = no tag, goes back to developer or Cyber team

### Tag Separation Explanation

| Tag | Applied When | Meaning |
|---|---|---|
| `AISAST_FixConfirmed` | Fix validation passes | Developer's code fix has been verified as complete |
| `AISAST_FPConfirmed` | Code-level FP validation passes | Vulnerability genuinely doesn't exist (dead code, trusted source, compensating control, impossible precondition) |
| `AISAST_FP_NARepo` | Repository-level FP validated | Repository is not applicable for remediation (archived OR personal POC only). **Non-prod repos are NOT eligible.** |

---

## Section 6: Common Vulnerability Patterns to Check

| Vuln Type | What to Search For | Common False Claims |
|---|---|---|
| **IDOR** | User-supplied IDs without ownership checks | "Session validated upstream" — verify the full call chain |
| **XSS** | Unencoded output, `innerHTML`, `dangerouslySetInnerHTML` | "Request validation blocks it" — check if it actually does |
| **Auth Bypass** | Skippable auth, trust in client data | "MFA enabled" — check if bypass paths exist |
| **SSRF** | Attacker-controlled URLs, insufficient allow-listing | "Regex validates" — check for DNS rebinding, redirects |
| **SQLi** | String concatenation in queries | "ORM handles it" — check for raw query usage |
| **Sensitive Data** | Logging credentials, weak crypto | "DEBUG only" — check production log config |
| **Hardcoded Secrets** | API keys, passwords in source | "It's a test key" — verify it's not used in prod configs |

---

## Section 7: Output — Write These Two Files

### File 1: `validation_results.json`

Write a JSON array with one object per finding:

```json
[
  {
    "tracking_id": "SSDLC-FIND-1202162",
    "finding_title": "OAuth Client Validation Bypass",
    "finding_description": "Brief description of the vulnerability...",
    "severity_original": "High",
    "severity_validated": "High",

    "is_false_positive": false,
    "false_positive_reason": "",
    "fp_confidence_score": null,
    "fp_claim_status": null,

    "fixed": true,
    "partially_fixed": false,
    "not_fixed": false,
    "fix_score": 0.85,
    "files_needing_fixes": [],

    "reason": "Detailed explanation of your analysis — what you found in the code, how you verified the fix, why you trust (or don't trust) the developer's claim...",

    "affected_files": ["src/controllers/SessionController.cs", "src/auth/OAuthValidator.cs"],
    "recommendations": ["Monitor for similar patterns in other OAuth flows"],

    "evidence_analyzed": {
      "pr_url": "https://github.example.com/pull/2246",
      "commit_sha": "abc123def456",
      "code_evidence": "Found fix at line 142: added server-side clientId validation",
      "developer_justification": "Summary of what the developer claimed"
    },

    "validation_outcome": "ACCEPTED/DONE",
    "jira_tag": "AISAST_FixConfirmed"
  }
]
```

**Possible values for `jira_tag`:**
- `"AISAST_FixConfirmed"` — fix validation passed
- `"AISAST_FPConfirmed"` — code-level false positive confirmed
- `"AISAST_FP_NARepo"` — repository-level FP (archived repo or personal POC only)
- `null` — validation did not pass; no tag applied

### File 2: `validation_report.md`

Write a human-readable Markdown report:

```markdown
# Security Finding Validation Report
**Date:** YYYY-MM-DD
**Repo:** <repo name from git or directory>
**Total Findings:** N

## Summary

| # | Tracking ID | Title | Severity | FP? | Fix Status | Fix Score | Outcome | Jira Tag |
|---|---|---|---|---|---|---|---|---|
| 1 | SSDLC-FIND-XXX | Title here | High | No | ✅ Fixed | 0.85 | ACCEPTED/DONE | AISAST_FixConfirmed |
| 2 | SSDLC-FIND-YYY | Title here | Medium | Yes | N/A | N/A | ACCEPTED/DONE | AISAST_FPConfirmed |
| 3 | SSDLC-FIND-ZZZ | Title here | High | No | ❌ Not Fixed | 0.30 | IN PROGRESS | — |

## Statistics
- ✅ ACCEPTED/DONE: X findings
  - 🏷️ AISAST_FixConfirmed: X
  - 🏷️ AISAST_FPConfirmed: X
  - 🏷️ AISAST_FP_NARepo: X
- 🔄 IN PROGRESS: X findings
- ⚠️ IN_TESTING: X findings

---

## Detailed Analysis

### Finding 1: SSDLC-FIND-XXX — <Title>
**Severity:** High → High (validated)
**Status:** ✅ FIXED (score: 0.85)
**Outcome:** ACCEPTED/DONE | 🏷️ AISAST_FixConfirmed

**Analysis:**
<Your detailed reasoning here — what you found in the code, how you verified...>

**Affected Files:** `src/file1.cs`, `src/file2.cs`
**Recommendations:** ...

---
(repeat for each finding)
```

---

## Section 8: Critical Validation Rules

- ✅ **Trust but verify** — Developer claims need code evidence backing them up
- ✅ **Search the actual codebase** — You're in the repo, USE IT. Don't just read the findings file.
- ✅ **Partial fixes count** — If 3 of 5 instances are fixed, it's PARTIALLY_FIXED
- ✅ **Check ALL instances** — One fix doesn't mean all occurrences are fixed. Use `grep`/search.
- ✅ **Git history matters** — `git log`, `git diff`, `git blame` tell you what actually changed
- ✅ **Be skeptical of FP claims** — Require solid technical reasoning backed by code evidence
- ✅ **Be fair on real fixes** — Give credit where code genuinely addresses the vulnerability
- ✅ **Severity can change** — If exploitation is harder/easier than originally assessed, adjust it
- ✅ **Explain your reasoning** — The `reason` field should be detailed enough for a security reviewer to understand your logic
- ✅ **Non-prod is NOT exempt** — Non-production repos must fix vulnerabilities; this is never a valid FP reason
- ✅ **Secrets in POC repos are never acceptable** — Even personal POC repos must not have secrets committed to version control

---

## Section 9: Example Prompts Developers Can Use

| Prompt | What Happens |
|---|---|
| "Validate the findings" | Full validation of all findings in the file |
| "Validate SSDLC-FIND-1202162" | Validate a single specific finding |
| "Check if the XSS finding is fixed" | Targeted check on a specific vulnerability type |
| "Show me which findings are still open" | Quick triage summary |
| "Re-validate finding X — the developer pushed a new fix" | Re-analyze after code changes |

---

## Section 10: FP Validation Decision Summary (Quick Reference)

| Decision | Criteria | Action |
|---|---|---|
| **FP_CONFIRMED** | FP Confidence >= 0.70 AND valid reason AND code evidence supports claim | ACCEPTED/DONE + Tag: `AISAST_FPConfirmed` |
| **FP_NEEDS_REVIEW** | FP Confidence 0.50–0.69 OR evidence is ambiguous | IN_TESTING (Cyber SSDLC human review) |
| **FP_REJECTED** | FP Confidence < 0.50 OR invalid reason OR code contradicts claim | IN PROGRESS |
| **FP_ARCHIVED_CONFIRMED** | Archived/sunset/EOL claim AND repo NOT on vgitapp AND repo EXISTS on ARCHIVED-ONPREMISE-ORG | ACCEPTED/DONE + Tag: `AISAST_FP_NARepo` |
| **FP_ARCHIVED_REJECTED** | Archived claim BUT repo still on vgitapp OR NOT found on ARCHIVED-ONPREMISE-ORG | IN PROGRESS + Comment: "Please provide evidence of archived repository or move your repository to github.trusted.visa.com/ARCHIVED-ONPREMISE-ORG" |
| **FP_POC_CONFIRMED** | POC claim AND GitHub property `purpose` = `Personal` AND no secrets detected | ACCEPTED/DONE + Tag: `AISAST_FP_NARepo` + Comment: "Personal POC" |
| **FP_POC_REJECTED** | POC claim AND GitHub property `purpose` = `business` | IN PROGRESS + Comment: "GitHub custom property 'purpose' = 'business'" |
| **FP_POC_REJECTED (Secrets)** | POC claim AND GitHub property `purpose` = `Personal` AND secrets detected on repository | IN PROGRESS + Comment: "Secrets should not be committed on version control systems regardless of POC repo" |
| **FP_NONPROD_REJECTED** | Non-prod claim (regardless of GitHub classification property) | **ALWAYS** IN PROGRESS + Comment: "Non-prod repo needs to be fixed as well." |
| **FP_SUNSET** | Sunset/decommission claim (not verified as archived) | IN PROGRESS (Cyber must verify operationally). No tag. |

---

**Remember: You are the final security reviewer. Your assessment determines whether findings get closed or escalated. Be thorough. Be fair. Be evidence-based.**
