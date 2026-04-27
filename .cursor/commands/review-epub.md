---
description: "Full Castalia Review: book file (EPUB/MOBI) + bibliotech, faculty, pipeline, export to this site"
---

# Castalia Review — full faculty review (from a book file)

The user wants to **set up a Castalia Review** of a book: not only uploading the source file (EPUB, or **MOBI/AZW** after conversion) to **bibliotech** (`../bibliotech`), but moving through **faculty reviewer selection** and the steps that produce the static site in **this repo** (Castalia **Review** at `review.castalia.institute`).

This **chains** with **`/add-epub`**: that command only runs `scripts/add-epub-to-bibliotech.sh`. This command is the **end-to-end** orchestration; run upload first if it has not been done.

If the agent runs in a **remote** environment, local macOS paths (e.g. `/Users/...`) are not readable there—point the user at **local terminal** for `add-epub-to-bibliotech.sh` (see `add-epub` command).

## 1) Source file and bibliotech

- If the user **dragged** or **@**‑attached a book file, resolve the **real absolute path** and (unless they say upload is already done) run from the **review** repo root, **or** in a local terminal on their machine if the path only exists on their computer:
  ```bash
  ./scripts/add-epub-to-bibliotech.sh "ABSOLUTE_PATH" -- --review
  ```
  The script **files a copy in the private store** and **converts** MOBI/AZW to EPUB with Calibre when needed. Use `BIBLIOTECH_ROOT` and `REVIEW_PRIVATE_BOOKS_DIR` if the defaults do not match their machine.

- **Docs** (in bibliotech; follow current flags and steps there): *FACULTY_REVIEW_EPUBS* (Readest, non-public EPUBs), and **REVIEW_PIPELINE_CHAPTER_ASK_FACULTY** (the chapter ask-faculty pipeline). Point the user to those for authoritative CLI and env.

## 2) Select faculty reviewers (three voices, optional fourth)

Castalia Review essays use **`*in voce*`** sections: each is a **named review voice** with a stable **ID** and **marginalia** (quoted passages + that voice’s comments). The published **Technological Republic** example uses **four** voices, each with a slug of the form `a.<name>`:

| Voice (label)     | Suggested ID slug (`review-faculty-id` / file prefix) |
|------------------|---------------------------------------------------------|
| Plato            | `a.plato`   |
| Durkheim         | `a.durkheim` |
| Einstein         | `a.einstein` |
| Li Zehou         | `a.zehou`   |

**With the user, choose three** (or four) **voices** for this book. If they want different figures, keep the same **slug pattern** (`a.<handle>`) so file names, anchors, and marginalia paths stay consistent. Record the list **in order of appearance** in the planned essay and **note which** map to the thesis “spine” (objections, themes) if applicable.

- **Record for later steps:** chosen slugs, display names, `book` **UUID** in Supabase (or from bibliotech after import), and the **URL slug** for the review (e.g. `the-technological-republic` → `reviews/<slug>/` in this repo).

**Do not** invent credentials or run destructive DB commands. Configuration of reviewers in bibliotech/Supabase follows that repo’s pipeline doc.

## 3) After upload — bibliotech and pipeline

- Run or guide the user through the **bibliotech** review pipeline per **REVIEW_PIPELINE_CHAPTER_ASK_FACULTY** (e.g. chapter-faculty prompts, ingestion, any `npm` scripts for HTML generation of the long-form review). **Exact** commands and flags are defined in **bibliotech**; do not copy stale examples from memory.

- **Render** published review HTML in bibliotech when the doc says to (e.g. `review:render-html` or equivalent) so the essay and structure match Castalia’s layout.

## 4) Export marginalia into this (review) repo

From **bibliotech** (path from README), the pattern in this project is:

```bash
npm run review:export-marginalia -- --book-id=<UUID> --slug=<url-slug> --out-dir=../review/reviews/<url-slug>/marginalia
```

Adjust `../review` if the local clone of **Castalia Review** lives elsewhere. Replace `<UUID>` and `<url-slug>` with the book id and the slug agreed with the user.

## 5) This repo (Castalia Review)

- Ensure the main review page and assets align with the existing pattern under `reviews/<slug>/` and `assets/review-inquirer.css` (see `README.md` and the example under `reviews/the-technological-republic/`).
- The user will **commit and push** this site repo when the exports look correct.

## Summary for the user

1. Book file on disk (see `/add-epub` for private store + MOBI→EPUB) + `./scripts/add-epub-to-bibliotech.sh … -- --review` when needed.  
2. **Pick 3 (or 4) faculty** voices and slugs; align with the pipeline in bibliotech.  
3. Run the **bibliotech** review pipeline; then **export marginalia** into `reviews/<slug>/marginalia`.  
4. **Ship** from this **review** repo to GitHub Pages as usual.

If the user has **not** attached a file, ask for the path, whether upload already ran, and the **bibliotech** and **book** context before running commands.
