--- Bank Loan Status Exploratory Data Analysis

--- Creating a table 
CREATE TABLE Loans (
    Loan_ID TEXT ,
    Customer_ID TEXT,
    Loan_Status TEXT,
    Current_Loan_Amount INTEGER,
    Term TEXT,
    Credit_Score INTEGER,
    Annual_Income INTEGER,
    Years_In_Current_Job INTEGER,
    Job_Duration_Category TEXT,
    Home_Ownership TEXT,
    Purpose TEXT,
    Monthly_Debt DECIMAL,
    Years_Of_Credit_History DECIMAL,
    Number_Of_Open_Accounts INTEGER,
    Number_Of_Credit_Problems INTEGER,
    Current_Credit_Balance INTEGER,
    Maximum_Open_Credit INTEGER,
    Bankruptcies INTEGER,
    Tax_Liens INTEGER
);

--- viewing the table --
SELECT  * 
FROM loans;

--- 3. Loan payback Rate Analysis
----3.1 Overall payback  Rate:
SELECT 
	COUNT(*) AS total_no_of_loans,
	SUM(CASE WHEN "loan_status" = 'Fully Paid' THEN 1 ELSE 0 END) AS Paid,
	ROUND((SUM(CASE WHEN "loan_status" = 'Fully Paid' THEN 1 ELSE 0 END)*1.0/COUNT(*)),2) As Paid_rate
FROM loans;


---- 3.2 payback Rates by Loan Term:
SELECT
	term,
	COUNT(*) AS total_no_of_loans,
	SUM(CASE WHEN "loan_status" = 'Fully Paid' THEN 1 ELSE 0 END) AS Paid,
	ROUND((SUM(CASE WHEN "loan_status" = 'Fully Paid' THEN 1 ELSE 0 END)*1.0/COUNT(*)),2) As Paid_rate
FROM loans
GROUP BY term;

--- 3.3  Overall chargeoff  Rate:
SELECT 
	COUNT(*) AS total_no_of_loans,
	SUM(CASE WHEN "loan_status" = 'Charged Off' THEN 1 ELSE 0 END) AS charge_off,
	ROUND((SUM(CASE WHEN "loan_status" = 'Charged Off' THEN 1 ELSE 0 END)*1.0/COUNT(*)),2) As Paid_rate
FROM loans;

-- 4 Credit Score Analysis
--- 4.1 How is the distribution of credit scores among borrowers?
SELECT
	CASE
		WHEN credit_score BETWEEN 500 AND 649 THEN 'Poor'
		WHEN credit_score BETWEEN 650 AND 699 THEN 'Fair'
		WHEN credit_score BETWEEN 700 AND 749 THEN  'Good'
		WHEN credit_score >= 750  THEN 'Excellent'
	END AS credit_score_category,
	COUNT(*) AS total_borrowers
FROM loans
GROUP BY credit_score_category
		
--- 4.2 Distribution of credit scores among borrowers along with loan Payback rate?

SELECT
	CASE
		WHEN credit_score BETWEEN 500 AND 649 THEN 'Poor (500-649)'
		WHEN credit_score BETWEEN 650 AND 699 THEN 'Fair (650-699)'
		WHEN credit_score BETWEEN 700 AND 749 THEN  'Good (700 -749)'
		WHEN credit_score >= 750  THEN 'Excellent (750 above)'
	END AS credit_score_category,
	COUNT(*) AS total_borrowers,
	SUM(CASE WHEN loan_status = 'Fully Paid' THEN 1 ELSE 0 END) AS total_paid,
	ROUND((SUM(CASE WHEN "loan_status" = 'Fully Paid' THEN 1 ELSE 0 END)*1.0/COUNT(*)),2) As Paid_rate
FROM loans
GROUP BY credit_score_category
ORDER BY paid_rate DESC

-- 5  Income vs. Loan Amount
--- 5.1 The relationship between annual income and the current loan amount.
SELECT
    ROUND(AVG(Annual_Income),2) AS Avg_Annual_Income,
    MIN(Annual_Income) AS Min_Annual_Income,
    MAX(Annual_Income) AS Max_Annual_Income,
    ROUND(AVG(Current_Loan_Amount),2) AS Avg_Current_Loan_Amount,
    MIN(Current_Loan_Amount) AS Min_Current_Loan_Amount,
    MAX(Current_Loan_Amount) AS Max_Current_Loan_Amount
