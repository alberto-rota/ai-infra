---
name: empleSweep
description: EmploSweep daily routine - source orgs and job postings into Notion, generate tailored CV + cover letter for each new posting
---

# EmploSweep Opencode Skill

Port of the Claude EmploSweep daily job search. Working directory: `/Users/albe/EmploSweep`.

**STEP 1, before doing anything else:** read `/Users/albe/EmploSweep/ROUTINE.md` in full. It is the single source of truth (profile, tone, Notion IDs/schemas, search + generation). Also read `/Users/albe/EmploSweep/CLAUDE.md` for tooling and layout. Do not act from memory or from this skill alone.

**STEP 2:** execute the routine end to end, in order:

1. **Section 2** — company search: add a few genuinely new organizations to the Notion Organizations database.
2. **Section 3** — job search: find real, currently open postings and log them in Job Search Tracker. Link verification is mandatory: never add a posting whose URL you have not fetched and confirmed live; never invent or guess a URL.
3. **Section 4** — for EVERY newly added posting:
   - Scaffold: `tools/new_application.sh "<Company> - <Short Role>"` (from project root)
   - Tailor `cv/main.tex` and `coverletter/main.tex` per ROUTINE.md
   - Compile both: `tools/compile.sh "Applications/<folder>/cv/main.tex" "CV_Alberto_Rota.pdf"` and the cover-letter equivalent
   - Fix and recompile on failure; do not leave a broken application
4. **Section 4, email drafts** — only when a posting has no online form and expects email. Create a Gmail **draft**. Never send application emails.
5. **Section 5** — compile-toolchain notes (tectonic only).
6. **Section 6** — end-of-run summary, then **send** the recap email to `alberto_rota@outlook.com` (subject `EmploSweep daily recap YYYY-MM-DD`). This is the only send allowed.

## Connectors

- **Notion** (required): Organizations + Job Search Tracker. IDs and schemas in ROUTINE.md section 1.
  - Organizations page: `7ada25f7-eece-4c60-b7c7-72a131452c73` / `collection://49c6798b-4e5b-47f6-8523-05fa53ee3b14`
  - Job Search Tracker page: `a91cd6fa-6d42-4fd1-8f0f-c40c288d598e` / `collection://0f31b499-7822-4a05-ad05-16249c661730`
  - Date columns write as `date:<Name>:start` (e.g. `date:Date Found:start`), not the plain UI name.
  - Create pages in small batches (2–3), not one huge payload.
- **Gmail** (required for recap + optional for application drafts):
  - Application contact emails: **drafts only**, never send.
  - Daily recap: **send** to `alberto_rota@outlook.com` after section 6.

## Hard rules

- Never use em-dashes in any generated CV, cover letter, or email.
- Be honest; never exaggerate or invent skills or experience.
- Never send application emails (section 4). Drafts only.
- Do send the daily recap to `alberto_rota@outlook.com` (section 6).
- Never fabricate a job posting or its URL.
- CV Objective: high-level and general, never naming the company.
- Referrals: De Momi, Pomati, Busam listed as-is; do not comment out or add/remove.

## Local helper scripts

Prefer project `tools/` when CWD is `/Users/albe/EmploSweep`. Skill copies under `scripts/` accept `--root /Users/albe/EmploSweep` if needed.

```bash
tools/new_application.sh "<Company> - <Short Role>"
tools/compile.sh "Applications/<folder>/cv/main.tex" "CV_Alberto_Rota.pdf"
tools/compile.sh "Applications/<folder>/coverletter/main.tex" "CoverLetter_Alberto_Rota.pdf"
```

Or via skill scripts:

```bash
~/.config/opencode/skill/emploSweep/scripts/new_application.sh --root /Users/albe/EmploSweep "<Company> - <Short Role>"
~/.config/opencode/skill/emploSweep/scripts/compile.sh --root /Users/albe/EmploSweep "Applications/<folder>/cv/main.tex" "CV_Alberto_Rota.pdf"
~/.config/opencode/skill/emploSweep/scripts/run_routine.sh --root /Users/albe/EmploSweep "<Company> - <Short Role>"
```

`run_routine.sh` only scaffolds + compiles one folder. The full daily search (Notion + web + multi-posting) is this skill prompt + ROUTINE.md, not that shell script alone.

## Finish

1. Report per ROUTINE.md section 6: new orgs, new postings with Fit, application folder paths, any application Gmail drafts, anything needing input (`Status = Needs Input`).
2. Send that recap to `alberto_rota@outlook.com` (subject `EmploSweep daily recap YYYY-MM-DD`). If send fails, create a Gmail draft to that address and note it in the chat summary.
