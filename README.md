# IFM Comac Parts Processor

A Windows desktop tool that turns a raw Comac spare-parts catalogue into a finished,
usable parts document.

**Website and download → https://imranifm.github.io/ifm-parts-processor/**

---

## The problem it solves

Comac supply their spare-parts catalogues as exploded drawings where every callout on the
drawing is just a balloon number — `1`, `2`, `3` — and the actual eight-digit part codes
live in a table on the following page. Anyone quoting or ordering from one of these
catalogues has to flip back and forth and match numbers to codes by hand. It is slow, and
a mismatched code means the wrong part gets ordered.

The Processor does that matching automatically, then carries on and finishes the document.

## What it does

Four stages. They can be run individually, or Auto-Pilot runs all four back-to-back.

| # | Stage | What happens |
|---|---|---|
| 01 | **Code Replacement** | Reads each exploded drawing, finds every balloon callout, matches it against that diagram's own parts table, and stamps the real part code in its place. |
| 02 | **Hyperlinks** | Makes every stamped code clickable so the document can be navigated rather than cross-referenced. |
| 03 | **Image Extraction** | Pulls the drawings out as individual image files for catalogue and web listings. |
| 04 | **Excel Report** | Builds a spreadsheet of every part found — costed against the master Comac price list, converted from euros to sterling at a live or fixed rate, with Italian descriptions translated to English. |

### Old PDFs Processor (experimental)

Older catalogues don't follow the current layout, so stage 01 ships with a second engine
built for them: landscape drawings, tables with no ruled boxes, rotated pages, and scans
with no usable text layer at all — those are read by OCR.

### Job history

Every run is recorded with its counts and output folder, so a job can be reopened,
checked, or re-exported later.

## Using it

1. Download from the [website](https://imranifm.github.io/ifm-parts-processor/) — you'll
   need the internal username and password.
2. Unzip the folder anywhere.
3. Run `IFM Processor.exe`.

There is no installer and nothing to configure. Processing happens on your own machine.

**Requirements:** Windows 10 or 11, 64-bit. About 140 MB on disk once unzipped.

A full user guide (**Manual**) and a video **Walkthrough** are built into the app — both
buttons are at the bottom of the sidebar.

## About this repository

This repository holds the public website only. The application source is internal and is
not published here.

---

© IFM Comac. Internal tool — not for external distribution.
