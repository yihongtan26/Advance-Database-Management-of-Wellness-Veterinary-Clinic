--Strategic: Top pet_type received treatment in each branch

clear break
clear compute
set linesize 80
set pagesize 100
break on state on branch_id skip 1
COMPUTE SUM LABEL TOTAL OF nooftreatment percentage transactionamount on branch_id
TTITLE ON
TTITLE CENTER  'Top Pet Type that received treatment in each branch' SKIP 1- 
CENTER ========================================================= SKIP 2
COLUMN branch_id FORMAT a10
COLUMN branch_id HEADING 'Branch ID'
COLUMN state FORMAT a15
COLUMN type_name FORMAT a10
COLUMN type_name HEADING 'Pet Type'
COLUMN nooftreatment HEADING 'Treatment|Received'
COLUMN transactionamount FORMAT 9999999.99
COLUMN transactionamount HEADING 'Total|Transaction|Made'
COLUMN Percentage FORMAT 999.99
COLUMN Percentage HEADING 'Percent|Over|Total'

CREATE OR REPLACE VIEW topPetTreatment AS
SELECT t.branch_id, pt.type_name, COUNT(t.appointment_id) AS NoOfTreatment, SUM(t.total_amount) AS TransactionAmount
FROM appointment a, veterinarian v, pet p, petType pt, transaction t
WHERE t.appointment_id=a.appointment_id AND a.vet_id=v.vet_id AND a.pet_id=p.pet_id
      AND p.type_id=pt.type_id AND t.appointment_id=a.appointment_id
GROUP BY t.branch_id, pt.type_name
ORDER BY t.branch_id, SUM(t.total_amount) DESC;

SELECT a.branch_id, b.state, a.type_name, a.nooftreatment, (a.NoOfTreatment/COUNT(t.appointment_id))*100 AS Percentage, a.transactionAmount, RANK() OVER(PARTITION BY a.branch_id ORDER BY a.transactionAmount DESC) Ranks
FROM topPetTreatment a, transaction t, branch b
WHERE a.branch_id=t.branch_id AND a.branch_id=b.branch_id
GROUP BY a.branch_id, b.state, a.type_name, a.nooftreatment, a.transactionAmount
ORDER BY a.branch_id, a.transactionamount DESC;




--Tactical: Appointment based on timestamp  in each branch for last year,(morning,afternoon,evening) (to increase or decrease staff shifts)

clear break
clear compute
set linesize 71
set pagesize 100
BREAK ON REPORT
COMPUTE SUM LABEL TOTAL AVG LABEL AVERAGE OF MORNING AFTERNOON EVENING totalappointment ON REPORT
COLUMN morning FORMAT 999999999
COLUMN afternoon FORMAT 999999999
COLUMN evening FORMAT 999999999
TTITLE ON
TTITLE CENTER 'Appointment made on times of a day in each branch for last year' SKIP 1- 
CENTER =================================================================== SKIP 2
COLUMN branch_id FORMAT a10
COLUMN branch_id HEADING 'Branch ID'
COLUMN state FORMAT a15
COLUMN totalappointment FORMAT 999999999
COLUMN totalappointment HEADING 'Total|Appointment'

CREATE OR REPLACE VIEW morningApp AS
SELECT t.branch_id, COUNT(t.transaction_id) AS MORNING
FROM appointment a, transaction t
WHERE t.appointment_id = a.appointment_id AND 
      EXTRACT(HOUR FROM CAST(a.appointment_datetime AS TIMESTAMP)) BETWEEN 10 AND 12
	  AND EXTRACT(YEAR FROM a.appointment_datetime) = EXTRACT(YEAR FROM SYSDATE)-1
GROUP BY t.branch_id
ORDER BY t.branch_id;

CREATE OR REPLACE VIEW afternoonApp AS
SELECT t.branch_id, COUNT(t.transaction_id) AS AFTERNOON
FROM appointment a, transaction t
WHERE t.appointment_id = a.appointment_id AND 
      EXTRACT(HOUR FROM CAST(a.appointment_datetime AS TIMESTAMP)) BETWEEN 13 AND 15
	  AND EXTRACT(YEAR FROM a.appointment_datetime) = EXTRACT(YEAR FROM SYSDATE)-1
