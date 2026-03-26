--table creation
CREATE TABLE PET_CARE_LOG (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    created_by  VARCHAR2(30),
    log_text    VARCHAR2(500),
    log_datetime TIMESTAMP DEFAULT SYSTIMESTAMP,
    update_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by_user VARCHAR2(30)
)

--Triggers
--1
CREATE OR REPLACE TRIGGER insert_pet_care_log_row
BEFORE INSERT ON pet_care_log
FOR EACH ROW
BEGIN
    :NEW.update_date := SYSTIMESTAMP;
    :NEW.updated_by_user := USER;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Error in insert trigger: ' || SQLERRM
        );
END;

--2
CREATE OR REPLACE TRIGGER update_pet_care_log_row
BEFORE UPDATE ON pet_care_log
FOR EACH ROW
BEGIN
    IF USER != :OLD.updated_by_user THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'Update by user mismatch'
        );
    END IF;
    :NEW.update_date := SYSTIMESTAMP;
    :NEW.updated_by_user := USER;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20003,
            'Error in update trigger: ' || SQLERRM
        );
END;
/

--3
CREATE OR REPLACE TRIGGER delete_pet_care_log_row
BEFORE DELETE ON pet_care_log
FOR EACH ROW
BEGIN
    IF USER != 'JOEMANAGER' THEN
        RAISE_APPLICATION_ERROR(
            -20004,
            'User not allowed to delete rows'
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20005,
            'Error in delete trigger: ' || SQLERRM
        );
END;

--bogus test data
INSERT INTO PET_CARE_LOG (created_by, log_text, updated_by_user)
VALUES ('ALICE', 'Fed the dogs and cleaned their cages', 'ALICE');

INSERT INTO PET_CARE_LOG (created_by, log_text, updated_by_user)
VALUES ('BOB', 'Administered medication to the sick cat', 'BOB');

INSERT INTO PET_CARE_LOG (created_by, log_text, updated_by_user)
VALUES ('CARLOS', 'Refilled water bowls for all animals', 'CARLOS');

INSERT INTO PET_CARE_LOG (created_by, log_text, updated_by_user)
VALUES ('DIANA', 'Groomed the poodles and trimmed nails', 'DIANA');

INSERT INTO PET_CARE_LOG (created_by, log_text, updated_by_user)
VALUES ('ELENA', 'Cleaned the bird cages and replaced liners', 'ELENA');

INSERT INTO PET_CARE_LOG (created_by, log_text, updated_by_user)
VALUES ('FRANK', 'Walked the dogs in the morning shift', 'FRANK');

INSERT INTO PET_CARE_LOG (created_by, log_text, updated_by_user)
VALUES ('GRACE', 'Checked inventory of pet food supplies', 'GRACE');

INSERT INTO PET_CARE_LOG (created_by, log_text, updated_by_user)
VALUES ('HENRY', 'Assisted vet during routine checkups', 'HENRY');

INSERT INTO PET_CARE_LOG (created_by, log_text, updated_by_user)
VALUES ('ISABEL', 'Sanitized feeding areas and tools', 'ISABEL');

INSERT INTO PET_CARE_LOG (created_by, log_text, updated_by_user)
VALUES ('JOEMANAGER', 'Reviewed daily operations and staff logs', 'JOEMANAGER');