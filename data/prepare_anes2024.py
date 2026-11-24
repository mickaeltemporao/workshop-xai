"""Single-source-of-truth data & model pipeline using real ANES 2024 survey data.

Source: American National Election Studies (ANES) 2024 Time Series Study
URL: https://raw.githubusercontent.com/datamisc/ts-2024/main/data.csv (gzipped CSV)
Generates:
  - data/anes2024_clean.csv : Cleaned 7-column subset (N = 4 734, English lowercase_underscore names)
  - app/model-data.json     : OLS + 329-param MLP weights + presets + 100 real scatter points (seed = 5, 1 < 10y)
  - app/model-data.js       : window.MODEL_DATA = ... (offline file:// compatibility)
"""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np
import pandas as pd
import statsmodels.formula.api as smf


FEATURES = [
    "education",
    "age",
    "employed",
    "married",
    "female",
    "minority",
]
TARGET = "annual_income"
ANES_URL = "https://raw.githubusercontent.com/datamisc/ts-2024/main/data.csv"
SCATTER_SAMPLE_SEED = 5  # Reproducible 100-row sample with exactly 1 respondent below 10 years (education = 8)

# 28 official ANES 2024 income brackets (V241566x) converted to midpoints in $k / year
MIDPOINTS_K = {
    1: 2.5, 2: 7.5,
    3: 11.25, 4: 13.75, 5: 16.25, 6: 18.75, 7: 21.25, 8: 23.75, 9: 26.25, 10: 28.75,
    11: 32.5, 12: 37.5, 13: 42.5, 14: 47.5, 15: 52.5, 16: 57.5,
    17: 62.5, 18: 67.5, 19: 72.5, 20: 77.5, 21: 85.0, 22: 95.0,
    23: 105.0, 24: 117.5, 25: 137.5, 26: 162.5, 27: 212.5, 28: 275.0,
}

# Recoding ANES education attainment (V241463) into equivalent years of schooling
EDUCATION_YEARS = {
    1: 6, 2: 8, 3: 9, 4: 10, 5: 11, 6: 11, 7: 11, 8: 11,
    9: 12, 10: 13, 11: 14, 12: 14, 13: 16, 14: 18, 15: 19, 16: 20,
}


def clean_anes2024(raw_df: pd.DataFrame) -> pd.DataFrame:
    """Filter valid respondents and build clean English lowercase_underscore predictors + annual_income."""
    sub = raw_df[
        (raw_df["V241566x"].isin(MIDPOINTS_K))
        & (raw_df["V241458x"] >= 18)
        & (raw_df["V241463"].isin(EDUCATION_YEARS))
        & (raw_df["V241488x"] > 0)
        & (raw_df["V241461x"] > 0)
        & (raw_df["V241550"].isin([1, 2]))
        & (raw_df["V241501x"] > 0)
    ].copy()

    return pd.DataFrame(
        {
            "education": sub["V241463"].map(EDUCATION_YEARS).astype(int),
            "age": sub["V241458x"].astype(int),
            "employed": (sub["V241488x"] == 1).astype(int),
            "married": (sub["V241461x"] == 1).astype(int),
            "female": (sub["V241550"] == 2).astype(int),
            "minority": (sub["V241501x"] != 1).astype(int),
            "annual_income": (sub["V241566x"].map(MIDPOINTS_K) * 1000.0).round(0),
        }
    ).reset_index(drop=True)


def with_jitter(df_sub: pd.DataFrame, seed: int) -> list[dict]:
    """Attach deterministic visual jitter (dx, dy) while keeping exact values (x, y)."""
    rng = np.random.default_rng(seed)
    pts = []
    for row in df_sub.itertuples(index=False):
        jx = float(rng.uniform(-0.32, 0.32))
        jy = float(rng.uniform(-2800.0, 2800.0))
        x_exact = int(row.education)
        y_exact = round(float(row.annual_income), 0)
        dx = round(float(np.clip(x_exact + jx, 0.2, 20.8)), 2)
        dy = round(float(np.clip(y_exact + jy, 2500.0, 278000.0)), 0)
        pts.append({"x": x_exact, "y": y_exact, "dx": dx, "dy": dy})
    return pts


