# Atelier : IA Explicable (XAI) - De la régression aux grands modèles de langage

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/mickaeltemporao/workshop-xai/blob/main/notebooks/atelier-xai-citoyen.ipynb)

Support complet pour une séance de **35 à 40 minutes** en français destinée à des chercheur·ses et étudiant·es en sciences sociales ayant peu ou pas de bagage en programmation Python :

- **Présentation (15 à 20 min)** : diaporama Typst ([slides/xai-workshop.typ](slides/xai-workshop.typ)) sur les notions de modèle (heuristique), d'algorithme (recette), d'apprentissage supervisé / non supervisé, de régression « boîte de verre » (`revenu_annuel ~ etudes`, `2` puis `7` paramètres) sur de **vraies données d'enquête (`ANES 2024`, `N = 4 734`)**, audit de biais sur **deux attributs protégés (`femme` et `minorite`, `p < 0,001`)**, jusqu'au deep learning (`329` paramètres) et aux grands modèles de langage (`70 Md à 1 000+ Md` de paramètres).
- **Application interactive (démo + prise en main)** : **Le Laboratoire du Revenu** ([app/index.html](app/index.html)), une application statique HTML/CSS/JS sans dépendance externe, prête pour **Vercel** et fonctionnelle hors ligne (`file://`), organisée en **5 onglets** :
  1. **`Accueil`** : introduction simple en français (modèle = heuristique avec citation de George Box, algorithme = recette, principe de l'IA Explicable).
  2. **`1 paramètre`** : `50` points réels `ANES 2024` avec léger jitter esthétique, bouton **`+ 250 points réels (ANES)`**, ajout de points au clic et résidus sur 100 % des points.
  3. **`Quelques paramètres`** : régression OLS à `7` paramètres, double audit de biais (`femme`, `minorite`) et comparaison contrefactuelle `Profil A`.
  4. **`Deep learning`** : comparaison boîte de verre (`7` params) vs boîte noire (`329` params) avec schéma SVG interactif du réseau de neurones (`6 → 16 → 12 → 1`) et sonde XAI locale.
  5. **`Notebook Colab`** : liens directs vers le notebook Google Colab et le dépôt GitHub ([github.com/mickaeltemporao/workshop-xai](https://github.com/mickaeltemporao/workshop-xai)).
- **Atelier pratique Google Colab (15 à 20 min)** : notebook guidé ([notebooks/atelier-xai-citoyen.ipynb](notebooks/atelier-xai-citoyen.ipynb)) chargeant directement `ANES 2024` avec `statsmodels` (`smf.ols`) et des curseurs interactifs pour auditer l'effet de chaque levier et des attributs protégés.

---

## Structure du dépôt

```text
workshop-2026-xai/
├── Makefile                          # Compilation Typst, prévisualisations PNG et préparation ANES 2024
├── README.md                         # Documentation et accès direct Google Colab
├── branding/                         # Charte graphique Sciences Po Bordeaux (logo + polices Bitter / Myriad Pro)
├── template/
│   └── iep-slides.typ                # Gabarit Typst minimaliste localisé en français
├── slides/
│   └── xai-workshop.typ              # Diaporama épuré (16 diapositives, blanc/gris + rouge IEP)
├── data/
│   ├── prepare_anes2024.py           # Source unique : prépare ANES 2024, OLS (2 & 7 params), MLP (329 poids), jitter
│   └── anes2024_clean.csv            # Jeu nettoyé issu d'ANES 2024 (N = 4 734 répondant·es, 7 colonnes)
├── app/
│   ├── index.html                    # Application web interactive en 5 onglets
│   ├── styles.css                    # Mise en page éditoriale responsive
│   ├── app.js                        # Navigation 5 onglets, nuage 50/300 pts + clic & jitter, OLS, SVG MLP & sonde XAI
│   ├── model-data.json               # Paramètres exportés par prepare_anes2024.py
│   ├── model-data.js                 # Copie JS pour usage hors ligne en file:// sans serveur
│   └── vercel.json                   # Configuration statique Vercel
├── notebooks/
│   └── atelier-xai-citoyen.ipynb     # Notebook Google Colab (zéro installation, charge ANES 2024 en gzip)
└── build/
    └── slides-xai.pdf                # PDF compilé des diapositives
```

---

## 1. Compiler les diapositives (Typst)

Depuis la racine du projet :

```bash
make slides
```

Le PDF est généré dans `build/slides-xai.pdf`. Pour générer aussi les aperçus PNG (`build/previews/slide-*.png`) :

```bash
make preview
```

Pour régénérer les paramètres exportés (`app/model-data.json` et `app/model-data.js`) depuis `data/anes2024_clean.csv` :

```bash
make data
```

---

## 2. Déployer l'application interactive sur Vercel

Le dossier `app/` est 100 % statique (aucun build requis, zéro dépendance CDN pour l'exécution).

### Option A : via la CLI Vercel
```bash
cd app
npx vercel --prod
```

### Option B : via GitHub + Vercel
1. Poussez ce dépôt sur GitHub (`https://github.com/mickaeltemporao/workshop-xai`).
2. Sur Vercel (`New Project`), importez le dépôt et définissez **Root Directory** sur `app`.
3. Laissez **Build Command** vide et **Output Directory** sur `.`.

### Usage hors ligne (sans connexion Internet)
Ouvrez directement `app/index.html` dans n'importe quel navigateur : les `50 + 250` points réels avec jitter, les coefficients OLS et les `329` poids du réseau de neurones sont déjà embarqués dans `app/model-data.js`.

---

## 3. Lancer le notebook Google Colab

Ouvrez directement le notebook dans Google Colab (aucune installation locale requise) :

- **Lien direct Colab :** `https://colab.research.google.com/github/mickaeltemporao/workshop-xai/blob/main/notebooks/atelier-xai-citoyen.ipynb`
- **Dépôt GitHub :** `https://github.com/mickaeltemporao/workshop-xai`

Tous les paquets utilisés (`numpy`, `pandas`, `statsmodels`, `matplotlib`) sont préinstallés sur Colab : aucune commande `!pip install` n'est nécessaire. Le chargement lit directement `https://raw.githubusercontent.com/datamisc/ts-2024/main/data.csv` avec `compression="gzip"`.

---

## Source des données et repères statistiques (`ANES 2024`)

Les données proviennent de l'enquête **American National Election Studies (ANES) 2024 Time Series Study** (`https://raw.githubusercontent.com/datamisc/ts-2024/main/data.csv`, `N = 4 734` répondant·es valides). Variable cible : `revenu_annuel` (revenu annuel du foyer en `$ US / an`, issu des 28 tranches `V241566x` converties aux centres officiels de `2 500 $` à `275 000 $` ; moyenne `97 347 $ / an`, médiane `77 500 $ / an`).

- **Régression simple (`revenu_annuel ~ etudes`, `2` paramètres)** : `Intercept = -100 399 $`, pente `etudes = +13 445 $ / an` par année d'études, `R² = 0,18`, `RMSE = 70 289 $ / an` (`50` points affichés par défaut dans l'onglet `1 paramètre` + option `+ 250 points réels` avec jitter esthétique, résidus sur 100 % des points et ajout interactif au clic).
- **Régression multiple (`7` paramètres)** : `etudes (+10 998 $/an)`, `age (-227 $/an)`, `en_emploi (+24 855 $/an)`, `marie (+48 093 $/an)`, et **deux attributs protégés hautement significatifs (`p < 0,001`)** : **`femme (-8 007 $/an)`** et **`minorite (-10 328 $/an)`** ; `R² = 0,31`, `RMSE = 64 267 $ / an`.
- **Deep learning (`6 → 16 → 12 → 1`, `329` paramètres)** : `R² = 0,34`, `RMSE = 62 837 $ / an`, illustrant la courbe non linéaire de l'âge (positif en début de carrière, négatif après la retraite), le risque de **variables proxy** dans la boîte noire et les obligations de l'**AI Act européen**.

---

## Note sur l'usage de l'IA (AI Disclaimer)

Certaines parties de ce projet (code de l'application interactive, notebook pédagogique et supports de présentation) ont été conçues avec l'assistance d'outils d'IA générative. L'ensemble des contenus, analyses statistiques sur `ANES 2024`, équations et explications reste sous la responsabilité éditoriale et scientifique de l'intervenant, qui a vérifié et validé chaque étape.
