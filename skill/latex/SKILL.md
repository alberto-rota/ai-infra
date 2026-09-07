---
name: latex
description: Work with LaTeX documents. Author/edit .tex sources with correct syntax, compile to PDF via Tectonic, fix compile errors iteratively, manage BibTeX bibliographies, and scaffold new paper projects. Use whenever a task involves .tex or .bib files, math typesetting, or building PDFs from LaTeX.
---

# LaTeX workflow

## Toolchain facts (this machine)

- The ONLY TeX engine installed is **Tectonic** (`tectonic`, XeTeX-based, at `/opt/homebrew/bin/tectonic`). There is NO `pdflatex`, `xelatex`, `latexmk`, `bibtex`, `biber`, `chktex`, `latexindent`, or `pandoc`. Never instruct or attempt to run those binaries.
- `tectonic doc.tex` compiles AND auto-reruns until references settle; it also runs its built-in BibTeX automatically when `\bibliography{...}` and `.bib` files are present.
- The first compile of any new package downloads it from the network bundle (requires internet). `--only-cached` forbids network access.
- **BibLaTeX/biber is NOT supported.** Always use the classic BibTeX workflow: `\usepackage{natbib}` + `\bibliographystyle{...}` + `\bibliography{refs}`.
- Output PDF lands next to the input file unless `-o DIR` is given.

## Preferred build path

Use the wrapper script (keeps logs on failure and prints a concise error summary):

```
/Users/albe/.config/opencode/skill/latex/scripts/texbuild.sh main.tex
/Users/albe/.config/opencode/skill/latex/scripts/texbuild.sh main.tex --outdir build
```

Raw tectonic when finer control is needed:

```
tectonic -p --keep-logs main.tex        # print chatter, keep .log
tectonic --synctex -o build main.tex    # synctex data, custom outdir
tectonic -r 2 main.tex                  # force extra reruns (stub references)
```

Exit code 0 = PDF produced. Warnings never fail the build.

## Error-fixing loop

1. Build with `texbuild.sh`; read its summary (it greps `!` lines and tectonic `error:` lines).
2. Fix only the FIRST reported error - later errors are usually cascade noise.
3. Rebuild. Repeat until clean.
4. Address warnings last: undefined citations/references first, then overfull boxes if visually harmful.

Common errors cheat-sheet:

| Message | Cause | Fix |
|---|---|---|
| `Undefined control sequence` | missing macro/package or typo | add the right `\usepackage{...}` or fix the command name |
| `Missing $ inserted` | math-only symbol in text mode | wrap the expression in `$...$` |
| `File 'x' not found` | unknown package / wrong image path | check spelling, `\includegraphics{figures/x}` path |
| `Environment X undefined` | env from an unloaded package | e.g. `align` -> add `amsmath` |
| `Citation ... undefined` / `Reference ... undefined` | normal on first pass | rerun; if persistent, check `.bib` keys vs `\cite` and `\label` names |
| `Emergency stop` / `Fatal error` early | syntax broken earlier in source | read the kept `.log` next to the source |

Overfull/underfull hbox/vbox are layout WARNINGS, not errors. Fix last.

## Authoring rules

- Escape specials outside math: `% & $ # _ { } ~ ^ \`. Use `\% \& \_ ...`, `~` for nbsp, `\textasciicircum{}`, `$\backslash$`.
- Math: prefer `amsmath` environments (`equation`, `align`) over `eqnarray`; number with `\eqref{eq:x}`.
- Load `hyperref` LAST in the preamble.
- Figures: `figure` environment + `\includegraphics[width=\linewidth]{figures/name}` + `\caption{...}` + `\label{fig:...}` directly after the caption.
- Tables: `booktabs` rules (`\toprule`, `\midrule`, `\bottomrule`), no vertical lines; label after caption.
- Keep each sentence on its own source line where practical - makes diffs and error line numbers meaningful.

## Bibliographies

- One `refs.bib` per project. Cite with `\citep{key}` / `\citet{key}` (natbib).
- Styles: `\bibliographystyle{plainnat}` (numeric) or `abbrvnat` etc.
- Tectonic runs BibTeX automatically on reruns - do not try to invoke bibtex yourself.
- If a citation stays undefined: verify the key exists in `.bib`, the `.bib` filename matches `\bibliography{refs}` (no extension), then rerun once more.

## Project layout

```
my-paper/
├── main.tex      # single entry point, documentclass article
├── refs.bib
├── figures/
└── .gitignore    # TeX artifacts
```

## Scaffolding a new paper

```
/Users/albe/.config/opencode/skill/latex/scripts/newpaper.sh my-paper "A Great Result"
```

Creates `main.tex` (article skeleton with natbib/amsmath/graphicx/booktabs/hyperref), `refs.bib` with one sample entry, `.gitignore`, and `figures/`. Then edit `main.tex` and build with `texbuild.sh`.
