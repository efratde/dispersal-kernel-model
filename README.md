# Dispersal-Kernel Evolution — an Agent-Based Model (NetLogo)

> **Portfolio demonstration — synthetic data.** Every plant, landscape, and genotype here is produced by the simulation itself: the modelled populations, their heritable dispersal alleles, and all resulting dispersal-kernel, spatial-genetic-structure, and inbreeding output are fictional and represent no real population, place, or field measurement. This is a portfolio piece, not a real dataset.


An individual-based (agent-based) simulation of how plant **seed-dispersal kernels** evolve when dispersal strategy is genetically encoded and free to change across generations. Built in **NetLogo**, with parameter sweeps via **BehaviorSpace** and output analysis in **R**, documented following the **ODD protocol**.

> **Note on provenance.** This is one of a family of dispersal-evolution models I designed and built during my PhD. They are my own research/exploratory models and were **not** the basis of a specific publication. *(My co-authored paper Greenbaum, Dener & Giladi 2022, J. R. Soc. Interface — "Limits to the evolution of dispersal kernels under rapid fragmentation" — uses a different model, developed by G. Greenbaum, and is listed on my CV under publications.)*

---

## What the model does

Plants disperse seeds according to a *dispersal kernel* — the probability distribution of dispersal distances. This model simulates a population of plants in which the dispersal strategy is **genetically encoded** (heritable alleles), then lets seeds disperse, establish, compete for space, and reproduce across many generations, while tracking how the dispersal kernel — and the population's **spatial genetic structure** and **inbreeding load** — changes over time.

Each simulated plant carries heritable alleles controlling its dispersal kernel; pollen and seeds disperse over a spatial landscape; offspring establish and compete; and the evolving kernel, relatedness, and inbreeding are recorded. Sweeping parameters (genetic architecture, dispersal distance, gamete number, neighbourhood size, mixing) maps how dispersal strategy and genetic structure co-evolve.

## My role

- **Designed and implemented the model** in NetLogo — population dynamics, genetic encoding of dispersal strategies, and the dispersal / pollination / establishment / competition / reproduction rules.
- **Designed and ran the simulation experiments** (BehaviorSpace parameter sweeps).
- **Analyzed the output in R** and produced summary figures.
- Documented the model following the **ODD protocol** for reproducibility.

## Repository structure

```
dispersal-kernel-model/
├── model/        NetLogo model (.nlogo) — the simulation itself
├── docs/         self-contained NetLogo Web export (runs in a browser)
├── analysis/     R scripts that process BehaviorSpace output → figures
└── .gitignore    excludes simulation output, raw data, and bulky files
```

## Data policy

This repository contains **code, not data**. The simulation **generates** its own data — there is nothing private here. Raw BehaviorSpace output (CSV/XLSX) is regenerable and is excluded via `.gitignore` to keep the repo lean.

## ▶ Run it in your browser

The model runs live in the browser via **NetLogo Web** — no install needed:
**[▶ Run the model in NetLogo Web](https://www.netlogoweb.org/launch#https://raw.githubusercontent.com/efratde/dispersal-kernel-model/main/model/dispersal-kernel-model.nlogo)**
*(Allow ~25–30 s to compile on first load — the model is large. Click **setup**, then **go**.)*

## How to run locally

1. Open `model/dispersal-kernel-model.nlogo` in **NetLogo 6.x**.
2. Click **setup**, then **go** to run the simulation interactively.
3. For experiments: run the BehaviorSpace experiment (`Tools → BehaviorSpace`), then open `analysis/` in R/RStudio to reproduce the figures.

---

*Part of the research-software portfolio of Dr. Efrat Dener — plant ecologist & quantitative/computational researcher.*
