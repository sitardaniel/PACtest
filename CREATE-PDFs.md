# 📄 How to Create PDF Documentation

This guide shows you how to convert the Markdown documentation to professional PDFs.

---

## Option 1: Using Pandoc (Best Quality)

### Install Pandoc

**macOS:**
```bash
brew install pandoc basictex
```

**Linux:**
```bash
sudo apt-get install pandoc texlive
```

**Windows:**
Download from: https://pandoc.org/installing.html

### Generate PDFs

```bash
# Main comprehensive guide
pandoc FINAL-COMPLETE-GUIDE.md \
  -o FINAL-COMPLETE-GUIDE.pdf \
  --pdf-engine=pdflatex \
  -V geometry:margin=1in \
  -V fontsize=11pt \
  --toc \
  --toc-depth=2

# README
pandoc README.md \
  -o README.pdf \
  --pdf-engine=pdflatex \
  -V geometry:margin=1in

# Demo guides
pandoc docs/COMPLETE-DEMO-SCRIPT.md \
  -o docs/COMPLETE-DEMO-SCRIPT.pdf \
  --pdf-engine=pdflatex \
  -V geometry:margin=1in

pandoc docs/DEMO-PRACTICE-GUIDE.md \
  -o docs/DEMO-PRACTICE-GUIDE.pdf \
  --pdf-engine=pdflatex \
  -V geometry:margin=1in

pandoc docs/DEMO2-ARCHITECTURE-SETUP.md \
  -o docs/DEMO2-ARCHITECTURE-SETUP.pdf \
  --pdf-engine=pdflatex \
  -V geometry:margin=1in

# All docs at once
for file in docs/*.md; do
  pandoc "$file" \
    -o "${file%.md}.pdf" \
    --pdf-engine=pdflatex \
    -V geometry:margin=1in
done
```

---

## Option 2: Using Online Converters (No Installation)

### CloudConvert (Recommended)

1. Go to: https://cloudconvert.com/md-to-pdf
2. Upload your Markdown files
3. Convert to PDF
4. Download

### Markdown to PDF (Free)

1. Go to: https://www.markdowntopdf.com/
2. Paste Markdown content
3. Click "Convert"
4. Download PDF

---

## Option 3: Using VS Code Extension

### Install Extension

1. Open VS Code
2. Install "Markdown PDF" extension by yzane
3. Open any .md file
4. Right-click → "Markdown PDF: Export (pdf)"

**Settings (Optional):**
```json
{
  "markdown-pdf.displayHeaderFooter": true,
  "markdown-pdf.headerTemplate": "<div style='font-size: 9px; margin-left: 1cm;'><span class='title'></span></div>",
  "markdown-pdf.footerTemplate": "<div style='font-size: 9px; margin: 0 auto;'><span class='pageNumber'></span> / <span class='totalPages'></span></div>"
}
```

---

## Option 4: Using Chrome/Browser

### Print to PDF

1. Open any .md file in VS Code
2. Press `Cmd+Shift+V` (macOS) or `Ctrl+Shift+V` (Windows) for preview
3. Right-click preview → "Open in Browser"
4. In browser: `Cmd+P` or `Ctrl+P`
5. Select "Save as PDF"
6. Download

---

## Recommended PDFs to Generate

### For Upload to GitHub

1. **FINAL-COMPLETE-GUIDE.pdf** - Main comprehensive guide
2. **README.pdf** - Repository overview  
3. **COMPLETE-DEMO-SCRIPT.pdf** - Demo presentation script

### For Distribution

1. **Demo-Package.pdf** - Combine:
   - README.md
   - QUICK-COMMANDS.txt
   - DEMO2-QUICK-STEPS.txt

2. **Architecture-Guide.pdf** - Combine:
   - DEMO2-ARCHITECTURE-SETUP.md
   - SHOW-SETUP-IN-CONSOLE.md

---

## Customizing PDF Output

### With Pandoc

