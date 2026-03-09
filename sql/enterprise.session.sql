DROP TABLE IF EXISTS risk_table CASCADE;
DROP TABLE IF EXISTS process_table CASCADE;
DROP TABLE IF EXISTS finance_table CASCADE;
DROP TABLE IF EXISTS ai_project_table CASCADE;

CREATE TABLE ai_project_table (
    project_id INT PRIMARY KEY,
    department VARCHAR(50),
    budget_million_usd DECIMAL(5,2),
    team_size INT,
    data_quality_score DECIMAL(5,2),
    infra_readiness_score DECIMAL(5,2),
    leadership_support_score DECIMAL(5,2),
    deployment_time_months INT,
    project_success INT
);
CREATE TABLE finance_table (
    department VARCHAR(50) PRIMARY KEY,
    annual_ai_investment_million DECIMAL(6,2),
    annual_automation_savings_million DECIMAL(6,2),
    maintenance_cost_million DECIMAL(6,2),
    net_benefit_million DECIMAL(6,2)
);
CREATE TABLE process_table (
    process_id INT PRIMARY KEY,
    department VARCHAR(50),
    frequency_per_month INT,
    avg_manual_hours DECIMAL(5,2),
    error_rate DECIMAL(5,3),
    cost_per_hour DECIMAL(6,2),
    manual_monthly_cost DECIMAL(10,2),
    automation_cost_estimate DECIMAL(10,2),
    automation_suitability INT
);
CREATE TABLE risk_table (
    project_id INT PRIMARY KEY,
    bias_risk_score DECIMAL(5,2),
    compliance_risk_score DECIMAL(5,2),
    cybersecurity_risk_score DECIMAL(5,2),
    data_sensitivity_score DECIMAL(5,2),
    overall_risk_index DECIMAL(6,2),
    FOREIGN KEY (project_id) REFERENCES ai_project_table(project_id)
);

COPY ai_project_table(
    project_id,
    department,
    budget_million_usd,
    team_size,
    data_quality_score,
    infra_readiness_score,
    leadership_support_score,
    deployment_time_months,
    project_success
)
FROM 'D:\DATA Analysis\Projects\Enterprise AI Transformation & ROI Intelligence Platform___SEM_6\Raw datasets\ai_project_table.csv'
DELIMITER ','
CSV HEADER;

COPY finance_table(
    department,
    annual_ai_investment_million,
    annual_automation_savings_million,
    maintenance_cost_million,
    net_benefit_million
)
FROM 'D:\DATA Analysis\Projects\Enterprise AI Transformation & ROI Intelligence Platform___SEM_6\Raw datasets\finance_table.csv'
DELIMITER ','
CSV HEADER;

COPY process_table(
    process_id,
    department,
    frequency_per_month,
    avg_manual_hours,
    error_rate,
    cost_per_hour,
    manual_monthly_cost,
    automation_cost_estimate,
    automation_suitability
)
FROM 'D:\DATA Analysis\Projects\Enterprise AI Transformation & ROI Intelligence Platform___SEM_6\Raw datasets\process_table.csv'
DELIMITER ','
CSV HEADER;

COPY risk_table(
    project_id,
    bias_risk_score,
    compliance_risk_score,
    cybersecurity_risk_score,
    data_sensitivity_score,
    overall_risk_index
)
FROM 'D:\DATA Analysis\Projects\Enterprise AI Transformation & ROI Intelligence Platform___SEM_6\Raw datasets\risk_table.csv'
DELIMITER ','
CSV HEADER;


-- Checking the count of rows
SELECT COUNT(*) FROM process_table; -- 500
SELECT COUNT(*) FROM ai_project_table; -- 200
SELECT COUNT(*) FROM finance_table; -- 6
SELECT COUNT(*) FROM risk_table; -- 200

 -- Checking Null values
SELECT *
FROM process_table
WHERE frequency_per_month IS NULL
   OR avg_manual_hours IS NULL
   OR error_rate IS NULL;

SELECT *
FROM ai_project_table
WHERE  project_id IS NULL OR
    department IS NULL OR
    budget_million_usd IS NULL OR
    team_size IS NULL OR
    data_quality_score IS NULL OR
    infra_readiness_score IS NULL OR
    leadership_support_score IS NULL OR
    deployment_time_months IS NULL OR
    project_success IS NULL;

SELECT *
FROM risk_table
WHERE project_id IS NULL OR
    bias_risk_score IS NULL OR
    compliance_risk_score IS NULL OR
    cybersecurity_risk_score IS NULL OR
    data_sensitivity_score IS NULL OR
    overall_risk_index IS NULL;

SELECT *
FROM finance_table
WHERE department IS NULL OR
    annual_ai_investment_million IS NULL OR
    annual_automation_savings_million IS NULL OR
    maintenance_cost_million IS NULL OR
    net_benefit_million IS NULL;

--Creating Annual Manual Cost
ALTER TABLE process_table
ADD COLUMN annual_manual_cost NUMERIC;

UPDATE process_table
SET annual_manual_cost = manual_monthly_cost * 12;

-- Automation Savings Potential
ALTER TABLE process_table
ADD COLUMN annual_automation_savings NUMERIC;

