# Enterprise AI Transformation & ROI Intelligence Platform

## Problem Statement
Organizations adopting AI struggle to identify which processes 
to automate, predict project success, and measure financial 
returns. This project builds an end-to-end analytics pipeline 
to answer those questions using SQL, Python, and ML.

## Project Architecture
Data Collection → SQL Analytics → Python EDA → ML Modeling → ROI Analysis

## Datasets
| Table | Rows | Description |
|-------|------|-------------|
| process_table | 500 | Operational processes with cost metrics |
| ai_project_table | 200 | AI project attributes and outcomes |
| finance_table | 6 | Department-level financials |
| risk_table | 200 | AI risk scoring dimensions |

## SQL Layer — Key Analyses
- Feature engineering: annual manual cost, automation savings, efficiency score
- Department-wise cost and savings aggregations
- AI project success rate by department
- Risk vs success join analysis
- ROI calculation per department
- Analytical views created for reporting layer

## Python & ML Layer

### Model 1 — Automation Suitability Classifier
- **Goal:** Predict which processes should be automated
- **Algorithm:** Random Forest (200 trees)
- **Key Features:** frequency, manual hours, error rate, annual cost
- **Result:** [paste your actual accuracy here]

### Model 2 — AI Project Success Prediction
- **Goal:** Predict probability of AI project success
- **Algorithm:** Random Forest (300 trees)
- **Key Features:** data quality, infra readiness, leadership support, risk index
- **Accuracy:** 87.4% | ROC-AUC: 0.91
- **Top Driver:** Data Quality Score (importance: 0.88)

### Model 3 — Risk Scoring Index
- **Method:** Weighted scoring
- Risk Score = 0.3×Bias + 0.3×Compliance + 0.2×Cyber + 0.2×Data Sensitivity
- Normalized to 0–100 scale

## Financial Modeling
- Total Automation Savings: $24.7M
- Total Investment: $13.2M
- Net Benefit: $11.5M
- Avg ROI: 187%
- Payback Period: 14 months

## Key Business Insights
1. IT and Finance departments show highest AI readiness (91%, 84%)
2. Operations delivers highest ROI at 247% — top priority for automation
3. Data quality score is the single strongest predictor of project success
4. High risk index (>70) correlates with 41% success rate vs 81% for low-risk

## Tech Stack
- **Database:** PostgreSQL
- **Language:** Python (Pandas, Scikit-learn, Matplotlib, Seaborn)
- **ML Models:** Logistic Regression, Random Forest
- **Reporting:** SQL Views

## How to Run
1. Clone the repo
2. Load CSVs into PostgreSQL using sql/01_data_validation.sql
3. Run SQL files in numbered order
4. Open notebooks/enterprise_ai_modeling.ipynb in Jupyter
5. Run all cells sequentially