GROUP BY t.branch_id
ORDER BY t.branch_id;

CREATE OR REPLACE VIEW eveningApp AS
SELECT t.branch_id, COUNT(t.transaction_id) AS EVENING
FROM appointment a, transaction t
WHERE t.appointment_id = a.appointment_id AND 
      EXTRACT(HOUR FROM CAST(a.appointment_datetime AS TIMESTAMP)) BETWEEN 16 AND 18
	  AND EXTRACT(YEAR FROM a.appointment_datetime) = EXTRACT(YEAR FROM SYSDATE)-1
GROUP BY t.branch_id
ORDER BY t.branch_id;

SELECT a.branch_id, d.state, a.morning, b.afternoon, c.evening, (a.morning + b.afternoon + c.evening) AS TotalAppointment
FROM morningApp a, afternoonApp b, eveningApp c, branch d
WHERE a.branch_id=b.branch_id AND a.branch_id=c.branch_id AND a.branch_id=d.branch_id
GROUP BY a.branch_id, d.state, a.morning, b.afternoon, c.evening
ORDER BY a.branch_id;






--Operational: 2020 first half sales vs 2020 second half sales

clear break
clear compute
BREAK ON REPORT
COMPUTE SUM LABEL TOTAL AVG LABEL AVERAGE OF SALES2020_1STHALF SALES2020_2NDHALF SALESDIFF ON REPORT
set linesize 95
set pagesize 100
TTITLE ON
TTITLE CENTER 'Year 2020 first half sales vs second half sales' SKIP 1- 
CENTER ================================================== SKIP 2
COLUMN branch_id FORMAT a10
COLUMN branch_id HEADING 'Branch ID'
COLUMN state FORMAT a15
COLUMN SALES2020_1STHALF FORMAT 9999999.99
COLUMN SALES2020_1STHALF HEADING 'First Half Sales'
COLUMN SALES2020_2NDHALF FORMAT 9999999.99
COLUMN SALES2020_2NDHALF HEADING 'Second Half Sales'
COLUMN SALESDIFF FORMAT 9999999.99
COLUMN SALESDIFF HEADING 'Sales Different'
COLUMN SALESDIFF_PERCENTAGE FORMAT 999.99
COLUMN SALESDIFF_PERCENTAGE HEADING 'Percent Different'

CREATE OR REPLACE VIEW Sales2020_1stHalf AS
SELECT branch_id, SUM(total_amount) AS Sales2020_1stHalf
FROM transaction
WHERE EXTRACT(YEAR FROM transaction_dateTime) = 2020 AND EXTRACT(MONTH FROM transaction_dateTime) <= 6 
GROUP BY branch_id
ORDER BY branch_id, SUM(total_amount) DESC;

CREATE OR REPLACE VIEW Sales2020_2ndHalf AS
SELECT branch_id, SUM(total_amount) AS Sales2020_2ndHalf
FROM transaction
WHERE EXTRACT(YEAR FROM transaction_dateTime) = 2020 AND EXTRACT(MONTH FROM transaction_dateTime) > 6 
GROUP BY branch_id
ORDER BY branch_id, SUM(total_amount) DESC;

SELECT a.branch_id, c.state, a.Sales2020_1stHalf, b.Sales2020_2ndHalf, Sales2020_2ndHalf-Sales2020_1stHalf AS SalesDiff, (Sales2020_2ndHalf/Sales2020_1stHalf)*100 AS SalesDiff_Percentage
FROM branch c, Sales2020_1stHalf a, Sales2020_2ndHalf b
WHERE a.branch_id=c.branch_id AND b.branch_id=c.branch_id
GROUP BY a.branch_id, c.state, a.Sales2020_1stHalf, b.Sales2020_2ndHalf
ORDER BY branch_id;
































