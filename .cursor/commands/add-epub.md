---
description: "Upload a dragged/attached book (EPUB or MOBI/AZW) to bibliotech; auto-convert + private store (scripts/add-epub-to-bibliotech.sh)"
---

# Add book to bibliotech

The user has attached (dragged) a book file: **EPUB** or **MOBI / AZW3 / AZW** to add to **bibliotech** at `../bibliotech` (or `BIBLIOTECH_ROOT` if they set it).

The script **copies** the file into a **local private book store** (default `../.castalia-review-private-books/<import-id>/`; set `REVIEW_PRIVATE_BOOKS_DIR` to use e.g. `private/books`). It **converts** non-EPUB to EPUB with Calibre’s **`ebook-convert`** when needed (user must have Calibre installed and on `PATH`).

## Do this

1. **Resolve the file path** from the attachment or `@`-mentioned file. Use the **absolute path** on disk. If the path is unclear, ask for the exact path.
2. From the **review repo root**, run:
   - Default (review title upload to bibliotech):
     ```bash
     ./scripts/add-epub-to-bibliotech.sh "ABSOLUTE_PATH_TO_FILE" -- --review
     ```
   - If needed: `BIBLIOTECH_ROOT`, `REVIEW_PRIVATE_BOOKS_DIR=…` (writable directory for the private copy + converted EPUB).
3. If `ebook-convert` is missing and the file is not `.epub`, tell the user to install [Calibre](https://calibre-ebook.com) and retry. Do not invent another converter unless the user asks.
4. **Report** the script’s exit code, the **private store** path printed, and any npm/Calibre log lines. If upload fails, help with env/credentials and retry when appropriate.

Do **not** invent paths; the attached file is the source of truth.

**Next (full Castalia Review):** For **faculty selection**, the **bibliotech** review pipeline, and **exporting marginalia** into this site repo, use the **`/review-epub`** command after a successful upload (or use `/review-epub` alone for end-to-end guidance).
