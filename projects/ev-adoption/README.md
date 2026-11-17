# EV Adoption Trends Across Washington State

Team project (UW Foster MSBA, SQL) analyzing electric vehicle adoption across Washington counties by county, make, range and income.

**Research questions**
- Which Washington counties are growing EV adoption fastest?
- Are buyers choosing high-range, high-price EVs or affordable models?
- Do clean-fuel (CAFV) eligibility and median household income relate to a county's EV adoption?

## Files
| Path | What it is |
|---|---|
| `EV_Adoption_Presentation.pptx` | Final presentation with charts and findings |
| `sql/ev_analysis.sql` | MySQL data cleaning and county-level analysis queries |
| `data/EV_Population.csv` | WA Department of Licensing EV population registry (~290K rows) |
| `data/EV_spec.csv` | EV model specs: battery, range, efficiency (Kaggle 2025, 478 rows) |
| `data/median_household_income.csv` | WA OFM median household income by county, 2011–2025 |

## Data cleaning highlights
- `electric_range = 0` set to `NULL` (unreported, not a real zero)
- Kept the latest re-registration per vehicle with `ROW_NUMBER()` over `dol_vehicle_id`
- Dropped non-WA and blank-county rows; `TRIM()` on county so every table joins cleanly
- Income strings cleaned with `REPLACE()`; all-zero summary rows excluded
- Specs pre-aggregated to one row per brand to avoid join fan-out; range converted km → miles

Data sources are public: Washington State Department of Licensing, Washington Office of Financial Management, and Kaggle.
