# ==============================================================================
# Workshop IA Explicable (XAI) - Typst Slides & ANES 2024 Data
# ==============================================================================

SLIDES_DIR = slides
BUILD_DIR = build
PREVIEW_DIR = $(BUILD_DIR)/previews
TYPST = typst
PYTHON = python3

.PHONY: all slides preview data clean

all: slides

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(PREVIEW_DIR):
	mkdir -p $(PREVIEW_DIR)

data:
	$(PYTHON) data/prepare_anes2024.py

slides: $(BUILD_DIR)
	$(TYPST) compile --root . $(SLIDES_DIR)/xai-workshop.typ $(BUILD_DIR)/slides-xai.pdf
	@echo "✓ Diaporama compile : $(BUILD_DIR)/slides-xai.pdf"

preview: slides $(PREVIEW_DIR)
	rm -f $(PREVIEW_DIR)/*.png
	pdftoppm -png -r 130 $(BUILD_DIR)/slides-xai.pdf $(PREVIEW_DIR)/slide
	@echo "✓ Apercus PNG generes dans $(PREVIEW_DIR)/"

clean:
	rm -f $(BUILD_DIR)/*.pdf $(PREVIEW_DIR)/*.png