FROM
    Loans;
-- 6 Home Ownership Imppact
---6.1 The relationship between home ownership and loan payback
SELECT
	home_ownership,
	COUNT(*) AS total_no_of_loans,
	SUM(CASE WHEN "loan_status" = 'Fully Paid' THEN 1 ELSE 0 END) AS Paid,
	ROUND((SUM(CASE WHEN "loan_status" = 'Fully Paid' THEN 1 ELSE 0 END)*1.0/COUNT(*)),2) As Paid_rate
FROM loans
GROUP BY home_ownership;

---6.2 The relationshiop between home ownership and loan amount
SELECT home_ownership, SUM(current_loan_amount) as Total_loan,
ROUND(AVG(current_loan_amount),2) AS average_loan,
MIN(current_loan_amount) AS minimum_loan,
MAX(current_loan_amount) AS maximum_loan
FROM loans
GROUP BY home_ownership
ORDER BY total_loan DESC

--7 Loan Purpose and relation with credit score and loan amount
SELECT purpose,
ROUND(AVG(credit_score),2) AS average_credit_score,
ROUND(AVG(current_loan_amount),2) AS average_loan
FROM loans
GROUP BY purpose
ORDER BY average_loan DESC



---8 Number of Credit Problems
SELECT 
CASE
		WHEN credit_score BETWEEN 500 AND 649 THEN 'Poor (500-649)'
		WHEN credit_score BETWEEN 650 AND 699 THEN 'Fair (650-699)'
		WHEN credit_score BETWEEN 700 AND 749 THEN  'Good (700 -749)'
		WHEN credit_score >= 750  THEN 'Excellent (750 above)'
	END AS credit_score_category,
SUM(number_of_credit_problems) As credit_problems
FROM loans
GROUP BY credit_score_category

--9 Risk Analysis
--- 9.1 Credit score and Charge offs coorelation
WITH CTE AS(
SELECT credit_score,
	CASE 
		WHEN "loan_status" = 'Charged Off'
		THEN 1 ELSE 0
		END AS Charged_off
FROM loans)
SELECT 
CORR(credit_score,Charged_Off) As coorelation
FROM CTE

--- 9.2 Relation with Bankrupties and Taxliens
SELECT
    Bankruptcies,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN Loan_Status = 'Fully Paid' THEN 1 ELSE 0 END) AS FullyPaid,
    SUM(CASE WHEN Loan_Status = 'Charged Off' THEN 1 ELSE 0 END) AS ChargedOff
FROM
    loans
GROUP BY
    Bankruptcies

SELECT
    Tax_Liens,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN Loan_Status = 'Fully Paid' THEN 1 ELSE 0 END) AS FullyPaid,
    SUM(CASE WHEN Loan_Status = 'Charge Off' THEN 1 ELSE 0 END) AS ChargedOff
FROM
    loans
GROUP BY
    Tax_Liens;

-- 10 Employment History Analysis:
SELECT years_in_current_job,job_duration_category,COUNT(*) AS total_borrower 
FROM loans
GROUP BY 1,2
ORDER BY 1 DESC

--- 11 Monthly debt ratio and loan term:

WITH TermDebtCTE AS (
    SELECT
        Term,
        SUM(Monthly_Debt) AS TotalTermDebt
    FROM
        loans
    GROUP BY
        Term
)
, TotalMonthlyDebtCTE AS (
    SELECT
        SUM(Monthly_Debt) AS TotalMonthlyDebt
    FROM
        loans
)
SELECT
    Term,
    MAX(TotalTermDebt) AS TotalTermDebt,
    ROUND(MAX(TotalTermDebt) * 100.0 / (SELECT TotalMonthlyDebt FROM TotalMonthlyDebtCTE),2) AS PercentageOfTotalDebt
FROM
    TermDebtCTE
WHERE
    Term IN ('Short Term', 'Long Term')
GROUP BY
    Term;


