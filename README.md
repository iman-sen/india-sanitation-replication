# Progress on Sanitation in Rural India: Reconciling Diverse Evidence

Replication code for the paper *"Progress on Sanitation in Rural India: Reconciling Diverse Evidence".

The analysis combines six national surveys — NFHS-4, NARSS 1–3, NSS-76, NFHS-5 — to track changes in rural toilet ownership and use across India between 2015 and 2021.

## Repository contents

| Path | Description |
| --- | --- |
| `Do-files/` | Stata code: data construction, figures, tables |
| `Do-files/Master.do` | Top-level runner — set `$main` and execute |
| `Output/Figures/` | Paper figures produced by the code |
| `Output/Tables/` | Paper tables (Excel) produced by the code |
| `Output/Regressions/` | Regression output files |
| `Readme.docx` | Full project documentation |

Microdata files (`.dta`) are **not** included in this repository — see the next section.

## Obtaining the input data

You will need to download each survey separately and place the cleaned `.dta` files in `Data/StataData/`. Sources:

* **NFHS-4 (2015–16) and NFHS-5 (2019–21)** — DHS Program: <https://dhsprogram.com/data/dataset_admin/login_main.cfm> (registration required, no redistribution permitted).
* **NARSS 1, 2, 3 (2017–2020)** — National Annual Rural Sanitation Surveys, available via the Department of Drinking Water and Sanitation, Government of India: <https://jalshakti-ddws.gov.in/>.
* **NSS Round 76 (2018)** — National Sample Survey Office (MoSPI): <https://microdata.gov.in/nada43/index.php/catalog/NSSO>.

The expected raw filenames are referenced in each `createvars_*.do` file.

## How to run

1. Open `Do-files/Master.do`.
  
2. Set the global `main` (line 12) to the path where you have cloned this repository:
  
      global main "C:/your/path/to/india-sanitation-replication"
  
3. Run the file. It will:
  
  * install required Stata packages (`schemepack`, `shp2dta`, `spmap`, `ereplace`),
  * construct the analysis variables for each survey (run the `createvars_*.do` block — currently commented out),
  * build the appended panel (`create_panel_allsurveys.do`),
  * produce all paper figures and tables.

The `createvars_*` block is commented out by default; uncomment it the first time you build the dataset.

## Software

* Stata 17 or later.
* The packages above are installed automatically by `Master.do`.

##

## Contact

Iman Sen — isen1@terpmail.umd.edu
