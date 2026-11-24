(function () {
  "use strict";

  var SVG_NS = "http://www.w3.org/2000/svg";
  var PRED_MIN = 2500;
  var PRED_MAX = 275000;
  var TAB1_DEFAULT_B0 = 0;
  var TAB1_DEFAULT_B1 = 6000;

  var FRENCH_PRESET_COPY = {
    typique: {
      label: "Profil typique (médian)",
      description: "14 ans d'études, 52 ans, en emploi, marié, homme blanc."
    },
    jeune_diplomee: {
      label: "Jeune diplômée active",
      description: "16 ans d'études, 29 ans, en emploi, non mariée, femme."
    },
    couple_master: {
      label: "Couple diplômé en carrière",
      description: "18 ans d'études, 46 ans, en emploi, marié, homme blanc."
    },
    retraitee_minorite: {
      label: "Retraitée seule",
      description: "12 ans d'études, 72 ans, hors emploi, femme minorité."
    }
  };

  var FRENCH_FEATURE_COPY = {
    etudes: {
      label: "Années d'études",
      short: "Études",
      unit: "ans",
      hint: "12 = Bac / High school, 16 = Licence (Bachelor), 18 = Master, 20 = Doctorat."
    },
    age: {
      label: "Âge",
      short: "Âge",
      unit: "ans",
      hint: "Âge du répondant (18 à 80 ans). L'effet réel varie entre début de carrière, pic et retraite."
    },
    en_emploi: {
      label: "Statut d'activité",
      short: "En emploi",
      unit: "0 = Non, 1 = En emploi",
      options: ["Hors emploi (0)", "En emploi (1)"],
      hint: "En emploi (20h+/semaine) ou retraité / hors emploi / étudiant."
    },
    marie: {
      label: "Situation maritale",
      short: "Marié·e",
      unit: "0 = Non, 1 = Marié·e",
      options: ["Non marié·e (0)", "Marié·e (1)"],
      hint: "Marié·e (foyer souvent à deux revenus) ou célibataire / divorcé·e / veuf·ve."
    },
    femme: {
      label: "Sexe",
      short: "Femme",
      unit: "0 = Homme, 1 = Femme",
      options: ["Homme (0)", "Femme (1)"],
      hint: "Effet statistiquement significatif (p < 0,001) à profil comparable."
    },
    minorite: {
      label: "Origine",
      short: "Minorité",
      unit: "0 = Blanc non-hisp., 1 = Minorité",
      options: ["Blanc non-hisp. (0)", "Minorité racisée (1)"],
      hint: "Effet statistiquement significatif (p < 0,001) à profil comparable."
    }
  };

  var state = {
    data: null,
    activeTab: "1",
    b0: TAB1_DEFAULT_B0,
    b1: TAB1_DEFAULT_B1,
    addedPoints: [],
    showResiduals: false,
    olsAnimId: null,
    profile: {
      etudes: 14,
      age: 52,
      en_emploi: 1,
      marie: 1,
      femme: 0,
      minorite: 0
    },
    lastChangedKey: "etudes",
    profileA: null,
    tab3Mode: "glass",
    probeOpen: false,
    mlpPinnedSelection: null,
    mlpLastPred: null
  };

  var el = {};

  function cacheElements() {
    el.paramBadge = document.getElementById("param-badge");
    el.dataNote = document.getElementById("data-note");
    el.tabBtns = Array.prototype.slice.call(document.querySelectorAll(".tab-btn"));
    el.goTabBtns = Array.prototype.slice.call(document.querySelectorAll("[data-go-tab]"));
    el.tabPanels = {
      "1": document.getElementById("tab-panel-1"),
      "2": document.getElementById("tab-panel-2"),
      "3": document.getElementById("tab-panel-3"),
      "4": document.getElementById("tab-panel-4"),
      "5": document.getElementById("tab-panel-5")
    };

    el.scatterSvg = document.getElementById("scatter-svg");
    el.scatterTooltip = document.getElementById("scatter-tooltip");
    el.scatterCountBadge = document.getElementById("scatter-count-badge");
    el.toggleResiduals = document.getElementById("toggle-residuals");
    el.sliderB0 = document.getElementById("slider-b0");
    el.sliderB1 = document.getElementById("slider-b1");
    el.valB0 = document.getElementById("val-b0");
    el.valB1 = document.getElementById("val-b1");
    el.tab1EqLive = document.getElementById("tab1-eq-live");
    el.btnFindOls = document.getElementById("btn-find-ols");
    el.btnResetTab1 = document.getElementById("btn-reset-tab1");
    el.btnClearPoints = document.getElementById("btn-clear-points");
    el.tab1RmseUserLabel = document.getElementById("tab1-rmse-user-label");
    el.tab1RmseOlsLabel = document.getElementById("tab1-rmse-ols-label");
    el.tab1RmseUser = document.getElementById("tab1-rmse-user");
    el.tab1RmseOls = document.getElementById("tab1-rmse-ols");
    el.tab1MeterFill = document.getElementById("tab1-meter-fill");
    el.tab1MeterStatus = document.getElementById("tab1-meter-status");
    el.tab1GlobalNote = document.getElementById("tab1-global-note");
    el.tab1OlsReveal = document.getElementById("tab1-ols-reveal");
    el.tab1BadgeR2 = document.getElementById("tab1-badge-r2");
    el.tab1BadgeRmse = document.getElementById("tab1-badge-rmse");
    el.tab1OlsInterp = document.getElementById("tab1-ols-interpretation");

    el.presetsTab2 = document.getElementById("presets-tab2");
    el.leversTab2 = document.getElementById("levers-tab2");
    el.btnResetTab2 = document.getElementById("btn-reset-tab2");
    el.tab2ScoreValue = document.getElementById("tab2-score-value");
    el.tab2ScoreTag = document.getElementById("tab2-score-tag");
    el.tab2LiveMarker = document.getElementById("tab2-live-marker");
    el.tab2GhostMarker = document.getElementById("tab2-ghost-marker");
    el.btnFreezeA = document.getElementById("btn-freeze-a");
    el.btnClearA = document.getElementById("btn-clear-a");
    el.compareReadout = document.getElementById("compare-readout");
    el.tab2ContribChart = document.getElementById("tab2-contrib-chart");
    el.tab2EquationLive = document.getElementById("tab2-equation-live");

    el.presetsTab3 = document.getElementById("presets-tab3");
    el.leversTab3 = document.getElementById("levers-tab3");
    el.btnResetTab3 = document.getElementById("btn-reset-tab3");
    el.modeBtnGlass = document.getElementById("mode-btn-glass");
    el.modeBtnBlack = document.getElementById("mode-btn-black");
    el.tab3ScoreOls = document.getElementById("tab3-score-ols");
    el.tab3ScoreMlp = document.getElementById("tab3-score-mlp");
    el.tab3ModelEyebrow = document.getElementById("tab3-model-eyebrow");
    el.tab3ModelTitle = document.getElementById("tab3-model-title");
    el.tab3ActiveScore = document.getElementById("tab3-active-score");
    el.tab3GlassView = document.getElementById("tab3-glass-view");
    el.tab3GlassEq = document.getElementById("tab3-glass-eq");
    el.tab3BlackView = document.getElementById("tab3-black-view");
    el.mlpSvg = document.getElementById("mlp-svg");
    el.mlpInspector = document.getElementById("mlp-inspector");
    el.btnRunProbe = document.getElementById("btn-run-probe");
    el.probeResults = document.getElementById("probe-results");
    el.probeBars = document.getElementById("probe-bars");
    el.probeCallout = document.getElementById("probe-callout");
    el.probeProxyCallout = document.getElementById("probe-proxy-callout");
  }

  function fmt(num, decimals) {
    var d = typeof decimals === "number" ? decimals : 0;
    var val = Number(num);
    var absFixed = Math.abs(val).toFixed(d);
    var parts = absFixed.split(".");
    var intPart = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, " ");
    var sign = val < 0 && Number(absFixed) !== 0 ? "-" : "";
    return sign + (parts.length > 1 ? intPart + "," + parts[1] : intPart);
  }

  function fmtSigned(num, decimals) {
    var d = typeof decimals === "number" ? decimals : 0;
    var val = Number(num);
    var prefix = val >= 0 ? "+" : "-";
    return prefix + fmt(Math.abs(val), d);
  }

  function fmtDollar(num, decimals) {
    var d = typeof decimals === "number" ? decimals : 0;
    return fmt(num, d) + " $";
  }

  function fmtIncome(num, decimals) {
    var d = typeof decimals === "number" ? decimals : 0;
    return fmt(num, d) + " $ / an";
  }

  function fmtSignedIncome(num, decimals) {
    var d = typeof decimals === "number" ? decimals : 0;
    return fmtSigned(num, d) + " $ / an";
  }

  function formatPval(p) {
    if (typeof p !== "number" || isNaN(p)) return "";
    if (p < 0.001) return "p < 0,001 ***";
    if (p < 0.01) return "p < 0,01 **";
    if (p < 0.05) return "p < 0,05 *";
    return "n.s.";
  }

  function clamp(val, min, max) {
    return Math.max(min, Math.min(max, val));
  }

  function loadModelData() {
    if (window.MODEL_DATA) {
      return Promise.resolve(window.MODEL_DATA);
    }
    return fetch("model-data.json").then(function (resp) {
      if (!resp.ok) {
        throw new Error("Impossible de charger model-data.json");
      }
      return resp.json();
    });
  }

  function setTab(tabId) {
    state.activeTab = tabId;
    el.tabBtns.forEach(function (btn) {
      var active = btn.getAttribute("data-tab") === tabId;
      btn.classList.toggle("is-active", active);
      btn.setAttribute("aria-selected", active ? "true" : "false");
    });
    Object.keys(el.tabPanels).forEach(function (key) {
      var panel = el.tabPanels[key];
      var isCurrent = key === tabId;
      panel.hidden = !isCurrent;
      panel.classList.toggle("is-active", isCurrent);
    });

    if (el.paramBadge) {
      if (tabId === "1") {
        el.paramBadge.textContent = "Introduction";
      } else if (tabId === "2") {
        el.paramBadge.textContent = "2 paramètres";
      } else if (tabId === "3") {
        el.paramBadge.textContent = "7 paramètres";
      } else if (tabId === "4") {
        el.paramBadge.textContent = "7 vs 329 paramètres";
      } else {
        el.paramBadge.textContent = "Hack-time · Colab";
      }
    }
  }

  /* =========================================================
     ONGLET 2 : REGRESSION SIMPLE (revenu_annuel ~ etudes)
     ========================================================= */
  var scatterGeom = {
    w: 720,
    h: 420,
    padL: 66,
    padR: 22,
    padT: 20,
    padB: 48,
    xMin: 0,
    xMax: 21,
    yMin: 0,
    yMax: 290000
  };

  function sx(x) {
    var plotW = scatterGeom.w - scatterGeom.padL - scatterGeom.padR;
    return scatterGeom.padL + ((x - scatterGeom.xMin) / (scatterGeom.xMax - scatterGeom.xMin)) * plotW;
  }

  function sy(y) {
    var plotH = scatterGeom.h - scatterGeom.padT - scatterGeom.padB;
    return scatterGeom.padT + (1 - (y - scatterGeom.yMin) / (scatterGeom.yMax - scatterGeom.yMin)) * plotH;
  }

  function invSx(svgX) {
    var plotW = scatterGeom.w - scatterGeom.padL - scatterGeom.padR;
    return scatterGeom.xMin + ((svgX - scatterGeom.padL) / plotW) * (scatterGeom.xMax - scatterGeom.xMin);
  }

  function invSy(svgY) {
    var plotH = scatterGeom.h - scatterGeom.padT - scatterGeom.padB;
    return scatterGeom.yMin + (1 - (svgY - scatterGeom.padT) / plotH) * (scatterGeom.yMax - scatterGeom.yMin);
  }

  function svgEl(tag, attrs) {
    var node = document.createElementNS(SVG_NS, tag);
    Object.keys(attrs).forEach(function (k) {
      node.setAttribute(k, String(attrs[k]));
    });
    return node;
  }

  function getPointPlotX(pt) {
    return typeof pt.dx === "number" ? pt.dx : pt.x;
  }

  function getPointPlotY(pt) {
    return typeof pt.dy === "number" ? pt.dy : pt.y;
  }

  function getActivePoints() {
    return state.data.scatter_sample.concat(state.addedPoints);
  }

  function computeActiveOls(points) {
    var n = points.length;
    var sumX = 0;
    var sumY = 0;
    for (var i = 0; i < n; i += 1) {
      sumX += points[i].x;
      sumY += points[i].y;
    }
    var meanX = sumX / n;
    var meanY = sumY / n;

    var sxx = 0;
    var sxy = 0;
    var sst = 0;
    for (var j = 0; j < n; j += 1) {
      var dx = points[j].x - meanX;
      var dy = points[j].y - meanY;
      sxx += dx * dx;
      sxy += dx * dy;
      sst += dy * dy;
    }

    var b1 = sxx > 1e-9 ? sxy / sxx : 0;
    var b0 = meanY - b1 * meanX;

    var sse = 0;
    for (var k = 0; k < n; k += 1) {
      var err = points[k].y - (b0 + b1 * points[k].x);
      sse += err * err;
    }
    var rmse = Math.sqrt(sse / n);
    var r2 = sst > 1e-9 ? 1 - sse / sst : 0;

    return {
      b0: b0,
      b1: b1,
      r2: r2,
      rmse: rmse
    };
  }

  function showPointTooltip(pt) {
    var wrapRect = el.scatterSvg.getBoundingClientRect();
    el.scatterTooltip.hidden = false;
    el.scatterTooltip.textContent =
      "Études : " +
      fmt(pt.x, 1) +
      " ans · Revenu : " +
      fmtIncome(pt.y, 0) +
      (pt.custom ? " [ajouté]" : "");
    var px = (sx(getPointPlotX(pt)) / scatterGeom.w) * wrapRect.width;
    var py = (sy(getPointPlotY(pt)) / scatterGeom.h) * wrapRect.height;
    el.scatterTooltip.style.left = Math.min(Math.max(8, wrapRect.width - 270), Math.max(8, px + 10)) + "px";
    el.scatterTooltip.style.top = Math.max(8, py - 34) + "px";
  }

  function renderScatterPoints() {
    var activePoints = getActivePoints();
    el.pointsLayer.innerHTML = "";
    el.residualsLayer.innerHTML = "";
    el.residualNodes = [];

    activePoints.forEach(function (pt) {
      var isCustom = Boolean(pt.custom);
      var pxVal = getPointPlotX(pt);
      var pyVal = getPointPlotY(pt);
      var baseR = isCustom ? 5.6 : 4.0;
      var baseFill = isCustom ? "#f7941e" : "#0072bc";
      var baseOpacity = isCustom ? 0.96 : 0.72;
      var baseStroke = isCustom ? "#1e2124" : "#ffffff";
      var baseStrokeW = isCustom ? 1.6 : 0.85;

      var c = svgEl("circle", {
        cx: sx(pxVal).toFixed(1),
        cy: sy(pyVal).toFixed(1),
        r: baseR,
        fill: baseFill,
        "fill-opacity": baseOpacity,
        stroke: baseStroke,
        "stroke-width": baseStrokeW
      });

      c.addEventListener("mouseenter", function () {
        c.setAttribute("r", String(baseR + 2));
        if (!isCustom) {
          c.setAttribute("fill", "#dd1019");
          c.setAttribute("fill-opacity", "0.95");
        }
        showPointTooltip(pt);
      });
      c.addEventListener("mouseleave", function () {
        c.setAttribute("r", String(baseR));
        c.setAttribute("fill", baseFill);
        c.setAttribute("fill-opacity", String(baseOpacity));
        el.scatterTooltip.hidden = true;
      });

      el.pointsLayer.appendChild(c);

      /* Segment de residu pour 100 % des points visibles (avec alignement sur la position affichee) */
      var seg = svgEl("line", {
        x1: sx(pxVal).toFixed(1),
        x2: sx(pxVal).toFixed(1),
        y1: sy(pyVal).toFixed(1),
        y2: sy(pyVal).toFixed(1),
        stroke: isCustom ? "#f7941e" : "#dd1019",
        "stroke-opacity": isCustom ? 0.85 : 0.36,
        "stroke-width": isCustom ? 1.7 : 1.15,
        "stroke-dasharray": "3 3"
      });
      el.residualsLayer.appendChild(seg);
      el.residualNodes.push({ pt: pt, node: seg });
    });

    var totalCount = activePoints.length;
    var addedCount = state.addedPoints.length;
    var realCount = state.data.scatter_sample.length;

    if (addedCount === 0) {
      el.scatterCountBadge.textContent = totalCount + " points réels";
      el.scatterCountBadge.className = "badge badge-indigo";
    } else {
      var suffix = addedCount > 1 ? "cliqués" : "cliqué";
      el.scatterCountBadge.textContent = totalCount + " points (" + realCount + " réels + " + addedCount + " " + suffix + ")";
      el.scatterCountBadge.className = "badge badge-amber";
    }
    el.btnClearPoints.disabled = addedCount === 0;
  }

  function initScatterSvg() {
    var svg = el.scatterSvg;
    svg.innerHTML = "";

    var defs = svgEl("defs", {});
    var clip = svgEl("clipPath", { id: "plot-clip" });
    clip.appendChild(
      svgEl("rect", {
        x: scatterGeom.padL,
        y: scatterGeom.padT,
        width: scatterGeom.w - scatterGeom.padL - scatterGeom.padR,
        height: scatterGeom.h - scatterGeom.padT - scatterGeom.padB
      })
    );
    defs.appendChild(clip);
    svg.appendChild(defs);

    var gridGroup = svgEl("g", { class: "scatter-grid" });
    [0, 50000, 100000, 150000, 200000, 250000].forEach(function (yv) {
      var yy = sy(yv);
      gridGroup.appendChild(
        svgEl("line", {
          x1: scatterGeom.padL,
          y1: yy,
          x2: scatterGeom.w - scatterGeom.padR,
          y2: yy,
          stroke: yv === 100000 ? "#cbd2db" : "#eaedf2",
          "stroke-width": yv === 100000 ? 1.2 : 1,
          "stroke-dasharray": yv === 100000 ? "4 4" : ""
        })
      );
      var lbl = svgEl("text", {
        x: scatterGeom.padL - 10,
        y: yy + 4,
        "text-anchor": "end",
        fill: "#555b62",
        "font-size": 11.5
      });
      lbl.textContent = Math.round(yv / 1000) + " k$";
      gridGroup.appendChild(lbl);
    });

    [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20].forEach(function (xv) {
      var xx = sx(xv);
      gridGroup.appendChild(
        svgEl("line", {
          x1: xx,
          y1: scatterGeom.padT,
          x2: xx,
          y2: scatterGeom.h - scatterGeom.padB,
          stroke: "#eaedf2",
          "stroke-width": 1
        })
      );
      var lbl = svgEl("text", {
        x: xx,
        y: scatterGeom.h - scatterGeom.padB + 18,
        "text-anchor": "middle",
        fill: "#555b62",
        "font-size": 11.5
      });
      lbl.textContent = String(xv);
      gridGroup.appendChild(lbl);
    });

    gridGroup.appendChild(
      svgEl("line", {
        x1: scatterGeom.padL,
        y1: scatterGeom.h - scatterGeom.padB,
        x2: scatterGeom.w - scatterGeom.padR,
        y2: scatterGeom.h - scatterGeom.padB,
        stroke: "#8d95a0",
        "stroke-width": 1.3
      })
    );
    gridGroup.appendChild(
      svgEl("line", {
        x1: scatterGeom.padL,
        y1: scatterGeom.padT,
        x2: scatterGeom.padL,
        y2: scatterGeom.h - scatterGeom.padB,
        stroke: "#8d95a0",
        "stroke-width": 1.3
      })
    );

    var xTitle = svgEl("text", {
      x: (scatterGeom.padL + scatterGeom.w - scatterGeom.padR) / 2,
      y: scatterGeom.h - 10,
      "text-anchor": "middle",
      fill: "#1e2124",
      "font-size": 12.5,
      "font-weight": 600
    });
    xTitle.textContent = "Années d'études (etudes, en ans)";
    gridGroup.appendChild(xTitle);

    var yTitle = svgEl("text", {
      x: 16,
      y: (scatterGeom.padT + scatterGeom.h - scatterGeom.padB) / 2,
      "text-anchor": "middle",
      fill: "#1e2124",
      "font-size": 12.5,
      "font-weight": 600,
      transform: "rotate(-90 16 " + (scatterGeom.padT + scatterGeom.h - scatterGeom.padB) / 2 + ")"
    });
    yTitle.textContent = "Revenu annuel ($ / an)";
    gridGroup.appendChild(yTitle);

    svg.appendChild(gridGroup);

    el.residualsLayer = svgEl("g", { "clip-path": "url(#plot-clip)" });
    el.pointsLayer = svgEl("g", { "clip-path": "url(#plot-clip)" });
    el.lineLayer = svgEl("g", { "clip-path": "url(#plot-clip)" });

    svg.appendChild(el.residualsLayer);
    svg.appendChild(el.pointsLayer);
    svg.appendChild(el.lineLayer);

    el.userLine = svgEl("line", {
      stroke: "#dd1019",
      "stroke-width": 3.2,
      "stroke-linecap": "round"
    });
    el.lineLayer.appendChild(el.userLine);

    renderScatterPoints();
  }

  function handleScatterClick(evt) {
    var rect = el.scatterSvg.getBoundingClientRect();
    if (!rect.width || !rect.height) return;
    var svgX = ((evt.clientX - rect.left) / rect.width) * scatterGeom.w;
    var svgY = ((evt.clientY - rect.top) / rect.height) * scatterGeom.h;

    if (
      svgX < scatterGeom.padL ||
      svgX > scatterGeom.w - scatterGeom.padR ||
      svgY < scatterGeom.padT ||
      svgY > scatterGeom.h - scatterGeom.padB
    ) {
      return;
    }

    var xVal = Number(clamp(invSx(svgX), 0, 20).toFixed(1));
    var yVal = Math.round(clamp(invSy(svgY), scatterGeom.yMin, scatterGeom.yMax) / 500) * 500;

    var newPt = { x: xVal, y: yVal, custom: true };
    state.addedPoints.push(newPt);
    renderScatterPoints();
    showPointTooltip(newPt);
    updateTab1();
  }

  function updateTab1() {
    var b0 = state.b0;
    var b1 = state.b1;
    var activePoints = getActivePoints();
    var activeOls = computeActiveOls(activePoints);
    var nPts = activePoints.length;

    el.valB0.textContent = fmtIncome(b0, 0);
    el.valB1.textContent = fmtSignedIncome(b1, 0);
    el.sliderB0.value = String(clamp(b0, -250000, 100000));
    el.sliderB1.value = String(clamp(b1, -5000, 25000));

    var signStr = b1 >= 0 ? "+ " + fmt(b1, 0) : "- " + fmt(Math.abs(b1), 0);
    el.tab1EqLive.textContent = "ŷ = " + fmt(b0, 0) + " " + signStr + " × etudes";

    var x1 = scatterGeom.xMin;
    var x2 = scatterGeom.xMax;
    el.userLine.setAttribute("x1", sx(x1).toFixed(1));
    el.userLine.setAttribute("y1", sy(b0 + b1 * x1).toFixed(1));
    el.userLine.setAttribute("x2", sx(x2).toFixed(1));
    el.userLine.setAttribute("y2", sy(b0 + b1 * x2).toFixed(1));

    var isOptimal =
      Math.abs(b0 - activeOls.b0) <= 25 && Math.abs(b1 - activeOls.b1) <= 5;
    el.userLine.setAttribute("stroke", isOptimal ? "#024d5f" : "#dd1019");

    el.residualsLayer.style.display = state.showResiduals ? "block" : "none";
    if (state.showResiduals) {
      el.residualNodes.forEach(function (item) {
        var yhatVisual = b0 + b1 * getPointPlotX(item.pt);
        item.node.setAttribute("y2", sy(yhatVisual).toFixed(1));
      });
    }

    var sumSq = 0;
    for (var i = 0; i < nPts; i += 1) {
      var p = activePoints[i];
      var err = p.y - (b0 + b1 * p.x);
      sumSq += err * err;
    }
    var rmseUser = Math.sqrt(sumSq / nPts);
    var rmseOpt = activeOls.rmse;

    el.tab1RmseUserLabel.textContent = "Votre erreur (" + nPts + " pts)";
    el.tab1RmseOlsLabel.textContent = "Optimum OLS (" + nPts + " pts)";
    el.tab1RmseUser.textContent = fmtIncome(rmseUser, 0);
    el.tab1RmseOls.textContent = fmtIncome(rmseOpt, 0);

    var excess = Math.max(0, rmseUser - rmseOpt);
    var qualityPct = clamp(100 - (excess / 25000) * 100, 8, 100);
    el.tab1MeterFill.style.width = qualityPct.toFixed(0) + "%";
    el.tab1MeterFill.classList.toggle("is-optimal", isOptimal);

    var globalOls = state.data.simple_ols;
    el.tab1GlobalNote.hidden = state.addedPoints.length > 0;
    if (!el.tab1GlobalNote.hidden) {
      el.tab1GlobalNote.textContent =
        "Repère sur l'échantillon complet (N = " +
        fmt(state.data.metadata.n, 0) +
        ") : RMSE optimal = " +
        fmtIncome(globalOls.rmse, 0) +
        " (R² = " +
        fmt(globalOls.r2, 2) +
        ").";
    }

    if (isOptimal) {
      el.tab1MeterStatus.textContent =
        "Droite optimale atteinte sur ces " +
        nPts +
        " points ! Aucune autre droite n'obtient une erreur moyenne plus faible.";
      el.tab1OlsReveal.hidden = false;
      el.tab1BadgeR2.textContent =
        "R² = " + fmt(activeOls.r2, 2) + " (" + fmt(activeOls.r2 * 100, 1) + " % expliqué)";
      el.tab1BadgeRmse.textContent = "RMSE optimal = " + fmtIncome(rmseOpt, 0);

      if (state.addedPoints.length === 0) {
        el.tab1OlsInterp.textContent =
          "Sur ces " +
          nPts +
          " foyers réels, chaque année d'études ajoute en moyenne " +
          fmtSignedIncome(activeOls.b1, 0) +
          " (" +
          fmtSignedIncome(globalOls.slope, 0) +
          " sur N = " +
          fmt(state.data.metadata.n, 0) +
          "). Mais à elles seules, les études n'expliquent que " +
          fmt(activeOls.r2 * 100, 1) +
          " % de la variance ici (" +
          fmt(globalOls.r2 * 100, 1) +
          " % sur N = 4 734) : il manque les autres leviers !";
      } else {
        var addedWord = state.addedPoints.length > 1 ? "points ajoutés" : "point ajouté";
        el.tab1OlsInterp.textContent =
          "Avec vos " +
          state.addedPoints.length +
          " " +
          addedWord +
          " (" +
          nPts +
          " pts au total), la droite OLS pivote à ŷ = " +
          fmt(activeOls.b0, 0) +
          " " +
          (activeOls.b1 >= 0 ? "+ " : "- ") +
          fmt(Math.abs(activeOls.b1), 0) +
          " × etudes. Chaque point ajouté déplace la règle linéaire !";
      }
    } else if (excess < 500) {
      el.tab1MeterStatus.textContent =
        "Vous êtes tout près de la droite optimale ! Ajustez finement ou cliquez sur « Trouver la droite optimale ».";
      el.tab1OlsReveal.hidden = true;
    } else {
      el.tab1MeterStatus.textContent =
        "Rapprochez votre droite du nuage pour réduire l'erreur moyenne (écart actuel : +" +
        fmtIncome(excess, 0) +
        ").";
      el.tab1OlsReveal.hidden = true;
    }
  }

  function animateToOls() {
    if (state.olsAnimId) {
      cancelAnimationFrame(state.olsAnimId);
    }
    var activeOls = computeActiveOls(getActivePoints());
    var startB0 = state.b0;
    var startB1 = state.b1;
    var targetB0 = Number(activeOls.b0.toFixed(1));
    var targetB1 = Number(activeOls.b1.toFixed(1));
    var startTime = performance.now();
    var duration = 520;

    function tick(now) {
      var t = clamp((now - startTime) / duration, 0, 1);
      var ease = 1 - Math.pow(1 - t, 3);
      state.b0 = startB0 + (targetB0 - startB0) * ease;
      state.b1 = startB1 + (targetB1 - startB1) * ease;
      updateTab1();
      if (t < 1) {
        state.olsAnimId = requestAnimationFrame(tick);
      } else {
        state.b0 = targetB0;
        state.b1 = targetB1;
        state.olsAnimId = null;
        updateTab1();
      }
    }

    state.olsAnimId = requestAnimationFrame(tick);
  }

  /* =========================================================
     LEVIERS PARTAGES (ONGLETS 2 & 3)
     ========================================================= */
  function getFeatureCopy(meta) {
    return FRENCH_FEATURE_COPY[meta.key] || {
      label: meta.label,
      short: meta.short_label,
      unit: meta.unit,
      hint: meta.hint,
      options: meta.options
    };
  }

  function formatLeverValue(meta, val) {
    if (meta.key === "etudes") {
      if (val === 12) return "12 ans (Bac)";
      if (val === 16) return "16 ans (Licence)";
      if (val === 18) return "18 ans (Master)";
      if (val === 20) return "20 ans (Doctorat)";
      return val + (val > 1 ? " ans" : " an");
    }
    if (meta.key === "age") {
      return val + " ans";
    }
    if (meta.key === "en_emploi") {
      return val === 1 ? "En emploi (1)" : "Hors emploi (0)";
    }
    if (meta.key === "marie") {
      return val === 1 ? "Marié·e (1)" : "Non (0)";
    }
    if (meta.key === "femme") {
      return val === 1 ? "Femme (1)" : "Homme (0)";
    }
    if (meta.key === "minorite") {
      return val === 1 ? "Minorité (1)" : "Blanc non-hisp. (0)";
    }
    return String(val);
  }

  function formatNodeShortValue(meta, val) {
    if (meta.key === "etudes" || meta.key === "age") {
      return val + " ans";
    }
    if (meta.key === "en_emploi") {
      return val === 1 ? "Oui" : "Non";
    }
    if (meta.key === "marie") {
      return val === 1 ? "Oui" : "Non";
    }
    if (meta.key === "femme") {
      return val === 1 ? "Femme" : "Homme";
    }
    if (meta.key === "minorite") {
      return val === 1 ? "Oui" : "Non";
    }
    return String(val);
  }

  function buildPresetsInto(container, compact) {
    container.innerHTML = "";
    state.data.presets.forEach(function (preset) {
      var copy = FRENCH_PRESET_COPY[preset.id] || preset;
      var btn = document.createElement("button");
      btn.type = "button";
      btn.className = "preset-btn";
      btn.setAttribute("data-preset-id", preset.id);
      btn.innerHTML =
        '<span class="preset-title">' +
        copy.label +
        "</span>" +
        (compact ? "" : '<span class="preset-sub">' + copy.description + "</span>");
      btn.addEventListener("click", function () {
        applyPreset(preset);
      });
      container.appendChild(btn);
    });
  }

  function buildLeversInto(container, prefix, compact) {
    container.innerHTML = "";
    state.data.feature_meta.forEach(function (meta) {
      var copy = getFeatureCopy(meta);
      var item = document.createElement("div");
      item.className = "lever-item";

      var top = document.createElement("div");
      top.className = "lever-top";

      var labelWrap = document.createElement("div");
      labelWrap.className = "lever-label-wrap";

      var lbl = document.createElement("label");
      lbl.className = "lever-label";
      var inputId = prefix + "-input-" + meta.key;
      lbl.setAttribute("for", inputId);
      lbl.textContent = compact ? copy.short : copy.label;
      labelWrap.appendChild(lbl);

      var badge = document.createElement("span");
      badge.className = "lever-badge";
      badge.id = prefix + "-badge-" + meta.key;

      top.appendChild(labelWrap);
      top.appendChild(badge);
      item.appendChild(top);

      if (meta.type === "toggle") {
        var segWrap = document.createElement("div");
        segWrap.className = "segmented-toggle";
        segWrap.setAttribute("role", "group");
        segWrap.setAttribute("aria-label", copy.label);

        [0, 1].forEach(function (optVal) {
          var segBtn = document.createElement("button");
          segBtn.type = "button";
          segBtn.className = "seg-btn";
          segBtn.setAttribute("data-key", meta.key);
          segBtn.setAttribute("data-val", String(optVal));
          segBtn.textContent = copy.options[optVal];
          segBtn.addEventListener("click", function () {
            setProfileValue(meta.key, optVal);
          });
          segWrap.appendChild(segBtn);
        });
        item.appendChild(segWrap);
      } else {
        var input = document.createElement("input");
        input.type = "range";
        input.id = inputId;
        input.min = String(meta.min);
        input.max = String(meta.max);
        input.step = String(meta.step);
        input.value = String(state.profile[meta.key]);
        input.setAttribute("data-lever-key", meta.key);
        input.addEventListener("input", function (e) {
          setProfileValue(meta.key, parseFloat(e.target.value));
        });
        item.appendChild(input);
      }

      if (copy.hint && !compact) {
        var hint = document.createElement("p");
        hint.className = "lever-hint";
        hint.textContent = copy.hint;
        item.appendChild(hint);
      }

      container.appendChild(item);
    });
  }

  function applyPreset(preset) {
    Object.keys(preset.values).forEach(function (k) {
      state.profile[k] = preset.values[k];
    });
    state.lastChangedKey = null;
    syncProfileViews();
  }

  function resetToTypicalPreset() {
    applyPreset(state.data.presets[0]);
  }

  function setProfileValue(key, val) {
    state.profile[key] = val;
    state.lastChangedKey = key;
    syncProfileViews();
  }

  function syncLeverControls() {
    var presets = state.data.presets;
    var activePresetId = null;
    presets.forEach(function (p) {
      var match = Object.keys(p.values).every(function (k) {
        return Math.abs(state.profile[k] - p.values[k]) < 1e-6;
      });
      if (match) {
        activePresetId = p.id;
      }
    });

    document.querySelectorAll(".preset-btn").forEach(function (btn) {
      btn.classList.toggle("is-active", btn.getAttribute("data-preset-id") === activePresetId);
    });

    state.data.feature_meta.forEach(function (meta) {
      var val = state.profile[meta.key];
      ["tab2", "tab3"].forEach(function (prefix) {
        var badge = document.getElementById(prefix + "-badge-" + meta.key);
        if (badge) {
          badge.textContent = formatLeverValue(meta, val);
        }
        var slider = document.getElementById(prefix + "-input-" + meta.key);
        if (slider) {
          slider.value = String(val);
        }
      });
    });

    document.querySelectorAll(".seg-btn").forEach(function (btn) {
      var key = btn.getAttribute("data-key");
      var optVal = parseInt(btn.getAttribute("data-val"), 10);
      btn.classList.toggle("is-active", state.profile[key] === optVal);
    });
  }

  /* =========================================================
     MODELES PREDICTIFS : OLS (7 PARAMS) & MLP (329 PARAMS)
     ========================================================= */
  function predictFullOls(profileObj) {
    var ols = state.data.full_ols;
    var raw = ols.intercept;
    state.data.feature_meta.forEach(function (meta) {
      raw += ols.params[meta.key] * profileObj[meta.key];
    });
    return {
      raw: raw,
      score: clamp(raw, PRED_MIN, PRED_MAX)
    };
  }

  function getIncomeTag(amount) {
    if (amount < 40000) return "Bas revenu";
    if (amount < 77500) return "Sous le médian";
    if (amount <= 120000) return "Autour de la moyenne";
    if (amount <= 180000) return "Revenu élevé";
    return "Haut revenu";
  }

  function incomeGaugePct(amount) {
    return clamp((amount / 275000) * 100, 0, 100);
  }

  function mlpForward(inputVec) {
    var mlp = state.data.blackbox_mlp;
    var nIn = mlp.scaler_mean.length;
    var xScaled = [];
    for (var i = 0; i < nIn; i += 1) {
      xScaled.push((inputVec[i] - mlp.scaler_mean[i]) / mlp.scaler_std[i]);
    }

    var h1 = [];
    for (var j = 0; j < 16; j += 1) {
      var z1 = mlp.b1[j];
      for (var i1 = 0; i1 < nIn; i1 += 1) {
        z1 += xScaled[i1] * mlp.W1[i1][j];
      }
      h1.push(Math.tanh(z1));
    }

    var h2 = [];
    for (var k = 0; k < 12; k += 1) {
      var z2 = mlp.b2[k];
      for (var j2 = 0; j2 < 16; j2 += 1) {
        z2 += h1[j2] * mlp.W2[j2][k];
      }
      h2.push(Math.tanh(z2));
    }

    var yScaled = mlp.b3;
    for (var k3 = 0; k3 < 12; k3 += 1) {
      yScaled += h2[k3] * mlp.W3[k3];
    }

    var raw = mlp.y_mean + mlp.y_std * yScaled;
    return {
      score: clamp(raw, PRED_MIN, PRED_MAX),
      raw: raw,
      h1: h1,
      h2: h2
    };
  }

  function profileToVec(profileObj) {
    return [
      profileObj.etudes,
      profileObj.age,
      profileObj.en_emploi,
      profileObj.marie,
      profileObj.femme,
      profileObj.minorite
    ];
  }

  /* =========================================================
     ONGLET 2 : RENDU BOITE DE VERRE
     ========================================================= */
  function renderEquationInto(container, highlightKey) {
    var ols = state.data.full_ols;
    container.innerHTML = "";

    var interceptChip = document.createElement("div");
    interceptChip.className = "eq-chip";
    interceptChip.innerHTML =
      '<span class="eq-chip-label">Constante</span>' +
      '<span class="eq-chip-math">' +
      fmtDollar(ols.intercept, 0) +
      "</span>" +
      '<span class="eq-chip-res">base</span>';
    container.appendChild(interceptChip);

    state.data.feature_meta.forEach(function (meta) {
      var op = document.createElement("span");
      op.className = "eq-op";
      op.textContent = ols.params[meta.key] >= 0 ? "+" : "-";
      container.appendChild(op);

      var copy = getFeatureCopy(meta);
      var coef = Math.abs(ols.params[meta.key]);
      var val = state.profile[meta.key];
      var term = ols.params[meta.key] * val;

      var chip = document.createElement("div");
      chip.className =
        "eq-chip" +
        (meta.protected ? " is-protected" : "") +
        (highlightKey === meta.key ? " is-highlighted" : "");
      chip.innerHTML =
        '<span class="eq-chip-label">' +
        copy.short +
        "</span>" +
        '<span class="eq-chip-math">' +
        fmt(coef, 0) +
        " × " +
        fmt(val, 0) +
        "</span>" +
        '<span class="eq-chip-res">= ' +
        fmtSigned(term, 0) +
        " $</span>";
      container.appendChild(chip);
    });

    var pred = predictFullOls(state.profile);
    var isClamped = Math.abs(pred.raw - pred.score) > 1;
    var eqOp = document.createElement("span");
    eqOp.className = "eq-op";
    eqOp.textContent = "=";
    container.appendChild(eqOp);

    var totalChip = document.createElement("div");
    totalChip.className = "eq-chip is-total";
    totalChip.innerHTML =
      '<span class="eq-chip-label">Revenu prédit</span>' +
      '<span class="eq-chip-math">= ' +
      fmtDollar(pred.score, 0) +
      "</span>" +
      '<span class="eq-chip-res">' +
      (isClamped ? "brut : " + fmtSigned(pred.raw, 0) + " $" : "modèle OLS") +
      "</span>";
    container.appendChild(totalChip);
  }

  function updateTab2() {
    var ols = state.data.full_ols;
    var pred = predictFullOls(state.profile);

    el.tab2ScoreValue.textContent = fmtDollar(pred.score, 0);
    el.tab2ScoreTag.textContent = getIncomeTag(pred.score);
    el.tab2LiveMarker.style.left = incomeGaugePct(pred.score).toFixed(2) + "%";

    if (state.profileA) {
      el.tab2GhostMarker.hidden = false;
      el.tab2GhostMarker.style.left = incomeGaugePct(state.profileA.score).toFixed(2) + "%";
      el.btnClearA.hidden = false;

      var delta = pred.score - state.profileA.score;
      var diffs = [];
      state.data.feature_meta.forEach(function (meta) {
        var cur = state.profile[meta.key];
        var ref = state.profileA.values[meta.key];
        if (Math.abs(cur - ref) > 1e-6) {
          var copy = getFeatureCopy(meta);
          diffs.push(copy.short + " : " + formatLeverValue(meta, ref) + " -> " + formatLeverValue(meta, cur));
        }
      });

      if (diffs.length === 0) {
        el.compareReadout.innerHTML =
          '<span class="compare-delta">Δ = 0 $ / an</span> par rapport au Profil A (' +
          fmtIncome(state.profileA.score, 0) +
          "). Modifiez un levier à gauche pour mesurer son effet exact.";
      } else {
        el.compareReadout.innerHTML =
          '<span class="compare-delta">Δ = ' +
          fmtSignedIncome(delta, 0) +
          "</span> par rapport au Profil A. Écarts : " +
          diffs.join(" · ");
      }
    } else {
      el.tab2GhostMarker.hidden = true;
      el.btnClearA.hidden = true;
      el.compareReadout.textContent =
        "Figez un profil puis changez un seul critère (ex. Homme vers Femme) pour isoler son effet exact.";
    }

    el.tab2ContribChart.innerHTML = "";
    var maxAbs = 60000;
    state.data.feature_meta.forEach(function (meta) {
      var copy = getFeatureCopy(meta);
      var coef = ols.params[meta.key];
      var pval = ols.pvalues && typeof ols.pvalues[meta.key] === "number" ? ols.pvalues[meta.key] : null;
      var sigStr = pval !== null ? formatPval(pval) : "";
      var diffFromMean = state.profile[meta.key] - meta.mean;
      var contrib = coef * diffFromMean;
      var pct = clamp((Math.abs(contrib) / maxAbs) * 50, 0, 50);
      var isRight = contrib >= 0;

      var row = document.createElement("div");
      row.className = "contrib-row";

      var nameDiv = document.createElement("div");
      nameDiv.className = "contrib-name";
      nameDiv.innerHTML =
        copy.short +
        '<span class="contrib-sub">pente : ' +
        fmtSignedIncome(coef, 0) +
        (sigStr ? ' · <strong class="sig-tag">' + sigStr + "</strong>" : "") +
        "</span>";

      var track = document.createElement("div");
      track.className = "contrib-track";
      var zeroLine = document.createElement("div");
      zeroLine.className = "contrib-zero";
      var fill = document.createElement("div");
      fill.className = "contrib-fill " + (isRight ? "is-right" : "is-left");
      fill.style.width = pct.toFixed(1) + "%";
      fill.style.left = isRight ? "50%" : (50 - pct).toFixed(1) + "%";
      track.appendChild(zeroLine);
      track.appendChild(fill);

      var valDiv = document.createElement("div");
      valDiv.className = "contrib-val " + (isRight ? "is-right" : "is-left");
      valDiv.textContent = fmtSignedIncome(contrib, 0);

      row.appendChild(nameDiv);
      row.appendChild(track);
      row.appendChild(valDiv);
      el.tab2ContribChart.appendChild(row);
    });

    renderEquationInto(el.tab2EquationLive, state.lastChangedKey);
  }

  /* =========================================================
     ONGLET 3 : RESEAU DE NEURONES SVG INTERACTIF (6->16->12->1)
     ========================================================= */
  function weightToColor(w) {
    var intensity = clamp(Math.abs(w) / 0.75, 0, 1);
    if (w >= 0) {
      var r = Math.round(236 + (0 - 236) * intensity);
      var g = Math.round(239 + (114 - 239) * intensity);
      var b = Math.round(244 + (188 - 244) * intensity);
      return "rgb(" + r + "," + g + "," + b + ")";
    }
    var r2 = Math.round(236 + (221 - 236) * intensity);
    var g2 = Math.round(239 + (16 - 239) * intensity);
    var b2 = Math.round(244 + (25 - 244) * intensity);
    return "rgb(" + r2 + "," + g2 + "," + b2 + ")";
  }

  function clearMlpHighlights() {
    if (!el.mlpEdges) return;
    el.mlpEdges.forEach(function (edge) {
      edge.node.setAttribute("opacity", String(edge.baseOpacity));
      edge.node.setAttribute("stroke-width", String(edge.baseWidth));
    });
    el.mlpNodeGroups.forEach(function (grp) {
      grp.classList.remove("is-selected");
      grp.setAttribute("opacity", "1");
    });
  }

  function applyMlpSelection(sel) {
    clearMlpHighlights();
    if (!sel) {
      el.mlpInspector.textContent =
        "Survolez ou touchez un neurone ou une connexion parmi les 329 paramètres pour explorer la boîte noire.";
      return;
    }

    var pred = state.mlpLastPred || mlpForward(profileToVec(state.profile));

    if (sel.kind === "edge") {
      el.mlpEdges.forEach(function (edge) {
        var isTarget = edge.idx === sel.idx;
        edge.node.setAttribute("opacity", isTarget ? "0.98" : "0.06");
        edge.node.setAttribute("stroke-width", isTarget ? "3.2" : String(edge.baseWidth));
      });
      el.mlpInspector.textContent =
        "Connexion #" +
        sel.idx +
        " / 329 (" +
        sel.fromLabel +
        " -> " +
        sel.toLabel +
        ") : poids = " +
        fmtSigned(sel.weight, 3) +
        " (impossible à traduire isolément en $ / an)";
      return;
    }

    if (sel.kind === "input") {
      var meta = state.data.feature_meta[sel.i];
      var copy = getFeatureCopy(meta);
      el.mlpEdges.forEach(function (edge) {
        var match = edge.layer === 1 && edge.fromIdx === sel.i;
        edge.node.setAttribute("opacity", match ? "0.9" : "0.05");
        edge.node.setAttribute("stroke-width", match ? String(Math.max(1.8, edge.baseWidth * 1.4)) : String(edge.baseWidth));
      });
      el.mlpInputGroups[sel.i].classList.add("is-selected");
      el.mlpInspector.textContent =
        "Entrée « " +
        copy.short +
        " » (valeur : " +
        formatLeverValue(meta, state.profile[meta.key]) +
        ") : diffuse son signal vers les 16 neurones de la couche 1 via 16 poids différents. Aucun coefficient unique n'existe.";
      return;
    }

    if (sel.kind === "h1") {
      var j = sel.j;
      el.mlpEdges.forEach(function (edge) {
        var match =
          (edge.layer === 1 && edge.toIdx === j) ||
          (edge.layer === 2 && edge.fromIdx === j);
        edge.node.setAttribute("opacity", match ? "0.9" : "0.05");
        edge.node.setAttribute("stroke-width", match ? String(Math.max(1.8, edge.baseWidth * 1.4)) : String(edge.baseWidth));
      });
      el.mlpH1Groups[j].classList.add("is-selected");
      el.mlpInspector.textContent =
        "Neurone caché C1." +
        (j + 1) +
        " : activation actuelle = " +
        fmtSigned(pred.h1[j], 2) +
        " · constante interne = " +
        fmtSigned(state.data.blackbox_mlp.b1[j], 3) +
        " · combine les 6 entrées à la fois (rôle isolé opaque).";
      return;
    }

    if (sel.kind === "h2") {
      var k = sel.k;
      el.mlpEdges.forEach(function (edge) {
        var match =
          (edge.layer === 2 && edge.toIdx === k) ||
          (edge.layer === 3 && edge.fromIdx === k);
        edge.node.setAttribute("opacity", match ? "0.92" : "0.05");
        edge.node.setAttribute("stroke-width", match ? String(Math.max(1.8, edge.baseWidth * 1.4)) : String(edge.baseWidth));
      });
      el.mlpH2Groups[k].classList.add("is-selected");
      el.mlpInspector.textContent =
        "Neurone caché C2." +
        (k + 1) +
        " : activation actuelle = " +
        fmtSigned(pred.h2[k], 2) +
        " · constante interne = " +
        fmtSigned(state.data.blackbox_mlp.b2[k], 3) +
        " · agrège 16 neurones cachés vers la sortie (rôle isolé opaque).";
      return;
    }

    if (sel.kind === "output") {
      el.mlpEdges.forEach(function (edge) {
        var match = edge.layer === 3;
        edge.node.setAttribute("opacity", match ? "0.92" : "0.05");
        edge.node.setAttribute("stroke-width", match ? String(Math.max(2.0, edge.baseWidth * 1.4)) : String(edge.baseWidth));
      });
      el.mlpOutputGroup.classList.add("is-selected");
      el.mlpInspector.textContent =
        "Neurone de sortie : prédiction = " +
        fmtIncome(pred.score, 0) +
        " · constante finale = " +
        fmtSigned(state.data.blackbox_mlp.b3, 3) +
        " · somme pondérée des 12 neurones C2 (329 paramètres au total).";
    }
  }

  function buildMlpSvg() {
    var svg = el.mlpSvg;
    var mlp = state.data.blackbox_mlp;
    svg.innerHTML = "";

    var inputShorts = [
      "Études",
      "Âge",
      "En emploi",
      "Marié·e",
      "Femme",
      "Minorité"
    ];

    var xCols = [142, 330, 515, 678];
    var inputPos = [];
    for (var i = 0; i < 6; i += 1) {
      inputPos.push({ x: xCols[0], y: 58 + i * 52 });
    }
    var h1Pos = [];
    for (var j = 0; j < 16; j += 1) {
      h1Pos.push({ x: xCols[1], y: 40 + j * 19.8 });
    }
    var h2Pos = [];
    for (var k = 0; k < 12; k += 1) {
      h2Pos.push({ x: xCols[2], y: 50 + k * 25 });
    }
    var outPos = { x: xCols[3], y: 188 };

    var headersLayer = svgEl("g", {});
    [
      { x: xCols[0], text: "Entrées (6)" },
      { x: xCols[1], text: "Couche 1 (16)" },
      { x: xCols[2], text: "Couche 2 (12)" },
      { x: xCols[3], text: "Sortie (1)" }
    ].forEach(function (h) {
      var t = svgEl("text", {
        x: h.x,
        y: 20,
        "text-anchor": "middle",
        fill: "#555b62",
        "font-size": 11.5,
        "font-weight": 700
      });
      t.textContent = h.text;
      headersLayer.appendChild(t);
    });
    svg.appendChild(headersLayer);

    var edgesLayer = svgEl("g", {});
    var nodesLayer = svgEl("g", {});
    svg.appendChild(edgesLayer);
    svg.appendChild(nodesLayer);

    svg.addEventListener("click", function (evt) {
      if (evt.target === svg) {
        state.mlpPinnedSelection = null;
        applyMlpSelection(null);
      }
    });

    el.mlpEdges = [];
    el.mlpNodeGroups = [];
    el.mlpInputGroups = [];
    el.mlpInputValueTexts = [];
    el.mlpH1Groups = [];
    el.mlpH1Circles = [];
    el.mlpH2Groups = [];
    el.mlpH2Circles = [];

    var connIdx = 1;

    function addEdge(layer, fromIdx, toIdx, p1, p2, w, fromLabel, toLabel) {
      var idx = connIdx;
      connIdx += 1;
      var absW = Math.abs(w);
      var baseOpacity = clamp(0.06 + (absW / 0.8) * 0.45, 0.06, 0.55);
      var baseWidth = clamp(0.65 + (absW / 0.8) * 1.9, 0.65, 2.6);
      var color = w >= 0 ? "#0072bc" : "#dd1019";

      var line = svgEl("line", {
        class: "mlp-edge",
        x1: p1.x,
        y1: p1.y,
        x2: p2.x,
        y2: p2.y,
        stroke: color,
        "stroke-width": baseWidth.toFixed(2),
        opacity: baseOpacity.toFixed(2)
      });

      var selObj = {
        kind: "edge",
        idx: idx,
        weight: w,
        fromLabel: fromLabel,
        toLabel: toLabel
      };

      line.addEventListener("mouseenter", function () {
        applyMlpSelection(selObj);
      });
      line.addEventListener("mouseleave", function () {
        applyMlpSelection(state.mlpPinnedSelection);
      });
      line.addEventListener("click", function (evt) {
        evt.stopPropagation();
        state.mlpPinnedSelection =
          state.mlpPinnedSelection &&
          state.mlpPinnedSelection.kind === "edge" &&
          state.mlpPinnedSelection.idx === idx
            ? null
            : selObj;
        applyMlpSelection(state.mlpPinnedSelection);
      });

      edgesLayer.appendChild(line);
      el.mlpEdges.push({
        node: line,
        idx: idx,
        layer: layer,
        fromIdx: fromIdx,
        toIdx: toIdx,
        baseOpacity: baseOpacity,
        baseWidth: baseWidth
      });
    }

    for (var i1 = 0; i1 < 6; i1 += 1) {
      for (var j1 = 0; j1 < 16; j1 += 1) {
        addEdge(
          1,
          i1,
          j1,
          inputPos[i1],
          h1Pos[j1],
          mlp.W1[i1][j1],
          inputShorts[i1],
          "C1." + (j1 + 1)
        );
      }
    }

    for (var j2 = 0; j2 < 16; j2 += 1) {
      for (var k2 = 0; k2 < 12; k2 += 1) {
        addEdge(
          2,
          j2,
          k2,
          h1Pos[j2],
          h2Pos[k2],
          mlp.W2[j2][k2],
          "C1." + (j2 + 1),
          "C2." + (k2 + 1)
        );
      }
    }

    for (var k3 = 0; k3 < 12; k3 += 1) {
      addEdge(
        3,
        k3,
        0,
        h2Pos[k3],
        outPos,
        mlp.W3[k3],
        "C2." + (k3 + 1),
        "Sortie"
      );
    }

    function bindNodeEvents(grp, selObj, isSameFn) {
      grp.addEventListener("mouseenter", function () {
        applyMlpSelection(selObj);
      });
      grp.addEventListener("mouseleave", function () {
        applyMlpSelection(state.mlpPinnedSelection);
      });
      grp.addEventListener("focus", function () {
        applyMlpSelection(selObj);
      });
      grp.addEventListener("blur", function () {
        applyMlpSelection(state.mlpPinnedSelection);
      });
      grp.addEventListener("click", function (evt) {
        evt.stopPropagation();
        state.mlpPinnedSelection =
          state.mlpPinnedSelection && isSameFn(state.mlpPinnedSelection) ? null : selObj;
        applyMlpSelection(state.mlpPinnedSelection);
      });
      grp.addEventListener("keydown", function (evt) {
        if (evt.key === "Enter" || evt.key === " ") {
          evt.preventDefault();
          state.mlpPinnedSelection =
            state.mlpPinnedSelection && isSameFn(state.mlpPinnedSelection) ? null : selObj;
          applyMlpSelection(state.mlpPinnedSelection);
        }
      });
    }

    for (var inIdx = 0; inIdx < 6; inIdx += 1) {
      (function (idx) {
        var meta = state.data.feature_meta[idx];
        var pos = inputPos[idx];
        var isProt = Boolean(meta.protected);
        var grp = svgEl("g", {
          class: "mlp-node-group",
          tabindex: "0",
          role: "button",
          "aria-label": "Entrée " + inputShorts[idx]
        });

        var circle = svgEl("circle", {
          class: "mlp-node-circle",
          cx: pos.x,
          cy: pos.y,
          r: 13.5,
          fill: isProt ? "#fef4e6" : "#ffffff",
          stroke: isProt ? "#dd1019" : "#024d5f",
          "stroke-width": isProt ? 2.5 : 1.9
        });

        var lblName = svgEl("text", {
          x: pos.x - 20,
          y: pos.y - 2,
          "text-anchor": "end",
          fill: isProt ? "#b40d14" : "#1e2124",
          "font-size": 11.5,
          "font-weight": 700
        });
        lblName.textContent = inputShorts[idx];

        var lblVal = svgEl("text", {
          x: pos.x - 20,
          y: pos.y + 12,
          "text-anchor": "end",
          fill: "#555b62",
          "font-size": 10.5,
          "font-weight": 600
        });
        lblVal.textContent = formatNodeShortValue(meta, state.profile[meta.key]);

        grp.appendChild(circle);
        grp.appendChild(lblName);
        grp.appendChild(lblVal);
        nodesLayer.appendChild(grp);

        var selObj = { kind: "input", i: idx };
        bindNodeEvents(grp, selObj, function (cur) {
          return cur.kind === "input" && cur.i === idx;
        });

        el.mlpNodeGroups.push(grp);
        el.mlpInputGroups.push(grp);
        el.mlpInputValueTexts.push(lblVal);
      })(inIdx);
    }

    for (var h1Idx = 0; h1Idx < 16; h1Idx += 1) {
      (function (idx) {
        var pos = h1Pos[idx];
        var grp = svgEl("g", {
          class: "mlp-node-group",
          tabindex: "0",
          role: "button",
          "aria-label": "Neurone couche 1 numéro " + (idx + 1)
        });
        var circle = svgEl("circle", {
          class: "mlp-node-circle",
          cx: pos.x,
          cy: pos.y,
          r: 7.4,
          fill: "#eceff4",
          stroke: "#2f3235",
          "stroke-width": 1.1
        });
        grp.appendChild(circle);
        nodesLayer.appendChild(grp);

        var selObj = { kind: "h1", j: idx };
        bindNodeEvents(grp, selObj, function (cur) {
          return cur.kind === "h1" && cur.j === idx;
        });

        el.mlpNodeGroups.push(grp);
        el.mlpH1Groups.push(grp);
        el.mlpH1Circles.push(circle);
      })(h1Idx);
    }

    for (var h2Idx = 0; h2Idx < 12; h2Idx += 1) {
      (function (idx) {
        var pos = h2Pos[idx];
        var grp = svgEl("g", {
          class: "mlp-node-group",
          tabindex: "0",
          role: "button",
          "aria-label": "Neurone couche 2 numéro " + (idx + 1)
        });
        var circle = svgEl("circle", {
          class: "mlp-node-circle",
          cx: pos.x,
          cy: pos.y,
          r: 8.8,
          fill: "#eceff4",
          stroke: "#2f3235",
          "stroke-width": 1.2
        });
        grp.appendChild(circle);
        nodesLayer.appendChild(grp);

        var selObj = { kind: "h2", k: idx };
        bindNodeEvents(grp, selObj, function (cur) {
          return cur.kind === "h2" && cur.k === idx;
        });

        el.mlpNodeGroups.push(grp);
        el.mlpH2Groups.push(grp);
        el.mlpH2Circles.push(circle);
      })(h2Idx);
    }

    var outGrp = svgEl("g", {
      class: "mlp-node-group",
      tabindex: "0",
      role: "button",
      "aria-label": "Neurone de sortie revenu prédit"
    });
    var outCircle = svgEl("circle", {
      class: "mlp-node-circle",
      cx: outPos.x,
      cy: outPos.y,
      r: 34,
      fill: "#1e2124",
      stroke: "#dd1019",
      "stroke-width": 2.6
    });
    var outVal = svgEl("text", {
      x: outPos.x,
      y: outPos.y - 1,
      "text-anchor": "middle",
      fill: "#ffffff",
      "font-size": 11.5,
      "font-weight": 800
    });
    outVal.textContent = "144 056 $";
    var outUnit = svgEl("text", {
      x: outPos.x,
      y: outPos.y + 13,
      "text-anchor": "middle",
      fill: "#cbd2db",
      "font-size": 9.5,
      "font-weight": 600
    });
    outUnit.textContent = "/ an";

    outGrp.appendChild(outCircle);
    outGrp.appendChild(outVal);
    outGrp.appendChild(outUnit);
    nodesLayer.appendChild(outGrp);

    var outSel = { kind: "output" };
    bindNodeEvents(outGrp, outSel, function (cur) {
      return cur.kind === "output";
    });
    el.mlpNodeGroups.push(outGrp);
    el.mlpOutputGroup = outGrp;
    el.mlpOutputValText = outVal;
  }

  function updateMlpVisual(mlpPred) {
    state.mlpLastPred = mlpPred;
    if (!el.mlpH1Circles) return;

    state.data.feature_meta.forEach(function (meta, idx) {
      el.mlpInputValueTexts[idx].textContent = formatNodeShortValue(meta, state.profile[meta.key]);
    });

    for (var i = 0; i < mlpPred.h1.length; i += 1) {
      el.mlpH1Circles[i].setAttribute("fill", weightToColor(mlpPred.h1[i]));
    }
    for (var j = 0; j < mlpPred.h2.length; j += 1) {
      el.mlpH2Circles[j].setAttribute("fill", weightToColor(mlpPred.h2[j]));
    }
    el.mlpOutputValText.textContent = fmtDollar(mlpPred.score, 0);

    if (state.mlpPinnedSelection) {
      applyMlpSelection(state.mlpPinnedSelection);
    }
  }

  function computeLocalProbe() {
    var baseVec = profileToVec(state.profile);
    var mlp = state.data.blackbox_mlp;
    var deltas = [1.0, 5.0, 1.0, 1.0, 1.0, 1.0];
    var results = [];

    state.data.feature_meta.forEach(function (meta, idx) {
      var copy = getFeatureCopy(meta);
      var slope;
      var stdEffect;

      if (meta.type === "toggle") {
        var v0 = baseVec.slice();
        v0[idx] = 0;
        var v1 = baseVec.slice();
        v1[idx] = 1;
        slope = mlpForward(v1).score - mlpForward(v0).score;
        stdEffect = slope * mlp.scaler_std[idx];
      } else {
        var d = deltas[idx];
        var vPlus = baseVec.slice();
        var vMinus = baseVec.slice();
        var xPlus = Math.min(meta.max, baseVec[idx] + d);
        var xMinus = Math.max(meta.min, baseVec[idx] - d);
        vPlus[idx] = xPlus;
        vMinus[idx] = xMinus;
        slope = (mlpForward(vPlus).score - mlpForward(vMinus).score) / (xPlus - xMinus);
        stdEffect = slope * mlp.scaler_std[idx];
      }

      results.push({
        key: meta.key,
        short: copy.short,
        isProtected: Boolean(meta.protected),
        slope: slope,
        stdEffect: stdEffect,
        olsSlope: state.data.full_ols.params[meta.key],
        unitLabel: meta.type === "toggle" ? "$ / an (0 -> 1)" : "$ / an (par an)"
      });
    });

    return results;
  }

  function renderProbeResults() {
    var probe = computeLocalProbe();
    el.probeResults.hidden = false;
    el.probeBars.innerHTML = "";

    var maxAbs = 38000;
    probe.forEach(function (item) {
      var pct = clamp((Math.abs(item.stdEffect) / maxAbs) * 50, 0, 50);
      var isRight = item.slope >= 0;

      var row = document.createElement("div");
      row.className = "contrib-row";

      var nameDiv = document.createElement("div");
      nameDiv.className = "contrib-name";
      nameDiv.innerHTML =
        item.short +
        '<span class="contrib-sub">OLS fixe : ' +
        fmtSigned(item.olsSlope, 0) +
        " " +
        item.unitLabel +
        "</span>";

      var track = document.createElement("div");
      track.className = "contrib-track";
      var zeroLine = document.createElement("div");
      zeroLine.className = "contrib-zero";
      var fill = document.createElement("div");
      fill.className = "contrib-fill " + (isRight ? "is-right" : "is-left");
      fill.style.width = pct.toFixed(1) + "%";
      fill.style.left = isRight ? "50%" : (50 - pct).toFixed(1) + "%";
      track.appendChild(zeroLine);
      track.appendChild(fill);

      var valDiv = document.createElement("div");
      valDiv.className = "contrib-val " + (isRight ? "is-right" : "is-left");
      valDiv.textContent = fmtSignedIncome(item.slope, 0);

      row.appendChild(nameDiv);
      row.appendChild(track);
      row.appendChild(valDiv);
      el.probeBars.appendChild(row);
    });

    var etudesProbe = probe[0];
    var ageProbe = probe[1];
    var enEmploiProbe = probe[2];
    var marieProbe = probe[3];
    var femmeProbe = probe[4];
    var minoriteProbe = probe[5];
    var olsParams = state.data.full_ols.params;

    el.probeCallout.innerHTML =
      "<strong>Comparaison clé (XAI locale vs règle globale) :</strong> " +
      "dans la boîte de verre (OLS), chaque critère est figé pour tout le monde : <strong>" +
      fmtSignedIncome(olsParams.etudes, 0) +
      "</strong> par année d'études, <strong>" +
      fmtSignedIncome(olsParams.age, 0) +
      "</strong> par année d'âge et <strong>" +
      fmtSignedIncome(olsParams.marie, 0) +
      "</strong> pour Marié·e. Pour <strong>ce profil précis</strong> (âge " +
      fmt(state.profile.age, 0) +
      " ans), la sonde locale sur le réseau de neurones mesure <strong>" +
      fmtSignedIncome(etudesProbe.slope, 0) +
      "</strong> par année d'études, <strong>" +
      fmtSignedIncome(ageProbe.slope, 0) +
      "</strong> par année d'âge, <strong>" +
      fmtSignedIncome(enEmploiProbe.slope, 0) +
      "</strong> pour En emploi et <strong>" +
      fmtSignedIncome(marieProbe.slope, 0) +
      "</strong> pour Marié·e. Contrairement à la pente fixe de l'OLS (-227 $ / an), le MLP capture la courbe réelle de l'âge : " +
      "pente positive ou en plateau en début et milieu de carrière (ex. vers 29-46 ans chez les actifs), puis pente négative à l'approche de la retraite (ex. vers 60-72 ans en activité) !";

    el.probeProxyCallout.innerHTML =
      "<strong>Biais et risque de variables proxy :</strong> " +
      "ici, la sonde locale mesure <strong>" +
      fmtSignedIncome(femmeProbe.slope, 0) +
      "</strong> sur <strong>Femme</strong> (contre " +
      fmtSignedIncome(olsParams.femme, 0) +
      " en OLS) et <strong>" +
      fmtSignedIncome(minoriteProbe.slope, 0) +
      "</strong> sur <strong>Minorité</strong> (contre " +
      fmtSignedIncome(olsParams.minorite, 0) +
      " en OLS). Même si l'on retire ces deux critères (sexe et origine) d'un algorithme RH ou bancaire, " +
      "une boîte noire peut les reconstruire via des variables corrélées " +
      "(statut d'activité, situation maritale, niveau d'études, âge). D'où l'exigence d'audit posée par l'<strong>AI Act européen</strong>.";
  }

  function updateTab3() {
    var olsPred = predictFullOls(state.profile);
    var mlpPred = mlpForward(profileToVec(state.profile));
    var isGlass = state.tab3Mode === "glass";

    el.tab3ScoreOls.textContent = fmtIncome(olsPred.score, 0);
    el.tab3ScoreMlp.textContent = fmtIncome(mlpPred.score, 0);

    el.modeBtnGlass.classList.toggle("is-active", isGlass);
    el.modeBtnBlack.classList.toggle("is-active", !isGlass);

    el.tab3GlassView.hidden = !isGlass;
    el.tab3BlackView.hidden = isGlass;

    if (isGlass) {
      el.tab3ModelEyebrow.textContent = "Modèle transparent · R² = 0,31 · RMSE = 64 267 $ / an";
      el.tab3ModelTitle.textContent = "Boîte de verre : 7 paramètres directement lisibles";
      el.tab3ActiveScore.textContent = fmtDollar(olsPred.score, 0);
      renderEquationInto(el.tab3GlassEq, state.lastChangedKey);
    } else {
      el.tab3ModelEyebrow.textContent = "Modèle boîte noire · R² = 0,34 · RMSE = 62 837 $ / an";
      el.tab3ModelTitle.textContent = "Réseau de neurones : 329 paramètres en interaction non linéaire";
      el.tab3ActiveScore.textContent = fmtDollar(mlpPred.score, 0);
      updateMlpVisual(mlpPred);
      if (state.probeOpen) {
        renderProbeResults();
      }
    }
  }

  function syncProfileViews() {
    syncLeverControls();
    updateTab2();
    updateTab3();
  }

  function bindEvents() {
    el.tabBtns.forEach(function (btn) {
      btn.addEventListener("click", function () {
        setTab(btn.getAttribute("data-tab"));
      });
    });

    el.goTabBtns.forEach(function (btn) {
      btn.addEventListener("click", function () {
        setTab(btn.getAttribute("data-go-tab"));
        if (typeof window.scrollTo === "function") {
          window.scrollTo({ top: 0, behavior: "smooth" });
        }
      });
    });

    el.scatterSvg.addEventListener("click", handleScatterClick);

    el.sliderB0.addEventListener("input", function (e) {
      if (state.olsAnimId) {
        cancelAnimationFrame(state.olsAnimId);
        state.olsAnimId = null;
      }
      state.b0 = parseFloat(e.target.value);
      updateTab1();
    });

    el.sliderB1.addEventListener("input", function (e) {
      if (state.olsAnimId) {
        cancelAnimationFrame(state.olsAnimId);
        state.olsAnimId = null;
      }
      state.b1 = parseFloat(e.target.value);
      updateTab1();
    });

    el.toggleResiduals.addEventListener("change", function (e) {
      state.showResiduals = Boolean(e.target.checked);
      updateTab1();
    });

    el.btnFindOls.addEventListener("click", animateToOls);

    el.btnResetTab1.addEventListener("click", function () {
      if (state.olsAnimId) {
        cancelAnimationFrame(state.olsAnimId);
        state.olsAnimId = null;
      }
      state.b0 = TAB1_DEFAULT_B0;
      state.b1 = TAB1_DEFAULT_B1;
      updateTab1();
    });

    el.btnClearPoints.addEventListener("click", function () {
      state.addedPoints = [];
      el.scatterTooltip.hidden = true;
      renderScatterPoints();
      updateTab1();
    });

    el.btnResetTab2.addEventListener("click", resetToTypicalPreset);
    el.btnResetTab3.addEventListener("click", resetToTypicalPreset);

    el.btnFreezeA.addEventListener("click", function () {
      var pred = predictFullOls(state.profile);
      state.profileA = {
        values: Object.assign({}, state.profile),
        score: pred.score
      };
      updateTab2();
    });

    el.btnClearA.addEventListener("click", function () {
      state.profileA = null;
      updateTab2();
    });

    el.modeBtnGlass.addEventListener("click", function () {
      state.tab3Mode = "glass";
      updateTab3();
    });

    el.modeBtnBlack.addEventListener("click", function () {
      state.tab3Mode = "black";
      updateTab3();
    });

    el.btnRunProbe.addEventListener("click", function () {
      state.probeOpen = true;
      renderProbeResults();
    });
  }

  function initApp(data) {
    state.data = data;
    cacheElements();

    initScatterSvg();
    buildPresetsInto(el.presetsTab2, false);
    buildPresetsInto(el.presetsTab3, true);
    buildLeversInto(el.leversTab2, "tab2", false);
    buildLeversInto(el.leversTab3, "tab3", true);
    buildMlpSvg();
    bindEvents();

    resetToTypicalPreset();
    updateTab1();
    setTab("1");
  }

  document.addEventListener("DOMContentLoaded", function () {
    loadModelData()
      .then(initApp)
      .catch(function (err) {
        console.error(err);
      });
  });

  if (typeof module !== "undefined" && module.exports) {
    module.exports = {
      computeActiveOls: computeActiveOls,
      predictFullOls: predictFullOls,
      mlpForward: mlpForward,
      profileToVec: profileToVec
    };
  }
})();
