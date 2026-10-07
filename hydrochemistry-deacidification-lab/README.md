# Deacidification of Water with Calcium Carbonate and Half-Burnt Dolomite

Laboratory report for the module MHSE08 Hydrochemistry, M.Sc. Hydro Science and Engineering, TU Dresden (experiment date 5 January 2026). We did the experiment in groups, with one group per reactor. My group worked on **Reactor 4 (MAGNO-DOL)**; the data of the other reactors come from the other groups.

---

## Project overview

| | |
|---|---|
| **Question** | Which of four commercial filter materials deacidifies acidic raw water best, as in drinking water treatment? |
| **Setup** | Water passed through four column reactors, one material each: HYDROLIT-Ca, HYDRO-Carbonate, AKDOLIT-GRAN, MAGNO-DOL |
| **Measurements** | pH, temperature, conductivity, acid neutralising capacity (ANC4.3, ANC8.2), base neutralising capacity (BNC8.2), titration of Ca²⁺ and Ca²⁺+Mg²⁺ with EDTA |
| **Evaluation** | Calco-carbonic equilibrium with the Tillmans and Langelier equations, and the German drinking water limits |

**Hypothesis:** dolomite-based materials (AKDOLIT-GRAN, MAGNO-DOL) react faster with CO₂ than calcium carbonate (HYDROLIT-Ca, HYDRO-Carbonate), so they should deacidify best.

## Why this matters

Acidic water with a lot of dissolved CO₂ dissolves calcite and corrodes pipes. Treatment brings the water close to calco-carbonic equilibrium, where it neither dissolves nor deposits calcite. The aim is a saturation index (SI) close to zero and a pH inside the legal range of 6.5 to 9.5.

---

## What I did (Reactor 4)

I titrated the treated water and calculated:

| Quantity | Titration | Result |
|---|---|---|
| ANC4.3 | 11.5 mL of 0.1 M HCl in 100 mL sample | 11.5 mmol/L |
| ANC8.2 | 2.5 mL of 0.1 M HCl in 100 mL sample | 2.5 mmol/L |
| Ca²⁺ | 0.9 mL of 0.01 M EDTA in 50 mL sample | 0.18 mmol/L |
| Ca²⁺ + Mg²⁺ | 14.7 mL of 0.01 M EDTA in 25 mL sample | 5.88 mmol/L |
| Mg²⁺ | by difference | 5.7 mmol/L |

For all reactors I then calculated the carbonate species (HCO₃⁻, CO₃²⁻, CO₂), the ionic strength from the conductivity, and the activity coefficient. With these I applied the **Tillmans equation** (comparing measured CO₂ with the equilibrium CO₂) and the **Langelier equation** (pH of equilibrium, pHeq, and the saturation index SI = pH − pHeq).

## Results

| Parameter | Raw water | HYDROLIT-Ca | HYDRO-Carbonate | AKDOLIT-GRAN | MAGNO-DOL |
|---|---|---|---|---|---|
| pH | 5.1 | 7.7 | 6.8 | 8.7 | 9.6 |
| Conductivity (µS/cm) | 124 | 685 | 613 | 1060 | 771 |
| ANC4.3 (mmol/L) | 0.925 | 7.5 | 6.4 | 13.3 | 11.5 |
| Ca²⁺ (mmol/L) | 0.46 | 1.96 | 3.2 | 0.7 | 0.18 |
| Mg²⁺ (mmol/L) | 0.36 | 2.0 | 0.0 | 2.79 | 5.7 |
| pHeq (Langelier) | 8.56 | 7.14 | 6.99 | not possible | 8.25 |
| Saturation index SI | −3.46 | +0.56 | −0.19 | not possible | +1.35 |
| Condition | calcite-dissolving | calcite-precipitating | calcite-dissolving | not determined | calcite-precipitating |

- **Raw water:** SI of −3.46, so it is calcite-dissolving and strongly corrosive. It needs deacidification.
- **HYDROLIT-Ca:** the most effective for this contact time. It raised the pH to 7.7 and is slightly oversaturated (SI +0.56).
- **HYDRO-Carbonate:** moves the water closer to equilibrium, but SI stays negative (−0.19), so the water is still slightly corrosive. A longer contact time could fix this.
- **MAGNO-DOL:** deacidifies strongly, but the pH of 9.6 is above the German limit of 9.5, and the water would deposit calcite (SI +1.35). A shorter contact time could keep the pH below 9.5.
- **AKDOLIT-GRAN:** its group could not determine ANC8.2, so the carbonate species and SI could not be calculated. The pH of 8.7 suggests that, like MAGNO-DOL, it is calcite-precipitating, but this is an inference.

**Compared with the hypothesis:** the dolomite materials raised the pH the most (9.6 and 8.7), which fits their faster reaction. But "faster" meant overshooting the drinking water limits for the contact time used, so HYDROLIT-Ca came out as the best choice.

## Calculation pages from the report

### Titration calculations (Reactor 4)
![Titration calculations](assets/titration-calculations.png)

### Results of all reactors and raw water
![Experimental results](assets/experimental-results-table.png)

### Tillmans and Langelier calculations, saturation index
![Calcite saturation index](assets/calcite-saturation-index.png)

## Limitations

- One run per reactor, one contact time, and no repeat measurements, so the results have no uncertainty estimate.
- The data of Reactors 1 to 3 come from other groups; I did not measure them.
- AKDOLIT-GRAN could not be fully evaluated (missing ANC8.2).
- The recommendations to lengthen or shorten the contact time were not tested.
- The equilibrium calculations depend on the equilibrium constants and the activity model used (Debye–Hückel type with ionic strength from conductivity), so the SI values are estimates.

## Skills shown

- Laboratory titration and calculation of water chemistry parameters (ANC, BNC, hardness).
- Calco-carbonic equilibrium with the Tillmans and Langelier equations.
- Judging treatment results against drinking water regulations.
- Reporting an incomplete data set honestly.

## Folder contents

```text
.
├── README.md
├── documentation/   # the report (PDF); remove the cover page first
└── assets/          # figures used in this README
```

## Author

Fashli Adli Wal Ikhsan · [github.com/fashliadli](https://github.com/fashliadli)
