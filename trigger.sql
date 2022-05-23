
CREATE OR REPLACE TRIGGER trg_appointmentDateTime
  BEFORE INSERT OR UPDATE ON Appointment
  FOR EACH ROW
BEGIN
  IF :new.appointment_datetime<SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20052, 'Cannot insert the date time before now.' );
  ELSIF EXTRACT(HOUR FROM CAST(:new.appointment_datetime AS TIMESTAMP)) < 10 THEN
    RAISE_APPLICATION_ERROR(-20053, 'Date time must be within business hour.' );
  ELSIF EXTRACT(HOUR FROM CAST(:new.appointment_datetime AS TIMESTAMP)) > 17 THEN
    RAISE_APPLICATION_ERROR(-20053, 'Date time must be within business hour.' );
  END IF;
END;
/




CREATE OR REPLACE TRIGGER trg_delAppointment
   BEFORE DELETE ON Appointment
   FOR EACH ROW
   
DECLARE
   counter  NUMBER;

BEGIN
   counter := 0;
   
   SELECT COUNT(*) INTO counter
   FROM transaction
   WHERE appointment_id = :old.appointment_id;
   
   IF counter = 1 THEN
      DBMS_OUTPUT.PUT_LINE(:old.appointment_id||' has been recorded in the Transaction and cannot be deleted');
	  RAISE_APPLICATION_ERROR(-20055,'Appointment delete unsuccessful');
   END IF;

END;
/




CREATE OR REPLACE TRIGGER trgVetAge
  BEFORE INSERT OR UPDATE ON Veterinarian
  FOR EACH ROW
BEGIN
  IF((ROUND((SYSDATE-:new.vet_dob)/365)) < 22) THEN
    RAISE_APPLICATION_ERROR(-20002, 'Veterinarian must be at least 22 years old.' );
  END IF;
END;
/
