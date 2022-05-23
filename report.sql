set serveroutput on;
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI';
set linesize 150


--Summary: Specific veterinarian with all of his/her transactions made in a year

CREATE OR REPLACE PROCEDURE prc_vet_summary(IN_vetID in CHAR, IN_year in NUMBER) AS

   v_vetName     VARCHAR2(50);
   v_branchID    CHAR(5);
   v_state       VARCHAR2(50);
   v_totalAmount NUMBER;
   counter       NUMBER;
   record_count  NUMBER;
   e_norecord    EXCEPTION;
   PRAGMA EXCEPTION_INIT(e_norecord,-20060);
   
   CURSOR vet_trans IS
      SELECT  t.transaction_id, t.appointment_id, tr.treatment_type, t.transaction_dateTime, t.total_amount
	  FROM transaction t, appointment a, treatment tr
	  WHERE t.appointment_id=a.appointment_id AND a.treatment_id=tr.treatment_id AND a.vet_id=IN_vetID AND EXTRACT(YEAR FROM t.transaction_dateTime) = IN_year
	  ORDER BY transaction_dateTime DESC;

BEGIN
   v_totalAmount := 0;
   counter := 0;
   record_count := 0;
   
   SELECT COUNT(*) INTO record_count
   FROM transaction t, appointment a
   WHERE t.appointment_id=a.appointment_id AND EXTRACT(YEAR FROM t.transaction_dateTime) = IN_year AND a.vet_id=IN_vetID;
   
   IF record_count = 0 THEN
     RAISE_APPLICATION_ERROR(-20060,'No record found');
   END IF;
   
   SELECT v.vet_name, v.branch_id, b.state INTO v_vetName, v_branchID, v_state
   FROM veterinarian v, branch b
   WHERE v.branch_id=b.branch_id AND vet_id=IN_vetID;
   
   DBMS_OUTPUT.PUT_LINE (chr(10));
   DBMS_OUTPUT.PUT_LINE ('Summary report of all transaction made by Veterinarian '||IN_vetID);
   DBMS_OUTPUT.PUT_LINE('Report generated on : ' || TO_CHAR(CURRENT_DATE, 'DD-MM-YYYY HH:MI:SS') || ' by ' || USER);
   DBMS_OUTPUT.PUT_LINE (chr(10));
   DBMS_OUTPUT.PUT_LINE ('Veterinarian Name : '||v_vetName);
   DBMS_OUTPUT.PUT_LINE ('Branch ID         : '||v_branchID);
   DBMS_OUTPUT.PUT_LINE ('State             : '||v_state);
   
   DBMS_OUTPUT.PUT_LINE(LPAD('-', 120, '-'));
   DBMS_OUTPUT.PUT_LINE(RPAD('Transaction ID', 23, ' ') || RPAD('Appointment ID', 23, ' ') || RPAD('Treatment Type', 30, ' ')|| RPAD('Transaction Date Time', 32, ' ') || RPAD('Total Amount', 20, ' '));
   DBMS_OUTPUT.PUT_LINE(LPAD('-', 120, '-'));
   
   FOR trans IN vet_trans LOOP
      DBMS_OUTPUT.PUT_LINE(RPAD(trans.transaction_id,23,' ')||RPAD(trans.appointment_id,23,' ')|| RPAD(trans.treatment_type, 30, ' ')||RPAD(trans.transaction_dateTime, 32, ' ') ||'RM '|| RPAD(TRIM(TO_CHAR(trans.total_amount,'999G999D99')), 17, ' '));
	  
	  v_totalAmount := v_totalAmount + trans.total_amount;
	  counter := counter + 1;

   END LOOP;
   
   DBMS_OUTPUT.PUT_LINE(LPAD('=', 120, '='));
   DBMS_OUTPUT.PUT_LINE(RPAD(('Total Treatment Done : '||counter),75,' ')||'Total Amount of Transaction : RM '||TRIM(TO_CHAR(v_totalAmount,'999G999D99')));
   DBMS_OUTPUT.PUT_LINE(LPAD('=', 120, '='));

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE ('No Veterinarian found');
   WHEN e_norecord THEN
      DBMS_OUTPUT.PUT_LINE('--------------------------------');
      DBMS_OUTPUT.PUT_LINE('Failed to print report for ' || IN_year || '.');
      DBMS_OUTPUT.PUT_LINE('--------------------------------');
      DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/


