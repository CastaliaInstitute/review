---
description: "Upload a dragged/attached EPUB to bibliotech (runs scripts/add-epub-to-bibliotech.sh)"
---

# Add EPUB to bibliotech

The user has attached (dragged) an **EPUB** in this input and wants it added to **bibliotech** at `../bibliotech` (or `BIBLIOTECH_ROOT` if they set it).

## Do this

1. **Resolve the EPUB path** from the attachment or `@`-mentioned file in the chat. Use the **absolute path** on disk (not a summary or a fake path). If the path is unclear, ask for the exact file path.
2. From the **review repo root** (where `scripts/add-epub-to-bibliotech.sh` lives), run in the terminal:
   - Default (faculty / review title upload):
     ```bash
     ./scripts/add-epub-to-bibliotech.sh "ABSOLUTE_PATH_TO.epub" -- --review
     ```
   - If the user asked for a non-review upload, omit the `--` flags or use the args they specified (per bibliotech’s `upload:local-epub` and docs).
3. If `BIBLIOTECH_ROOT` must point somewhere other than `../bibliotech`, set it in the same command, e.g.:
   ```bash
   BIBLIOTECH_ROOT="/path/to/bibliotech" ./scripts/add-epub-to-bibliotech.sh "ABSOLUTE_PATH_TO.epub" -- --review
   ```
4. **Report** the script’s exit code and any relevant log lines. If npm or auth fails, help with env/credentials and retry only when appropriate.

Do **not** invent paths; the EPUB the user attached is the source of truth.