**Add Title Page:**
```bash
pandoc FINAL-COMPLETE-GUIDE.md \
  -o FINAL-COMPLETE-GUIDE.pdf \
  --pdf-engine=pdflatex \
  -V title="Policy as Code Demo" \
  -V subtitle="Complete Implementation Guide" \
  -V author="Your Name" \
  -V date="December 2025" \
  --toc
```

**Change Formatting:**
```bash
pandoc FINAL-COMPLETE-GUIDE.md \
  -o FINAL-COMPLETE-GUIDE.pdf \
  --pdf-engine=pdflatex \
  -V geometry:margin=1.5in \
  -V fontsize=12pt \
  -V linestretch=1.5 \
  -V colorlinks=true \
  --toc \
  --toc-depth=3
```

**Add Header/Footer:**
```bash
pandoc FINAL-COMPLETE-GUIDE.md \
  -o FINAL-COMPLETE-GUIDE.pdf \
  --pdf-engine=pdflatex \
  -V header-includes='\usepackage{fancyhdr}\pagestyle{fancy}\fhead{Policy as Code}\rhead{\today}' \
  --toc
```

---

## Quick Script to Generate All PDFs

Create `generate-pdfs.sh`:

```bash
#!/bin/bash

echo "📄 Generating PDFs..."

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "❌ Pandoc not found. Please install:"
    echo "   brew install pandoc basictex (macOS)"
    echo "   or use online converters"
    exit 1
fi

# Main guides
pandoc FINAL-COMPLETE-GUIDE.md -o FINAL-COMPLETE-GUIDE.pdf --pdf-engine=pdflatex -V geometry:margin=1in --toc
pandoc README.md -o README.pdf --pdf-engine=pdflatex -V geometry:margin=1in

# Documentation directory
mkdir -p docs/pdfs
for file in docs/*.md; do
    filename=$(basename "$file" .md)
    pandoc "$file" -o "docs/pdfs/${filename}.pdf" --pdf-engine=pdflatex -V geometry:margin=1in
done

echo "✅ PDFs generated successfully!"
echo "   - FINAL-COMPLETE-GUIDE.pdf"
echo "   - README.pdf"
echo "   - docs/pdfs/*.pdf"
```

Run it:
```bash
chmod +x generate-pdfs.sh
./generate-pdfs.sh
```

---

## Uploading to GitHub

### Add PDFs to Repository

```bash
# Create PDFs directory
mkdir -p pdfs

# Move PDFs
mv FINAL-COMPLETE-GUIDE.pdf pdfs/
mv README.pdf pdfs/

# Add to git
git add pdfs/
git commit -m "Add PDF documentation"
git push
```

### Or Add to Releases

1. Go to GitHub repository
2. Click "Releases" → "Create a new release"
3. Tag version (e.g., v1.0.0)
4. Upload PDFs as release assets
5. Publish release

---

## Best Practices

1. **Keep Markdown as Source** - PDFs are generated, not edited
2. **Update PDFs with Changes** - Regenerate when Markdown updates
3. **Version PDFs** - Include date or version in filename
4. **Optimize Size** - Compress large PDFs if needed
5. **Test PDFs** - Verify links and formatting work

---

## Troubleshooting

### "pdflatex not found"

**macOS:**
```bash
brew install basictex
# Add to PATH
export PATH=$PATH:/Library/TeX/texbin
```

**Linux:**
```bash
sudo apt-get install texlive-latex-base
```

### Fonts Issues

Install additional fonts:
```bash
brew install font-liberation  # macOS
sudo apt-get install fonts-liberation  # Linux
```

### Large File Size

Compress PDF:
```bash
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile=compressed.pdf input.pdf
```

---

## ✅ You're Ready!

Choose the method that works best for you:
- **Pandoc** - Best quality, full control
- **Online** - No installation needed
- **VS Code** - Quick and easy
- **Browser** - Built-in, no setup

Happy PDF creating! 📄