exec prc_vet_summary('V0007','2021');





--Detail: List all customers in specific state with appointment made in a year


CREATE OR REPLACE PROCEDURE prc_less_appointment(IN_state IN VARCHAR2,IN_year IN NUMBER) AS
   
   counter       NUMBER;
   record_count  NUMBER;
   e_norecord    EXCEPTION;
   PRAGMA EXCEPTION_INIT(e_norecord,-20062);
   
   CURSOR cust_cursor IS
      SELECT owner_id, owner_name, owner_gender, owner_contact, state
	  FROM petowner
	  WHERE state = IN_state;
	
   CURSOR app_cursor IS
      SELECT t.owner_id, a.appointment_id, a.pet_id, p.pet_name, pt.type_name, a.treatment_id, tr.treatment_type, a.vet_id, v.vet_name, a.appointment_dateTime
	  FROM appointment a, transaction t, treatment tr, veterinarian v, pet p, pettype pt
	  WHERE t.appointment_id=a.appointment_id AND a.treatment_id=tr.treatment_id AND a.vet_id=v.vet_id AND a.pet_id=p.pet_id AND p.type_id=pt.type_id AND EXTRACT(YEAR FROM a.appointment_dateTime) = IN_year;

BEGIN
   record_count := 0;
   
   SELECT COUNT(*) INTO record_count
   FROM transaction t, appointment a, branch b
   WHERE t.appointment_id=a.appointment_id AND EXTRACT(YEAR FROM a.appointment_dateTime) = IN_year AND b.state LIKE IN_state;
   
   IF record_count = 0 THEN
     RAISE_APPLICATION_ERROR(-20062,'No record found');
   END IF;
   
   DBMS_OUTPUT.PUT_LINE (chr(10));
   DBMS_OUTPUT.PUT_LINE ('All customers in '||IN_state||' with appointment made in the year '||IN_year);
   DBMS_OUTPUT.PUT_LINE('Report generated on : ' || TO_CHAR(CURRENT_DATE, 'DD-MM-YYYY HH:MI:SS') || ' by ' || USER);
   DBMS_OUTPUT.PUT_LINE (chr(10));
   
   FOR cust IN cust_cursor LOOP
      counter := 0;
      DBMS_OUTPUT.PUT_LINE ('Customer ID    : '||cust.owner_ID);
      DBMS_OUTPUT.PUT_LINE ('Customer Name  : '||cust.owner_name);
	  DBMS_OUTPUT.PUT_LINE ('Contact        : '||cust.owner_contact);
	  DBMS_OUTPUT.PUT_LINE ('Gender         : '||cust.owner_gender);
      DBMS_OUTPUT.PUT_LINE ('State          : '||cust.state);
   
      DBMS_OUTPUT.PUT_LINE(LPAD('-', 135, '-'));
      DBMS_OUTPUT.PUT_LINE(RPAD('Appointment ID', 20, ' ') || RPAD('Pet', 28, ' ') || RPAD('Treatment', 35, ' ')|| RPAD('Veterinarian Handled', 31, ' ') || RPAD('Appointment Date Time', 25, ' '));
      DBMS_OUTPUT.PUT_LINE(LPAD('-', 135, '-'));
	  
	  FOR app IN app_cursor LOOP
	     IF app.owner_ID = cust.owner_ID THEN
	        DBMS_OUTPUT.PUT_LINE(RPAD(app.appointment_id, 20, ' ') || RPAD((app.pet_id||' '||app.pet_name||' ( '||app.type_name||')'), 28, ' ') || RPAD((app.treatment_id||' '||app.treatment_type), 35, ' ')|| RPAD((app.vet_id||' '||app.vet_name), 31, ' ') || RPAD(app.appointment_dateTime, 20, ' '));
			
			counter := counter + 1;
		 END IF;
	  
	  END LOOP;
	  
	  DBMS_OUTPUT.PUT_LINE(LPAD('=', 135, '='));
	  DBMS_OUTPUT.PUT_LINE(RPAD('*',113,' ')||'No of record found: '||counter);
	  DBMS_OUTPUT.PUT_LINE(CHR(10));

   END LOOP;
   
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE ('No Veterinarian found');
   WHEN e_norecord THEN
      DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
      DBMS_OUTPUT.PUT_LINE('No record found for state '||IN_state||' in year '||IN_year||'.');
      DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
  
