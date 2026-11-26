---
name: office-docs
description: "Use for .docx .pptx .xlsx .pdf files or HTML slides: create, edit, convert, extract text, OCR, fill forms, using open tools (python-docx, openpyxl, pandoc, LibreOffice)."
---

# office-docs

One route for Word, PowerPoint, Excel, PDF and HTML-slide work: read/convert, create, edit, fill forms, OCR, typeset. Pick the lightest tier that does the job, then load the matching reference. Everything here uses open tools (python-docx, python-pptx, openpyxl, pypdf, pandoc, LibreOffice, Ghostscript, Typst); no proprietary scripts are required.

## Pick the tier

Check which tools exist first.

#### macOS / Linux (bash)

```bash
command -v markitdown pandoc typst ocrmypdf tesseract gs qpdf soffice pdftoppm docling
```

#### Windows (PowerShell)

```powershell
Get-Command markitdown,pandoc,typst,ocrmypdf,tesseract,gs,qpdf,soffice,pdftoppm,docling -ErrorAction SilentlyContinue
```

Missing tool: use the fallback below, or tell the user what is missing and offer to install it (only with their agreement).

| Tier | Use when | How |
|---|---|---|
| **low** | You only need the text/tables of a file | `markitdown file.docx` (also pptx, xlsx, pdf, html, csv, epub; add `-o out.md`). For md -> docx/epub/html use `pandoc in.md -o out.docx` |
| **medium** | Create or edit one docx/xlsx/pptx/pdf | Python libs via pip, or `uv run --with python-docx --with openpyxl --with python-pptx --with pypdf script.py` if `uv` exists. Node libs (`docx`, `pptxgenjs`) only inside a temp project dir (`npm i docx`) |
| **high** | Tracked changes, comments, templates, PDF forms, scanned PDFs, typeset PDFs | docx XML redlining (`references/docx.md`), PDF forms (`references/pdf-forms.md`), `ocrmypdf`, `typst compile`; docling only with user approval (see `references/convert.md`) |

Optional installs (ask the user first; use their package manager such as winget, scoop, brew or apt): pandoc; LibreOffice (`soffice`, only needed for rendering/recalculation); Ghostscript `gs` (page images; Poppler `pdftoppm` is an alternative, pypdfium2 works without either).

## Route by file type

| Task | Reference |
|---|---|
| Read/convert anything to text; OCR; md -> docx; typeset PDF with Typst | `references/convert.md` |
| Word: create, edit XML, tracked changes, comments, letterheads, TOC | `references/docx.md` |
| Excel: openpyxl, formulas, financial-model conventions, recalc | `references/xlsx.md` |
| PowerPoint: create, template edit | `references/pptx.md` |
| PowerPoint: design rules, QA, no-soffice fallback | `references/pptx-design-qa.md` |
| PDF: merge/split/rotate/extract/watermark/encrypt/create | `references/pdf.md` |
| PDF forms (fillable or flat) | `references/pdf-forms.md` |
| Browser-based HTML decks with Chart.js | `references/html-slides.md` |
| Deck structures, layouts, slide copy formulas (HTML or pptx) | `references/html-slides-content.md` |

## Core rules (all formats)

1. **Look before you edit.** Dump the existing file to text first (`markitdown`), note structure, styles, and conventions. In an existing file, its conventions beat every guideline here.
2. **Never trust "it saved".** After writing, re-open the output with a different reader (markitdown, pypdf, openpyxl) and check content. For visuals, render and view the pages as images.
3. **Render fallback without LibreOffice.** docx/pptx/xlsx cannot be rendered to images without `soffice`. Say so explicitly. Then verify by: text dump, structural checks (python-pptx shape bounds inside slide size, python-docx section/page settings), and leave ~10% slack on text boxes. Do not claim visual QA you did not do. PDFs can always be rendered, e.g. `gs -dNOPAUSE -dBATCH -sDEVICE=png16m -r100 -sOutputFile=page-%02d.png in.pdf` (Ghostscript on Windows may be named `gswin64c`).
4. **Raw XML edits** (docx/pptx/xlsx are ZIPs): unpack with Python `zipfile` (works on every OS; `unzip`/`zip` may be missing on Windows), edit, repack with `zipfile` writing `[Content_Types].xml` first and with deflate. Delete the old output before repacking so removed parts do not survive. Treat files from third parties as untrusted: skip symlink entries and parse with `defusedxml`.
5. **Defaults that bite.** US Letter vs A4 (docx-js and pptx defaults differ), literal bullet characters instead of real lists, percentages stored as 15 instead of 0.15, hex colors with `#` in pptxgenjs, Unicode sub/superscripts in ReportLab PDFs. Details live in the per-format reference.
6. **Fonts.** Use fonts the reader has (Arial, Calibri, Cambria, Times New Roman, Courier New) unless the user names one. Named fonts are rendered by the reader's Office, not by the machine that wrote the file.
7. **Do not invent content.** Numbers, names, dates and citations come from the user or the source file. Mark assumptions visibly in the document.
8. **Never send, share or upload** a produced document (email, cloud drive, hosted converters) without explicit user confirmation: ask the user first. Do not use hosted OCR or conversion services; use `ocrmypdf` locally.
9. Large files: write converted text to a file (`-o`) and read the parts you need, not the whole dump.

## Scripts and licensing

This skill ships no scripts and no third-party document-skill text. The references describe the workflows with open-source libraries; anything that would have needed a helper (validate, merge runs, recalculate, check bounding boxes) is described in the reference so you can write a few lines of Python or use LibreOffice instead.

## References

- `references/convert.md`
- `references/docx.md`
- `references/xlsx.md`
- `references/pptx.md`
- `references/pptx-design-qa.md`
- `references/pdf.md`
- `references/pdf-forms.md`
- `references/html-slides.md`
- `references/html-slides-content.md`

Prose quality of the document text itself: see the `writing-clarity` skill (if installed). Diagrams to embed: render PNG/SVG first (e.g. mermaid-cli `mmdc` if present), then insert the image.