UPDATE process_table
SET annual_automation_savings =
    (manual_monthly_cost - automation_cost_estimate) * 12;

-- Scoring metric later help in automation ranking
ALTER TABLE process_table
ADD COLUMN efficiency_score NUMERIC;

UPDATE process_table
SET efficiency_score =
    (frequency_per_month * avg_manual_hours) / (1 + error_rate);


-- PHASE 3 - EXPLORATORY SQL BUSINESS ANALYSIS

-- Top 10 Most Expensive Processes
SELECT process_id,
       department,
       annual_manual_cost
FROM process_table
ORDER BY annual_manual_cost DESC
LIMIT 10;

-- Department-wise Total Manual Cost
SELECT department,
       SUM(annual_manual_cost) AS total_manual_cost
FROM process_table
GROUP BY department
ORDER BY total_manual_cost DESC;

-- Automation Savings by Department
SELECT department,
       SUM(annual_automation_savings) AS total_savings
FROM process_table
GROUP BY department
ORDER BY total_savings DESC;

-- High Error Rate Processes
SELECT *
FROM process_table
WHERE error_rate > 0.15
ORDER BY error_rate DESC;


-- PHASE 4 – AI Project Analysis

-- AI Project Success Rate
SELECT 
    COUNT(*) FILTER (WHERE project_success = 1) * 100.0 / COUNT(*) 
    AS success_rate_percentage
FROM ai_project_table;

 -- Success Rate by Department
SELECT department,
       AVG(project_success) * 100 AS success_percentage
FROM ai_project_table
GROUP BY department
ORDER BY success_percentage DESC;

-- Average Scores for Successful vs Failed Projects
SELECT project_success,
       AVG(data_quality_score) AS avg_data_quality,
       AVG(infra_readiness_score) AS avg_infra,
       AVG(leadership_support_score) AS avg_leadership
FROM ai_project_table
GROUP BY project_success;

-- PHASE 5 – Risk + Project Join Analysis

-- Joining Project + Risk
SELECT p.project_id,
       p.department,
       p.project_success,
       r.overall_risk_index
FROM ai_project_table p
JOIN risk_table r
ON p.project_id = r.project_id;

-- Risk vs Success Analysis
SELECT 
    p.project_success,
    AVG(r.overall_risk_index) AS avg_risk
FROM ai_project_table p
JOIN risk_table r
ON p.project_id = r.project_id
GROUP BY p.project_success;

-- PHASE 6 – ROI Analysis

-- Department ROI Calculation
SELECT department,
       annual_ai_investment_million,
       annual_automation_savings_million,
       maintenance_cost_million,
       (annual_automation_savings_million - maintenance_cost_million)
           / annual_ai_investment_million * 100 AS roi_percentage
FROM finance_table
ORDER BY roi_percentage DESC;

-- PHASE 7 – Create Analytical Views

-- View 1 – Automation Analytics View
CREATE VIEW automation_analytics AS
SELECT department,
       SUM(annual_manual_cost) AS total_manual_cost,
       SUM(annual_automation_savings) AS total_savings,
       AVG(error_rate) AS avg_error_rate
FROM process_table
GROUP BY department;

-- View 2 – AI Performance View
CREATE VIEW ai_performance AS
SELECT p.department,
       COUNT(*) AS total_projects,
       SUM(p.project_success) AS successful_projects,
       AVG(r.overall_risk_index) AS avg_risk
FROM ai_project_table p
JOIN risk_table r
ON p.project_id = r.project_id
GROUP BY p.department;

-- PHASE 8 – Advanced SQL (Consulting-Level)

-- Rank Departments by AI Readiness
SELECT department,
       AVG(data_quality_score + infra_readiness_score + leadership_support_score) 
           AS readiness_score
FROM ai_project_table
GROUP BY department
ORDER BY readiness_score DESC;

-- Automation Priority Ranking
SELECT process_id,
       department,
       annual_automation_savings,
       RANK() OVER (ORDER BY annual_automation_savings DESC) AS priority_rank
FROM process_table;


-- Exporting 

COPY (
    SELECT process_id,
           department,
           frequency_per_month,
           avg_manual_hours,
           error_rate,
           cost_per_hour,
           annual_manual_cost,
           annual_automation_savings,
           automation_suitability
    FROM process_table
) 
TO 'D:\DATA Analysis\Projects\Enterprise AI Transformation & ROI Intelligence Platform___SEM_6\process_cleaned.csv'
WITH CSV HEADER;

COPY (
    SELECT p.project_id,
           p.department,
           p.budget_million_usd,
           p.team_size,
           p.data_quality_score,
           p.infra_readiness_score,
           p.leadership_support_score,
           p.deployment_time_months,
           p.project_success,
           r.overall_risk_index
    FROM ai_project_table p
    JOIN risk_table r
    ON p.project_id = r.project_id
)
TO 'D:\DATA Analysis\Projects\Enterprise AI Transformation & ROI Intelligence Platform___SEM_6\project_cleaned.csv'
WITH CSV HEADER;

COPY finance_table
TO 'D:\DATA Analysis\Projects\Enterprise AI Transformation & ROI Intelligence Platform___SEM_6\finance_cleaned.csv'
WITH CSV HEADER;