def train_blackbox_mlp(x_mat: np.ndarray, y_vec: np.ndarray, seed: int = 42) -> dict:
    """Train a 2-hidden-layer MLP (6 -> 16 -> 12 -> 1, 329 params) in NumPy."""
    rng = np.random.default_rng(seed)

    scaler_mean = x_mat.mean(axis=0)
    scaler_std = x_mat.std(axis=0)
    x_scaled = (x_mat - scaler_mean) / scaler_std

    y_mean = float(y_vec.mean())
    y_std = float(y_vec.std())
    y_scaled = ((y_vec - y_mean) / y_std).reshape(-1, 1)

    # Architecture: 6 -> 16 -> 12 -> 1
    # Params: (6*16 + 16) + (16*12 + 12) + (12*1 + 1) = 112 + 204 + 13 = 329
    w1 = rng.normal(0, np.sqrt(2 / 6), size=(6, 16))
    b1 = np.zeros((1, 16))
    w2 = rng.normal(0, np.sqrt(2 / 16), size=(16, 12))
    b2 = np.zeros((1, 12))
    w3 = rng.normal(0, np.sqrt(1 / 12), size=(12, 1))
    b3 = np.zeros((1, 1))

    params = [w1, b1, w2, b2, w3, b3]
    m_adam = [np.zeros_like(p) for p in params]
    v_adam = [np.zeros_like(p) for p in params]

    lr = 0.009
    beta1, beta2, eps = 0.9, 0.999, 1e-8
    l2_reg = 0.005
    n_samples = x_scaled.shape[0]

    def tanh_deriv(a: np.ndarray) -> np.ndarray:
        return 1.0 - a * a

    for step in range(1, 1101):
        z1 = x_scaled @ params[0] + params[1]
        a1 = np.tanh(z1)
        z2 = a1 @ params[2] + params[3]
        a2 = np.tanh(z2)
        y_hat = a2 @ params[4] + params[5]

        err = y_hat - y_scaled
        d_yhat = (2.0 / n_samples) * err

        g_w3 = a2.T @ d_yhat + l2_reg * params[4]
        g_b3 = np.sum(d_yhat, axis=0, keepdims=True)
        da2 = d_yhat @ params[4].T
        dz2 = da2 * tanh_deriv(a2)

        g_w2 = a1.T @ dz2 + l2_reg * params[2]
        g_b2 = np.sum(dz2, axis=0, keepdims=True)
        da1 = dz2 @ params[2].T
        dz1 = da1 * tanh_deriv(a1)

        g_w1 = x_scaled.T @ dz1 + l2_reg * params[0]
        g_b1 = np.sum(dz1, axis=0, keepdims=True)

        grads = [g_w1, g_b1, g_w2, g_b2, g_w3, g_b3]
        for idx, (p, g) in enumerate(zip(params, grads)):
            m_adam[idx] = beta1 * m_adam[idx] + (1 - beta1) * g
            v_adam[idx] = beta2 * v_adam[idx] + (1 - beta2) * (g * g)
            m_hat = m_adam[idx] / (1 - beta1**step)
            v_hat = v_adam[idx] / (1 - beta2**step)
            p -= lr * m_hat / (np.sqrt(v_hat) + eps)

    z1 = x_scaled @ params[0] + params[1]
    a1 = np.tanh(z1)
    z2 = a1 @ params[2] + params[3]
    a2 = np.tanh(z2)
    y_pred = np.clip((a2 @ params[4] + params[5]).ravel() * y_std + y_mean, 2500.0, 275000.0)

    ss_res = float(np.sum((y_vec - y_pred) ** 2))
    ss_tot = float(np.sum((y_vec - y_vec.mean()) ** 2))
    r2 = 1.0 - ss_res / ss_tot
    rmse = float(np.sqrt(np.mean((y_vec - y_pred) ** 2)))
    n_params = int(sum(p.size for p in params))

    return {
        "architecture": [6, 16, 12, 1],
        "activation": "tanh",
        "n_params": n_params,
        "r2": round(r2, 4),
        "rmse": round(rmse, 0),
        "scaler_mean": [round(float(v), 6) for v in scaler_mean],
        "scaler_std": [round(float(v), 6) for v in scaler_std],
        "y_mean": round(y_mean, 6),
        "y_std": round(y_std, 6),
        "W1": np.round(params[0], 5).tolist(),
        "b1": np.round(params[1].ravel(), 5).tolist(),
        "W2": np.round(params[2], 5).tolist(),
        "b2": np.round(params[3].ravel(), 5).tolist(),
        "W3": np.round(params[4].ravel(), 5).tolist(),
        "b3": round(float(params[5].ravel()[0]), 5),
    }


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    raw_path = root / "data" / "anes2024_raw7.csv"
    clean_path = root / "data" / "anes2024_clean.csv"

    if raw_path.exists():
        raw_df = pd.read_csv(raw_path)
        df = clean_anes2024(raw_df)
        df.to_csv(clean_path, index=False)
    else:
        df = pd.read_csv(clean_path)

    # 1. Simple OLS: annual_income ~ education
    model_simple = smf.ols("annual_income ~ education", data=df).fit()
    simple_pred = model_simple.predict(df)
    simple_rmse = float(np.sqrt(np.mean((df[TARGET] - simple_pred) ** 2)))

    # 2. Multiple OLS (7 parameters)
    formula_full = "annual_income ~ education + age + employed + married + female + minority"
    model_full = smf.ols(formula_full, data=df).fit()
    full_pred = model_full.predict(df)
    full_rmse = float(np.sqrt(np.mean((df[TARGET] - full_pred) ** 2)))

    # 3. Real Black-Box MLP (329 params)
    x_mat = df[FEATURES].to_numpy(dtype=float)
    y_vec = df[TARGET].to_numpy(dtype=float)
    mlp_data = train_blackbox_mlp(x_mat, y_vec, seed=42)

    # 100 real respondents sampled with SCATTER_SAMPLE_SEED = 5 (includes 1 respondent < 10 years)
    sample_df = df.sample(n=100, random_state=SCATTER_SAMPLE_SEED)[["education", "annual_income"]]
    below_10_n = int((sample_df["education"] < 10).sum())
    assert below_10_n == 1, f"Expected 1 respondent < 10 years, got {below_10_n}"
    scatter_sample = with_jitter(sample_df, seed=101)

    sample_ols = smf.ols("annual_income ~ education", data=sample_df).fit()
    sample_pred = sample_ols.predict(sample_df)
    sample_rmse = float(np.sqrt(np.mean((sample_df["annual_income"] - sample_pred) ** 2)))

    feature_means = {col: round(float(df[col].mean()), 3) for col in FEATURES}

    feature_meta = [
        {
            "key": "education",
            "label": "Annees d'etudes equivalentes",
            "short_label": "Etudes",
            "unit": "ans",
            "min": 6,
            "max": 20,
            "step": 1,
            "mean": feature_means["education"],
            "type": "slider",
            "protected": False,
            "hint": "12 = Bac / High school, 16 = Licence (Bachelor), 18 = Master, 20 = Doctorat.",
        },
        {
            "key": "age",
            "label": "Age",
            "short_label": "Age",
            "unit": "ans",
            "min": 18,
            "max": 80,
            "step": 1,
            "mean": round(float(df["age"].mean()), 1),
            "type": "slider",
            "protected": False,
            "hint": "Age du repondant (18 a 80 ans). L'effet reel n'est pas lineaire entre carriere et retraite.",
        },
        {
            "key": "employed",
            "label": "Statut d'activite",
            "short_label": "En emploi",
            "unit": "0=Non, 1=En emploi",
            "min": 0,
            "max": 1,
            "step": 1,
            "mean": feature_means["employed"],
            "type": "toggle",
            "protected": False,
            "options": ["Hors emploi (0)", "En emploi (1)"],
            "hint": "En emploi (20h+/semaine) ou retraite / hors emploi / etudiant.",
        },
        {
            "key": "married",
            "label": "Situation maritale",
            "short_label": "Marie·e",
            "unit": "0=Non, 1=Marie·e",
            "min": 0,
            "max": 1,
            "step": 1,
            "mean": feature_means["married"],
            "type": "toggle",
            "protected": False,
            "options": ["Non marie·e (0)", "Marie·e (1)"],
            "hint": "Marie·e (foyer souvent a deux revenus) vs celibataire / divorce·e / veuf·ve.",
        },
        {
            "key": "female",
            "label": "Sexe",
            "short_label": "Femme",
            "unit": "0=Homme, 1=Femme",
            "min": 0,
            "max": 1,
            "step": 1,
            "mean": feature_means["female"],
            "type": "toggle",
            "protected": True,
            "options": ["Homme (0)", "Femme (1)"],
            "hint": "Effet statistiquement significatif (p < 0,001) a profil comparable.",
        },
        {
            "key": "minority",
            "label": "Origine",
            "short_label": "Minorite",
            "unit": "0=Blanc non-hisp., 1=Minorite",
            "min": 0,
            "max": 1,
            "step": 1,
            "mean": feature_means["minority"],
            "type": "toggle",
            "protected": True,
            "options": ["Blanc non-hisp. (0)", "Minorite racisee (1)"],
            "hint": "Effet statistiquement significatif (p < 0,001) a profil comparable.",
        },
    ]

    presets = [
        {
            "id": "typical",
            "label": "Profil typique (median)",
            "description": "14 ans d'etudes, 52 ans, en emploi, marie, homme blanc.",
            "values": {
                "education": 14,
                "age": 52,
                "employed": 1,
                "married": 1,
                "female": 0,
                "minority": 0,
            },
        },
        {
            "id": "young_graduate",
            "label": "Jeune diplomee active",
            "description": "16 ans d'etudes, 29 ans, en emploi, non mariee, femme.",
            "values": {
                "education": 16,
                "age": 29,
                "employed": 1,
                "married": 0,
                "female": 1,
                "minority": 0,
            },
        },
        {
            "id": "career_couple",
            "label": "Couple diplome en carriere",
            "description": "18 ans d'etudes, 46 ans, en emploi, marie, homme blanc.",
            "values": {
                "education": 18,
                "age": 46,
                "employed": 1,
                "married": 1,
                "female": 0,
                "minority": 0,
            },
        },
        {
            "id": "retired_single",
            "label": "Retraitee seule",
            "description": "12 ans d'etudes, 72 ans, hors emploi, femme minorite.",
            "values": {
                "education": 12,
                "age": 72,
                "employed": 0,
                "married": 0,
                "female": 1,
                "minority": 1,
            },
        },
    ]

    payload = {
        "metadata": {
            "n": int(len(df)),
            "scatter_n": int(len(scatter_sample)),
            "scatter_seed": SCATTER_SAMPLE_SEED,
            "scatter_below_10_n": below_10_n,
            "dataset": "ANES 2024 Time Series Study (USA)",
            "source_url": ANES_URL,
            "target": TARGET,
            "target_label": "Revenu annuel du foyer ($ US / an)",
            "target_mean": round(float(df[TARGET].mean()), 0),
            "target_median": round(float(df[TARGET].median()), 0),
            "target_std": round(float(df[TARGET].std()), 0),
            "note": "Donnees reelles ANES 2024 (N = 4 734 repondant·es, USA).",
        },
        "feature_meta": feature_meta,
        "simple_ols": {
            "formula": "annual_income ~ education",
            "n_params": 2,
            "intercept": round(float(model_simple.params["Intercept"]), 1),
            "slope": round(float(model_simple.params["education"]), 1),
            "r2": round(float(model_simple.rsquared), 4),
            "rmse": round(simple_rmse, 0),
            "pvalue_slope": float(model_simple.pvalues["education"]),
            "sample100_intercept": round(float(sample_ols.params["Intercept"]), 1),
            "sample100_slope": round(float(sample_ols.params["education"]), 1),
            "sample100_r2": round(float(sample_ols.rsquared), 4),
            "sample100_rmse": round(sample_rmse, 0),
        },
        "full_ols": {
            "formula": formula_full,
            "n_params": 7,
            "intercept": round(float(model_full.params["Intercept"]), 1),
            "params": {k: round(float(model_full.params[k]), 1) for k in FEATURES},
            "pvalues": {k: float(model_full.pvalues[k]) for k in FEATURES},
            "r2": round(float(model_full.rsquared), 4),
            "rmse": round(full_rmse, 0),
            "baseline_mean_pred": round(
                float(
                    model_full.params["Intercept"]
                    + sum(model_full.params[k] * float(df[k].mean()) for k in FEATURES)
                ),
                0,
            ),
        },
        "scatter_sample": scatter_sample,
        "blackbox_mlp": mlp_data,
        "presets": presets,
    }

    json_path = root / "app" / "model-data.json"
    js_path = root / "app" / "model-data.js"
    json_str = json.dumps(payload, indent=2, ensure_ascii=False)
    json_path.write_text(json_str + "\n", encoding="utf-8")
    js_path.write_text(f"window.MODEL_DATA = {json_str};\n", encoding="utf-8")

    print("=== SUMMARY ANES 2024 (Single Source of Truth) ===")
    print(
        f"N = {len(df)}, Target mean = {payload['metadata']['target_mean']:.0f} $/an, "
        f"median = {payload['metadata']['target_median']:.0f} $/an, std = {payload['metadata']['target_std']:.0f} $/an"
    )
    print("Simple OLS (annual_income ~ education, 2 params):")
    print(
        f"  Full N=4734 : Intercept = {payload['simple_ols']['intercept']:.1f}, slope = {payload['simple_ols']['slope']:+.1f} $/an, "
        f"R2 = {payload['simple_ols']['r2']:.4f}, RMSE = {payload['simple_ols']['rmse']:.0f} $/an"
    )
    print(
        f"  Sample 100 (seed={SCATTER_SAMPLE_SEED}, <10y={below_10_n}): "
        f"Intercept = {payload['simple_ols']['sample100_intercept']:.1f}, "
        f"slope = {payload['simple_ols']['sample100_slope']:+.1f} $/an, "
        f"R2 = {payload['simple_ols']['sample100_r2']:.4f}, RMSE = {payload['simple_ols']['sample100_rmse']:.0f} $/an"
    )
    print("Full OLS (7 params):")
    print(f"  Intercept = {payload['full_ols']['intercept']:.1f}, R2 = {payload['full_ols']['r2']:.4f}, RMSE = {payload['full_ols']['rmse']:.0f} $/an")
    for k in FEATURES:
        print(
            f"  {k:12s}: coef = {payload['full_ols']['params'][k]:+9.1f} $/an "
            f"(p = {payload['full_ols']['pvalues'][k]:.2e}, mean = {feature_means[k]:.3f})"
        )
    print(f"Black-Box MLP ({mlp_data['n_params']} params): R2 = {mlp_data['r2']:.4f}, RMSE = {mlp_data['rmse']:.0f} $/an")
    for p in presets:
        v = p["values"]
        ols_p = payload["full_ols"]["intercept"] + sum(payload["full_ols"]["params"][k] * v[k] for k in FEATURES)
        print(f"  Preset {p['id']:20s}: OLS = {ols_p:.0f} $/an")


if __name__ == "__main__":
    main()
