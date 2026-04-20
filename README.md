# Review

Static site for **review.castalia.institute**: critical three-faculty reviews of books, published with [GitHub Pages](https://pages.github.com/).

## Bibliotech (source EPUBs + annotations)

Non-public review EPUBs and the Readest import path are documented in the **bibliotech** repo: [docs/FACULTY_REVIEW_EPUBS.md](https://github.com/InquiryInstitute/bibliotech/blob/main/docs/FACULTY_REVIEW_EPUBS.md).

**Example title:** *The Technological Republic* (ISBN 9780593798706) — uploaded via `npm run upload:local-epub` with `--review`; deep link on the site under **Titles in review**.

## Marginalia pages (per reviewer)

Static HTML under `reviews/<slug>/marginalia/` lists **book quotations** and each **reviewer’s comment** (from Supabase `marginalia`). Regenerate from the bibliotech repo after a pipeline run:

`npm run review:export-marginalia -- --book-id=<UUID> --slug=<slug> --out-dir=../review/reviews/<slug>/marginalia`

See [REVIEW_PIPELINE_CHAPTER_ASK_FACULTY.md](https://github.com/InquiryInstitute/bibliotech/blob/main/docs/REVIEW_PIPELINE_CHAPTER_ASK_FACULTY.md) in bibliotech.

## Publish (GitHub Pages)

1. Create the repository **InquiryInstitute/review** (if it does not exist) and push this tree to `main`.
2. **Settings → Pages**: Build and deployment source = **Deploy from a branch**, branch `main`, folder `/ (root)`.
3. **Custom domain**: enter `review.castalia.institute` and save. GitHub adds a DNS check; complete Cloudflare (below) first or retry after DNS propagates.
4. When the certificate shows as ready under Pages, enable **Enforce HTTPS**.

Equivalent **GitHub API** (after DNS points at Pages):

```bash
gh api -X PUT repos/InquiryInstitute/review/pages --input - <<'JSON'
{
  "cname": "review.castalia.institute",
  "source": { "branch": "main", "path": "/" },
  "https_enforced": true
}
JSON
```

Use `https_enforced: false` until GitHub has issued the certificate for the custom domain.

## DNS (Cloudflare)

In the **castalia.institute** zone, add (or upsert) a **CNAME**:

| Type  | Name   | Target                      |
|-------|--------|-----------------------------|
| CNAME | review | `inquiryinstitute.github.io` |

Match your org’s GitHub Pages hostname if it differs.

With API token (**Zone → DNS → Edit**) from the parent project env (see `Inquiry.Institute` `.env.local.example`):

```bash
export CLOUDFLARE_API_TOKEN="…"   # from ../Inquiry.Institute/.env.local
./scripts/upsert-cloudflare-cname.sh
```

Optional: `PROXIED=0 ./scripts/upsert-cloudflare-cname.sh` for DNS-only (grey cloud) if you prefer GitHub to terminate TLS directly.

## Local preview

Open `index.html` in a browser, or:

```bash
python3 -m http.server 8080
```

Then visit http://127.0.0.1:8080/
