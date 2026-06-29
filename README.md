# Evolution of Dispersal Kernels under Habitat Fragmentation

An individual-based (agent-based) simulation model of how plant **seed-dispersal kernels** evolve when habitats fragment rapidly — and the limits on that evolution. Built in **NetLogo**, with parameter sweeps via **BehaviorSpace** and output analysis in **R**, documented following the **ODD protocol**.

> **Published as:** Greenbaum, G., **Dener, E.** & Giladi, I. (2022). *Limits to the evolution of dispersal kernels under rapid fragmentation.* **Journal of the Royal Society Interface** 19(188), 20210696. [doi:10.1098/rsif.2021.0696](https://doi.org/10.1098/rsif.2021.0696)

---

## What the model does

Plants disperse seeds according to a *dispersal kernel* — the probability distribution of dispersal distances. When a landscape fragments, selection on that kernel changes. This model simulates a population of plants in which dispersal strategy is **genetically encoded** and free to evolve, then asks: under rapid fragmentation, **how far and how fast can the dispersal kernel actually evolve — and what constrains it?**

Each simulated plant carries heritable alleles controlling its dispersal kernel; seeds disperse, establish, compete for space, and reproduce across many generations; fragmentation is imposed and the evolving kernel is tracked. Sweeping parameters (fragmentation rate, genetic architecture, relatedness/selection regimes) maps the conditions under which dispersal evolution keeps pace with environmental change — and where it hits limits.

## My role

- **Designed and implemented the model** in NetLogo (population dynamics, genetic encoding of dispersal strategies, dispersal/competition/reproduction rules, fragmentation scenarios).
- **Designed and ran the simulation experiments** (BehaviorSpace parameter sweeps).
- **Analyzed the output in R** and produced the figures for the paper.
- Documented the model with the **ODD protocol** for reproducibility.
- Co-author on the resulting publication.

## Repository structure

```
dispersal-kernel-model/
├── model/        NetLogo model (.nlogo) — the simulation itself
├── analysis/     R scripts that process BehaviorSpace output → paper figures
├── docs/         ODD protocol description of the model
└── .gitignore    excludes simulation output, raw data, and bulky/copyrighted files
```

## Data policy

This repository contains **code, not data**. The simulation **generates** its own data — there is nothing private here. Raw BehaviorSpace output (CSV/XLSX) is regenerable and is excluded via `.gitignore` to keep the repo lean. To reproduce the results, run the BehaviorSpace experiment and then the analysis scripts (see below).

## ▶ Run it in your browser

Once this repo is public, the model runs live in the browser via **NetLogo Web** — no install needed:
`https://www.netlogoweb.org/launch#https://raw.githubusercontent.com/efratde/dispersal-kernel-model/main/model/dispersal-kernel-model.nlogo`
*(NetLogo Web supports most but not all primitives; verify the model loads before sharing the link.)*

## How to run locally

1. Open `model/dispersal-kernel-model.nlogo` in **NetLogo 6.x**.
2. Run the BehaviorSpace experiment to generate output (`Tools → BehaviorSpace`).
3. Open `analysis/` in R/RStudio and run the notebook to reproduce the figures.

---

*Part of the research-software portfolio of Dr. Efrat Dener — plant ecologist & quantitative/computational researcher. Other projects available on request.*

<!-- TO FINALIZE (Efrat): (1) confirm the canonical/final .nlogo filename to place in model/ ; (2) confirm NetLogo version; (3) I'll generalize any hard-coded file paths in the R scripts before this goes public. -->
