# mostowylab.com — Quarto site

**Microbial Genomics Group · Jagiellonian University**  
Built with [Quarto](https://quarto.org) · Deployed via GitHub Pages

---

## Prerequisites

Install these once on your Mac:

```bash
# 1. Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Quarto
brew install --cask quarto

# 3. R  (if not already installed)
brew install --cask r

# 4. R package: bibtex  (for publications page)
Rscript -e 'install.packages("bibtex", repos="https://cloud.r-project.org")'

# 5. Verify Quarto is working
quarto --version
```

---

## Local preview

```bash
cd mostowylab
quarto preview
```

This opens the site at `http://localhost:4321` with live reload.

---

## File structure

```
mostowylab/
├── _quarto.yml          # Site config: nav, title, footer
├── styles.css           # All custom CSS
├── publications.bib     # BibTeX — copy from your Zotero export
├── index.qmd            # Home
├── research.qmd         # Research
├── publications.qmd     # Publications (auto-rendered from .bib)
├── team.qmd             # Team
├── opportunities.qmd    # Join Us
├── news.qmd             # News
├── contact.qmd          # Contact
├── assets/              # Logos, favicon, images
│   ├── logo.png         # Navbar logo (Secondary_Logo01_blue.png, ~36px tall)
│   ├── favicon.png      # Browser tab icon (icon only, ~32px)
│   ├── ncn_logo.png     # Funder logo
│   ├── embo_logo.png    # Funder logo
│   └── nawa_logo.png    # Funder logo (past)
└── .github/
    └── workflows/
        └── deploy.yml   # Auto-deploy on push to main
```

---

## Adding assets (logos, images)

1. Copy your logo files into `assets/`. Suggested names are already referenced in the CSS and pages.
2. For the **navbar logo**, use `Secondary_Logo01_blue.png` (horizontal, "Mostowy Lab") — rename to `assets/logo.png`.
3. For the **favicon**, use the standalone icon variant from the logo PDFs — export as a 64×64 PNG, save as `assets/favicon.png`.
4. For **funder logos**, download official PNG logos from NCN, EMBO, NAWA websites.

---

## Updating publications

Publications are rendered automatically from `publications.bib`.

To update:
1. In Zotero: **File → Export Library** → BibTeX → save as `publications.bib` in the site folder.
2. `quarto preview` to check rendering locally.
3. `git add publications.bib && git commit -m "Update publications" && git push` — site rebuilds automatically.

---

## Adding a news item

Open `news.qmd` and add a new block at the top of the list:

```html
<div class="news-item">
  <div class="news-date">Mon YYYY</div>
  <div class="news-body">
    Your news here. One sentence is fine.
  </div>
</div>
```

---

## GitHub setup (first time only)

### 1. Create the repository

```bash
# On GitHub.com: create a new repo named "mostowylab.com" (or "mostowylab")
# Then locally:
cd mostowylab
git init
git remote add origin https://github.com/rmostowy/mostowylab.com.git
git add .
git commit -m "Initial site"
git push -u origin main
```

### 2. Enable GitHub Pages

1. Go to your repo on GitHub → **Settings → Pages**
2. Under **Source**, choose **GitHub Actions**
3. On the next push to `main`, the workflow runs and deploys automatically.

Your site will be live at `https://rmostowy.github.io/mostowylab.com/` while DNS propagates, and at `https://mostowylab.com` after the DNS step below.

### 3. DNS configuration (point mostowylab.com → GitHub Pages)

Your domain is registered via Squarespace. Update DNS there:

**Add these four A records** (apex domain `mostowylab.com`):
```
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

**Add a CNAME record** (www subdomain):
```
www  →  rmostowy.github.io
```

**In GitHub** (Settings → Pages → Custom domain): enter `mostowylab.com` and tick **Enforce HTTPS** once it propagates (can take up to 24 h).

You can verify DNS has propagated with:
```bash
dig mostowylab.com +noall +answer
```

---

## Editing content

- **All pages** are `.qmd` files — standard Markdown with optional R code chunks.
- **Team data** is in `team.qmd` — edit the HTML cards directly.
- **Research narrative** is in `research.qmd` — plain prose.
- **Colour and fonts** are all in `styles.css` via CSS variables at the top.
- **Site structure** (nav items, footer, title) is in `_quarto.yml`.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Publications page blank | Check `bibtex` R package is installed; run `Rscript -e 'library(bibtex)'` |
| Navbar logo not showing | Check `assets/logo.png` exists; path is relative to site root |
| CSS not applying | Run `quarto render` (not just preview) to force a clean build |
| GitHub Actions fails | Check the Actions tab in GitHub for the error log |
