# Explainable AI (XAI) Workshop

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/mickaeltemporao/workshop-xai/blob/main/notebooks/atelier-xai-citoyen.ipynb)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

Teaching materials (in French) for a **35 to 40 minute** introductory workshop on Explainable AI (XAI) designed for social science researchers and students with little or no Python background.

## What is included

- **Typst Slides (`15-20 min`)**: [slides/xai-workshop.typ](slides/xai-workshop.typ) (compiled PDF in [build/slides-xai.pdf](build/slides-xai.pdf)) covering models as heuristics, algorithms as recipes, glass-box regressions (`annual_income ~ education`, `2` and `7` parameters) vs. neural networks (`329` parameters) and LLMs, bias auditing (`female`, `minority`), and local XAI probes.
- **Interactive Web App**: [app/index.html](app/index.html) is a zero-dependency static HTML/CSS/JS app (Vercel-ready and offline `file://` compatible) organized in **5 full-width tabs**:
  1. **`Introduction`**: George Box's quote and core intuition (model, algorithm, XAI).
  2. **`Une droite`**: fit a line starting at `(0, 0)` over `100` real respondents (`seed = 5`, including `1` point at `education = 8`), toggle residuals on all points, or click to add points.
  3. **`Des paramètres`**: `7`-parameter OLS model with `p < 0.001 ***` significance tags and `Profil A` counterfactual comparison.
  4. **`Deep Learning`**: compare the `7`-parameter glass box to a `329`-parameter interactive SVG neural network (`6 -> 16 -> 12 -> 1`) using local perturbation probes (including the COMPAS proxy example).
  5. **`Hack-time`**: direct links to launch the Google Colab notebook.
- **Google Colab Notebook (`15-20 min`)**: [notebooks/atelier-xai-citoyen.ipynb](notebooks/atelier-xai-citoyen.ipynb) loads ANES 2024 directly with `statsmodels` (`smf.ols`) and interactive form sliders. No local installation required.

---

## Repository structure

```text
workshop-2026-xai/
├── LICENSE                           # CC BY-NC-SA 4.0 license
├── Makefile                          # Build slides, PNG previews, and JSON/JS model data
├── README.md                         # Workshop overview
├── branding/                         # Sciences Po Bordeaux logo and fonts
├── template/
│   └── iep-slides.typ                # Minimalist Typst slide template
├── slides/
│   └── xai-workshop.typ              # 16-slide deck (monochrome + IEP red)
├── data/
│   ├── prepare_anes2024.py           # Data prep, OLS (2 & 7 params), MLP (329 weights), seed=5 jittered sample
│   └── anes2024_clean.csv            # Cleaned ANES 2024 subset (N = 4 734, English lowercase_underscore columns)
├── app/
│   ├── index.html                    # 5-tab static web app
│   ├── styles.css                    # Responsive layout
│   ├── app.js                        # OLS/MLP math, SVG scatter & interactive neural network
│   ├── model-data.json               # Precomputed model parameters and 100-point sample
│   ├── model-data.js                 # Offline file:// copy
│   └── vercel.json                   # Static Vercel config
├── notebooks/
│   └── atelier-xai-citoyen.ipynb     # Guided Google Colab notebook
└── build/
    └── slides-xai.pdf                # Compiled slide deck
```

---

## Usage

### Build slides & regenerate data
```bash
make data      # Regenerate app/model-data.json and app/model-data.js
make slides    # Compile build/slides-xai.pdf
make preview   # Export PNG previews to build/previews/
```

### Deploy the web app on Vercel
Deploy `app/` directly as a static directory (**Root Directory**: `app`, empty build command, output directory `.`) or run `npx vercel --prod` inside `app/`.

### Data source (`ANES 2024`)
Variables extracted from the **American National Election Studies (ANES) 2024 Time Series Study** (`N = 4 734`): `education`, `age`, `employed`, `married`, `female`, `minority`, and `annual_income` (`$ US / year`, bracket midpoints). The `100`-point scatter sample uses `SCATTER_SAMPLE_SEED = 5` (includes `1` respondent below `10` years of schooling at `education = 8`).

---

## AI Disclaimer

Parts of this project (web application code, pedagogical notebook, and slide materials) were created with the assistance of generative AI tools. All code, statistical analyses on `ANES 2024`, equations, and explanations were reviewed and validated under the responsibility of the author.

---

## License

Copyright (c) 2026 [Mickael Temporão](https://github.com/mickaeltemporao).
This work is licensed under [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/). See [LICENSE](LICENSE).
