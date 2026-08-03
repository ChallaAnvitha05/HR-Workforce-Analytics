CREATE DATABASE hr_analytics_project;
USE hr_analytics_project;

CREATE TABLE hr_analytics (
    EmpId INT,
    Satisfaction DECIMAL(3,1),
    Evaluation DECIMAL(3,1),
    number_of_projects INT,
    average_montly_hours INT,
    time_spent_company INT,
    work_accident TINYINT,
    Promotion TINYINT,
    Department VARCHAR(100),
    Salary_INR INT,
    Churn TINYINT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/HR Analytics.csv'
INTO TABLE hr_analytics
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
EmpId,
Satisfaction,
Evaluation,
number_of_projects,
average_montly_hours,
time_spent_company,
work_accident,
Promotion,
Department,
Salary_INR,
Churn
);

SELECT COUNT(*) AS Total_Records
FROM hr_analytics;

CREATE TABLE departments AS
SELECT DISTINCT Department
FROM hr_analytics;

SELECT * FROM departments;

ALTER TABLE departments
ADD COLUMN DepartmentID INT AUTO_INCREMENT PRIMARY KEY FIRST;

SELECT * FROM departments;

CREATE TABLE employees AS
SELECT
    EmpId,
    Satisfaction,
    Evaluation,
    number_of_projects,
    average_montly_hours,
    time_spent_company,
    Department
FROM hr_analytics;

SELECT * FROM employees
LIMIT 5;

ALTER TABLE employees
ADD COLUMN DepartmentID INT;

DESCRIBE employees;

UPDATE employees e
JOIN departments d
ON e.Department = d.Department
SET e.DepartmentID = d.DepartmentID;

SELECT *
FROM employees
LIMIT 10;

SELECT DISTINCT DepartmentID
FROM employees;

ALTER TABLE employees
DROP COLUMN Department;

CREATE TABLE compensation AS
SELECT
    EmpId,
    Salary_INR,
    Promotion
FROM hr_analytics;

SELECT *
FROM compensation
LIMIT 10;

SELECT DISTINCT Promotion
FROM hr_analytics;

SELECT
    Promotion,
    COUNT(*) AS Total
FROM hr_analytics
GROUP BY Promotion;

SELECT Promotion, COUNT(*) AS Total
FROM compensation
GROUP BY Promotion;

CREATE TABLE employee_status AS
SELECT
    EmpId,
    work_accident,
    Churn
FROM hr_analytics;

SELECT *
FROM employee_status
LIMIT 10;

-- Query 1 – Total Employees
SELECT COUNT(*) AS Total_Employees
FROM employees;

-- Query 2 – Employees in Each Department
SELECT d.Department,
       COUNT(*) AS Employees
FROM employees e
JOIN departments d
ON e.DepartmentID = d.DepartmentID
GROUP BY d.Department
ORDER BY Employees DESC;

-- Query 3 – Average Satisfaction by Department
SELECT d.Department,
       ROUND(AVG(e.Satisfaction),2) AS Avg_Satisfaction
FROM employees e
JOIN departments d
ON e.DepartmentID = d.DepartmentID
GROUP BY d.Department
ORDER BY Avg_Satisfaction DESC;

-- Query 4 – Average Evaluation Score by Department
SELECT d.Department,
       ROUND(AVG(e.Evaluation),2) AS Avg_Evaluation
FROM employees e
JOIN departments d
ON e.DepartmentID = d.DepartmentID
GROUP BY d.Department
ORDER BY Avg_Evaluation DESC;

-- Query 5 – Average Monthly Hours by Department
SELECT d.Department,
       ROUND(AVG(e.average_montly_hours),0) AS Avg_Monthly_Hours
FROM employees e
JOIN departments d
ON e.DepartmentID = d.DepartmentID
GROUP BY d.Department
ORDER BY Avg_Monthly_Hours DESC;

-- Query 6 – Employees Working on More Than 5 Projects
SELECT EmpId,
       number_of_projects
