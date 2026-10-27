# adnexpexa

The ADNEX model of the International Ovarian Tumor Analysis (IOTA) group, from
its published equations. For a woman with an adnexal mass assessed by
ultrasound before surgery, it estimates the probabilities that the mass is
benign, borderline, stage I invasive, stage II–IV invasive or secondary
metastatic, and the total risk of malignancy.

Van Calster B, et al. Evaluating the risk of ovarian cancer before surgery
using the ADNEX model to differentiate between benign, borderline, early and
advanced stage invasive, and secondary metastatic tumours: prospective
multicentre diagnostic study. *BMJ.* 2014;349:g5920.
[doi:10.1136/bmj.g5920](https://doi.org/10.1136/bmj.g5920)

This is **not** the certified IOTA/Gynaia ADNEX application. The IOTA group
withdrew its own ADNEX calculators because, under the EU Medical Device
Regulation, it regards such calculators as medical devices needing
certification. Certified versions are now distributed by Gynaia.

## Two models

| Model | Used when | Source of coefficients |
|---|---|---|
| With CA-125 | `ca125` is given | BMJ 2014, supplementary appendix D; identical in BMJ 2020, appendix 4 |
| Without CA-125 | `ca125` is left out | Van Calster B, et al. *BMJ* 2020;370:m2614, supplementary appendix 4 |

The version without CA-125 is a separately fitted model with its own
coefficients. It is not the CA-125 model with the CA-125 term set to zero.
`model = "with_ca125"` or `"without_ca125"` forces a choice.

## Inputs

| Field | Meaning |
|---|---|
| `age` | years |
| `ca125` | serum CA-125, U/mL (optional; must be > 0) |
| `lesion_diameter` | maximum diameter of the lesion, mm |
| `solid_diameter` | maximum diameter of the largest solid component, mm (0 if none; not more than the lesion) |
| `more_than_10_locules` | yes/no |
| `papillary_projections` | number, 0–3, or 4 for more than three |
| `acoustic_shadows` | yes/no |
| `ascites` | yes/no (fluid outside the pouch of Douglas) |
| `oncology_centre` | examined at a gynaecological oncology centre, yes/no |

Ultrasound variables follow the IOTA terms and definitions. The proportion of
solid tissue is `solid_diameter / lesion_diameter`; lesion diameter and CA-125
enter as log2. The model was developed in women with at least one adnexal mass
who had surgery within 120 days of the scan, excluding pregnant women.

## Output

`risk_benign`, `risk_borderline`, `risk_stage_i`, `risk_stage_ii_iv`,
`risk_metastatic` (these five sum to 1), `risk_malignant` (1 − benign),
`proportion_solid`, and `model`.

## Validation

All published examples are reproduced to their printed 0.1 percentage point:

| Case | Published (borderline, stage I, stage II–IV, metastatic) | This package |
|---|---|---|
| BMJ 2014 example, with CA-125 | 37.4, 10.8, 8.4, 11.0 (total 67.6) | 37.4, 10.8, 8.4, 11.0 (67.6) |
| BMJ 2014 example, without CA-125 | 25.2, 8.3, 35.8, 11.5 | 25.2, 8.3, 35.8, 11.5 |
| Van Calster 2015 case 1, with CA-125 | 1.6, 4.6, 67.9, 21.2 (total 95.3) | 1.6, 4.6, 67.9, 21.2 (95.3) |
| Van Calster 2015 case 2, with CA-125 | 18.7, 13.3, 5.9, 3.0 (total 40.9) | 18.7, 13.3, 5.9, 3.0 (40.9) |

Van Calster B, et al. Practical guidance for applying the ADNEX model from the
IOTA group. *Facts Views Vis Obgyn.* 2015;7:32–41.

## Use

```r
remotes::install_git("https://github.com/raminrzn/adnexpexa", ref = "main")
adnexpexa::adnex(age = 55, ca125 = 42, lesion_diameter = 120,
                 solid_diameter = 20, more_than_10_locules = "yes",
                 papillary_projections = 0, acoustic_shadows = "no",
                 ascites = "yes", oncology_centre = "yes")
```

For research use. Not a medical device.

## Licence

GPL-3. Coefficients are from Van Calster et al., BMJ 2020 (CC BY 4.0) and BMJ
2014 (CC BY-NC 3.0), with attribution.