END;
/


exec prc_less_appointment('Kedah',2020);




--On-demand: List of customer who do transaction for less than 3 times in a year



CREATE OR REPLACE PROCEDURE prc_less_appointment(IN_year IN NUMBER) AS

   counter       NUMBER;
   record_count  NUMBER;
   e_norecord    EXCEPTION;
   PRAGMA EXCEPTION_INIT(e_norecord,-20061);
  
  CURSOR cust_trans IS
	 SELECT po.owner_id, po.owner_name, po.owner_contact, po.owner_gender, po.state, COUNT(t.transaction_dateTime) AS TotalTransaction, MAX(t.transaction_dateTime) AS LastTransaction
	 FROM petowner po, transaction t
	 WHERE t.owner_id=po.owner_id AND EXTRACT(YEAR FROM t.transaction_dateTime) = IN_year
	 GROUP BY po.owner_id, po.owner_name, po.owner_contact, po.owner_gender, po.state;
	 
BEGIN
   counter := 0;
   record_count := 0;
   
   SELECT COUNT(*) INTO record_count
   FROM petowner po, transaction t
   WHERE t.owner_id=po.owner_id AND EXTRACT(YEAR FROM t.transaction_dateTime) = IN_year;
   
   IF record_count = 0 THEN
     RAISE_APPLICATION_ERROR(-20061,'No record found');
   END IF;
   
   DBMS_OUTPUT.PUT_LINE (chr(10));
   DBMS_OUTPUT.PUT_LINE ('List of customer who do transaction for less than 3 times in the year '||IN_year);
   DBMS_OUTPUT.PUT_LINE('Report generated on : ' || TO_CHAR(CURRENT_DATE, 'DD-MM-YYYY HH:MI:SS') || ' by ' || USER);
   DBMS_OUTPUT.PUT_LINE (chr(10));
   
   DBMS_OUTPUT.PUT_LINE(LPAD('-', 137, '-'));
   DBMS_OUTPUT.PUT_LINE(RPAD('Customer ID', 15, ' ') || RPAD('Customer Name', 26, ' ') || RPAD('Customer Contact', 20, ' ')|| RPAD('Gender', 10, ' ') || RPAD('State', 20, ' ') || RPAD('No of Transaction made', 25, ' ') || RPAD('Last Transaction Date', 30, ' '));
   DBMS_OUTPUT.PUT_LINE(LPAD('-', 137, '-'));
   
   FOR cust_record IN cust_trans LOOP
      IF cust_record.totaltransaction < 3 THEN
	     DBMS_OUTPUT.PUT_LINE(RPAD(cust_record.owner_id, 15, ' ') || RPAD(cust_record.owner_name, 26, ' ') || RPAD(cust_record.owner_contact, 20, ' ')|| RPAD(cust_record.owner_gender, 10, ' ') || RPAD(cust_record.state, 20, ' ') || RPAD(cust_record.totaltransaction, 25, ' ') || RPAD(cust_record.lasttransaction, 30, ' '));
		 
		 counter := counter + 1;
	  END IF;

   END LOOP;
   
   DBMS_OUTPUT.PUT_LINE(LPAD('=', 137, '='));
   DBMS_OUTPUT.PUT_LINE(RPAD('*',110,' ')||'Total No of Customer: '||counter);
   DBMS_OUTPUT.PUT_LINE(LPAD('=', 137, '='));

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE ('No Veterinarian found');
   WHEN e_norecord THEN
      DBMS_OUTPUT.PUT_LINE('--------------------------------');
      DBMS_OUTPUT.PUT_LINE('Failed to print report for ' || IN_year || '.');
      DBMS_OUTPUT.PUT_LINE('--------------------------------');
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
  
END;
/



exec prc_less_appointment(2020);