FROM employees
WHERE number_of_projects > 5
ORDER BY number_of_projects DESC;

-- Query 7 – Employees Who Stayed More Than 5 Years
SELECT EmpId,
       time_spent_company
FROM employees
WHERE time_spent_company > 5
ORDER BY time_spent_company DESC;

SELECT DISTINCT time_spent_company
FROM employees
ORDER BY time_spent_company;

SELECT time_spent_company, COUNT(*) AS Total
FROM employees
WHERE time_spent_company > 5
GROUP BY time_spent_company
ORDER BY time_spent_company;

-- Query 8 – Salary Statistics
SELECT
MIN(Salary_INR) AS Minimum_Salary,
MAX(Salary_INR) AS Maximum_Salary,
ROUND(AVG(Salary_INR),0) AS Average_Salary
FROM compensation;

-- Query 9 – Promotion Statistics
SELECT Promotion,
COUNT(*) AS Employees
FROM compensation
GROUP BY Promotion;

-- Query 10 – Employee Attrition Statistics
SELECT Churn,
COUNT(*) AS Employees
FROM employee_status
GROUP BY Churn;

-- Query 11 – Departments with More Than 1,000 Employees (HAVING)
SELECT d.Department,
       COUNT(*) AS Employees
FROM employees e
JOIN departments d
ON e.DepartmentID = d.DepartmentID
GROUP BY d.Department
HAVING COUNT(*) > 1000
ORDER BY Employees DESC;

-- Query 12 – Average Salary by Department
SELECT d.Department,
       ROUND(AVG(c.Salary_INR),0) AS Average_Salary
FROM employees e
JOIN departments d
ON e.DepartmentID = d.DepartmentID
JOIN compensation c
ON e.EmpId = c.EmpId
GROUP BY d.Department
ORDER BY Average_Salary DESC;

-- Query 13 – Attrition by Department
SELECT d.Department,
       COUNT(*) AS Employees_Left
FROM employees e
JOIN departments d
ON e.DepartmentID = d.DepartmentID
JOIN employee_status s
ON e.EmpId = s.EmpId
WHERE s.Churn = 1
GROUP BY d.Department
ORDER BY Employees_Left DESC;

-- Query 14 – Promotion Count by Department
SELECT d.Department,
       COUNT(*) AS Promoted_Employees
FROM employees e
JOIN departments d
ON e.DepartmentID = d.DepartmentID
JOIN compensation c
ON e.EmpId = c.EmpId
WHERE c.Promotion = 1
GROUP BY d.Department
ORDER BY Promoted_Employees DESC;

-- Query 15 – Employees with Work Accidents
SELECT COUNT(*) AS Employees_With_Work_Accident
FROM employee_status
WHERE work_accident = 1;

-- Query 16 – Employee Performance Category
SELECT
EmpId,
Evaluation,
CASE
WHEN Evaluation >= 8 THEN 'Excellent'
WHEN Evaluation >= 6 THEN 'Good'
ELSE 'Needs Improvement'
END AS Performance_Category
FROM employees;

-- Query 17 – Employee Satisfaction Category
SELECT
EmpId,
Satisfaction,
CASE
WHEN Satisfaction >= 8 THEN 'Highly Satisfied'
WHEN Satisfaction >= 6 THEN 'Satisfied'
ELSE 'Low Satisfaction'
END AS Satisfaction_Level
FROM employees;

-- Query 18 – Employees Earning Above Average Salary
SELECT EmpId,
Salary_INR
FROM compensation
WHERE Salary_INR >
(
SELECT AVG(Salary_INR)
FROM compensation
);

-- Query 19 – Department with Highest Average Salary
SELECT d.Department,
ROUND(AVG(c.Salary_INR),0) AS Avg_Salary
FROM employees e
JOIN compensation c
ON e.EmpId = c.EmpId
JOIN departments d
ON e.DepartmentID = d.DepartmentID
GROUP BY d.Department
ORDER BY Avg_Salary DESC
LIMIT 1;

