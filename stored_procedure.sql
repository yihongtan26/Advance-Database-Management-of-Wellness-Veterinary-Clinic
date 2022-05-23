set serveroutput on;
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI';


--Add appointment

CREATE OR REPLACE PROCEDURE PRC_ADD_APPOINTMENT(IN_vetID in CHAR, IN_treatmentID in CHAR, IN_petID in CHAR, IN_dateTime in DATE) AS
   v_insertID   CHAR(10);
   v_branchID   CHAR(5);
   counter_t    NUMBER;
   counter_p    NUMBER;
   e_invalid_treatment EXCEPTION;
   PRAGMA EXCEPTION_INIT(e_invalid_treatment, -20050);
   e_invalid_pet EXCEPTION;
   PRAGMA EXCEPTION_INIT(e_invalid_pet, -20051);
   
BEGIN
   counter_t := 0;
   counter_p := 0;

   SELECT branch_id INTO v_branchID
   FROM veterinarian
   WHERE vet_id = IN_vetID;
   
   SELECT COUNT(*) INTO counter_t
   FROM treatment
   WHERE treatment_id = IN_treatmentID;
   
   IF counter_t = 0 THEN
      RAISE_APPLICATION_ERROR(-20050, 'Invalid Treatment ID.');
   END IF;
   
   SELECT COUNT(*) INTO counter_p
   FROM pet
   WHERE pet_id = IN_petID;
     
   IF counter_p = 0 THEN
      RAISE_APPLICATION_ERROR(-20051, 'Invalid Pet ID.');
   END IF;
   
   IF v_branchID = 'B0001' THEN
      v_insertID := TO_CHAR('PP'||app_seq_PG.NEXTVAL);
	  
   ELSIF v_branchID = 'B0002' THEN
      v_insertID := TO_CHAR('KL'||app_seq_KL.NEXTVAL);

   ELSIF v_branchID = 'B0003' THEN
      v_insertID := TO_CHAR('KD'||app_seq_KD.NEXTVAL);
	  
   END IF;

   insert into appointment values(v_insertID,IN_vetID,IN_treatmentID,IN_petID,IN_dateTime);
   
   DBMS_OUTPUT.PUT_LINE (CHR(10));
   DBMS_OUTPUT.PUT_LINE ('Appointment add SUCCESSFUL as follows: ');
   DBMS_OUTPUT.PUT_LINE ('Appointment ID: '||v_insertID||'|Veterinarian ID: '||IN_vetID||'|Treatment ID: '||IN_treatmentID||'|Pet ID: '||IN_petID||'|Appointment Date Time: '||IN_dateTime);
   

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE ('No Veterinarian found');
   WHEN e_invalid_treatment THEN
      DBMS_OUTPUT.PUT_LINE('No such Treatment ID');
	  DBMS_OUTPUT.PUT_LINE(SQLERRM);
   WHEN e_invalid_pet THEN
      DBMS_OUTPUT.PUT_LINE('No such Pet ID');
	  DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

exec prc_add_appointment('V0001','T0001','P0001','02-SEP-2021 11:00');

--Try error

--No VET
exec prc_add_appointment('V0000','T0001','P0001','23-AUG-2021 11:00');

--No Treatment
exec prc_add_appointment('V0001','T0099','P0001','23-AUG-2021 11:00');

--No Pet
exec prc_add_appointment('V0001','T0001','P0000','23-AUG-2021 11:00');

--Before sysdate
exec prc_add_appointment('V0001','T0001','P0001','22-AUG-2021 11:00');

--before 10
exec prc_add_appointment('V0001','T0001','P0001','23-SEP-2021 09:00');

--after 17
exec prc_add_appointment('V0001','T0001','P0001','23-SEP-2021 18:00');




--Delete appointment

CREATE OR REPLACE PROCEDURE PRC_DEL_APPOINTMENT(IN_appointmentID in CHAR) AS
   
BEGIN
   DELETE FROM appointment
   WHERE appointment_id = IN_appointmentID;
   
   DBMS_OUTPUT.PUT_LINE (IN_appointmentID||' Deleted successfully.');
   
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         DBMS_OUTPUT.PUT_LINE ('No Appointment found');

END;
/


-- Existed record in transaction
exec PRC_DEL_APPOINTMENT('PP10007064');