-- Query 20 – Top 10 Highest Paid Employees
SELECT EmpId,
Salary_INR
FROM compensation
ORDER BY Salary_INR DESC
LIMIT 10;

-- Query 21 – Rank Employees by Salary
SELECT
EmpId,
Salary_INR,
RANK() OVER (ORDER BY Salary_INR DESC) AS Salary_Rank
FROM compensation;

-- Query 22 – Dense Rank by Salary
SELECT
EmpId,
Salary_INR,
DENSE_RANK() OVER (ORDER BY Salary_INR DESC) AS Salary_Dense_Rank
FROM compensation;

-- Query 23 – Row Number by Salary
SELECT
EmpId,
Salary_INR,
ROW_NUMBER() OVER (ORDER BY Salary_INR DESC) AS Row_Num
FROM compensation;

-- Query 24 – Top 3 Highest Paid Employees in Each Department
SELECT *
FROM
(
SELECT
e.EmpId,
d.Department,
c.Salary_INR,
RANK() OVER
(
PARTITION BY d.Department
ORDER BY c.Salary_INR DESC
) AS SalaryRank
FROM employees e
JOIN departments d
ON e.DepartmentID=d.DepartmentID
JOIN compensation c
ON e.EmpId=c.EmpId
) x
WHERE SalaryRank<=3;

-- Query 25 – CTE: Employees Above Department Average Salary
WITH DeptSalary AS
(
SELECT
e.DepartmentID,
AVG(c.Salary_INR) AS AvgSalary
FROM employees e
JOIN compensation c
ON e.EmpId=c.EmpId
GROUP BY e.DepartmentID
)

SELECT
e.EmpId,
d.Department,
c.Salary_INR,
ds.AvgSalary
FROM employees e
JOIN compensation c
ON e.EmpId=c.EmpId
JOIN departments d
ON e.DepartmentID=d.DepartmentID
JOIN DeptSalary ds
ON e.DepartmentID=ds.DepartmentID
WHERE c.Salary_INR>ds.AvgSalary;

-- Query 26 – Department Attrition Rate
SELECT
d.Department,
ROUND(
SUM(CASE WHEN s.Churn=1 THEN 1 ELSE 0 END)*100.0
/
COUNT(*),2
) AS Attrition_Percentage
FROM employees e
JOIN employee_status s
ON e.EmpId=s.EmpId
JOIN departments d
ON e.DepartmentID=d.DepartmentID
GROUP BY d.Department
ORDER BY Attrition_Percentage DESC;

-- Query 27 – Employees with Excellent Evaluation and High Satisfaction
SELECT
EmpId,
Satisfaction,
Evaluation
FROM employees
WHERE Satisfaction>=8
AND Evaluation>=8;

-- Query 28 – Department with Highest Average Satisfaction
SELECT
d.Department,
ROUND(AVG(e.Satisfaction),2) AS Avg_Satisfaction
FROM employees e
JOIN departments d
ON e.DepartmentID=d.DepartmentID
GROUP BY d.Department
ORDER BY Avg_Satisfaction DESC
LIMIT 1;

-- Query 29 – Employees Working More Than Department Average Hours
SELECT
e.EmpId,
d.Department,
e.average_montly_hours
FROM employees e
JOIN departments d
ON e.DepartmentID=d.DepartmentID
WHERE e.average_montly_hours >
(
SELECT AVG(e2.average_montly_hours)
FROM employees e2
WHERE e2.DepartmentID=e.DepartmentID
);

-- Query 30 – Executive HR Dashboard Summary
SELECT
COUNT(*) AS Total_Employees,
ROUND(AVG(Satisfaction),2) AS Avg_Satisfaction,
ROUND(AVG(Evaluation),2) AS Avg_Evaluation,
ROUND(AVG(average_montly_hours),0) AS Avg_Monthly_Hours,
ROUND(AVG(time_spent_company),1) AS Avg_Years_at_Company
FROM employees;