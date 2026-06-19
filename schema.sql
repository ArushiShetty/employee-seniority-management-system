-- ====================================================================
-- HAL OVERHAUL DIVISION - HR SENIORITY MANAGEMENT SYSTEM
-- DATABASE DDL & SEED DATA (ORACLE COMPATIBLE)
-- ====================================================================

-- 1. DROP TABLES & SEQUENCES (FOR CLEAN RE-RUNS)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TRN_PROMOTIONS CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE MST_EMPLOYEES CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE MST_USERS CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE SYS_AUDIT_LOGS CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_PROMOTIONS';
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_AUDIT_LOGS';
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Ignore if tables do not exist
END;
/

-- 2. CREATE SEQUENCES
CREATE SEQUENCE SEQ_PROMOTIONS START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_AUDIT_LOGS START WITH 1 INCREMENT BY 1 NOCACHE;

-- 3. CREATE USERS TABLE (AUTHENTICATION & AUTHORIZATION)
CREATE TABLE MST_USERS (
    username VARCHAR2(20) PRIMARY KEY,
    password_hash VARCHAR2(100) NOT NULL, -- SHA-1 hash (compatible with simple Java 1.4 hashing)
    user_role VARCHAR2(15) DEFAULT 'USER' NOT NULL,
    employee_name VARCHAR2(100) NOT NULL,
    CONSTRAINT chk_user_role CHECK (user_role IN ('ADMIN', 'USER'))
);

-- Seed Default users:
-- 'admin' with password 'admin123' (SHA-1: d033e22ae348aeb5660fc2140aec35850c4da997)
-- 'operator' with password 'hal123' (SHA-1: bd90e6e73ec2319f3f4c6e93ffdf6a44b82d49ad)
INSERT INTO MST_USERS (username, password_hash, user_role, employee_name) 
VALUES ('admin', 'd033e22ae348aeb5660fc2140aec35850c4da997', 'ADMIN', 'HR Admin Officer');

INSERT INTO MST_USERS (username, password_hash, user_role, employee_name) 
VALUES ('operator', 'bd90e6e73ec2319f3f4c6e93ffdf6a44b82d49ad', 'USER', 'HR Clerk');

-- 4. CREATE EMPLOYEE MASTER TABLE
CREATE TABLE MST_EMPLOYEES (
    employee_id VARCHAR2(10) PRIMARY KEY,
    employee_name VARCHAR2(100) NOT NULL,
    grade VARCHAR2(10) NOT NULL,            -- 'Grade 1' to 'Grade 10'
    emp_level VARCHAR2(10) NOT NULL,        -- 'Level 1', 'Level 2', etc.
    promotion_date DATE NOT NULL,           -- Promotion date into current grade
    date_of_joining DATE NOT NULL,
    date_of_birth DATE NOT NULL,
    department VARCHAR2(50) NOT NULL,
    designation VARCHAR2(50) NOT NULL,
    company_id NUMBER(5) DEFAULT 17 NOT NULL,
    CONSTRAINT chk_emp_dates CHECK (date_of_joining > date_of_birth),
    CONSTRAINT chk_grade CHECK (grade IN (
        'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5',
        'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10'
    ))
);

-- 5. CREATE PROMOTION HISTORY TABLE
CREATE TABLE TRN_PROMOTIONS (
    promotion_id NUMBER PRIMARY KEY,
    employee_id VARCHAR2(10) NOT NULL,
    grade VARCHAR2(10) NOT NULL,
    promotion_date DATE NOT NULL,
    order_number VARCHAR2(30),
    company_id NUMBER(5) DEFAULT 17 NOT NULL,
    pos_code VARCHAR2(30) NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    is_primary NUMBER(1) DEFAULT 0 NOT NULL,
    assignment_type VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_promo_emp FOREIGN KEY (employee_id) REFERENCES MST_EMPLOYEES(employee_id) ON DELETE CASCADE,
    CONSTRAINT chk_is_primary CHECK (is_primary IN (0, 1))
);

-- 6. CREATE SYS AUDIT LOGS TABLE
CREATE TABLE SYS_AUDIT_LOGS (
    log_id NUMBER PRIMARY KEY,
    changed_by VARCHAR2(20),
    table_name VARCHAR2(30) NOT NULL,
    record_id VARCHAR2(20) NOT NULL,
    action_type VARCHAR2(10) NOT NULL,
    changed_field VARCHAR2(30),
    old_value CLOB,
    new_value CLOB,
    log_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 7. AUDIT TRIGGERS FOR DATA SECURITY
CREATE OR REPLACE TRIGGER TRG_AUDIT_EMPLOYEE
AFTER UPDATE OR DELETE ON MST_EMPLOYEES
FOR EACH ROW
DECLARE
    v_action VARCHAR2(10);
BEGIN
    IF UPDATING THEN
        v_action := 'UPDATE';
        IF :OLD.employee_name != :NEW.employee_name THEN
            INSERT INTO SYS_AUDIT_LOGS (log_id, changed_by, table_name, record_id, action_type, changed_field, old_value, new_value)
            VALUES (SEQ_AUDIT_LOGS.NEXTVAL, NULL, 'MST_EMPLOYEES', :OLD.employee_id, v_action, 'employee_name', :OLD.employee_name, :NEW.employee_name);
        END IF;
        IF :OLD.grade != :NEW.grade THEN
            INSERT INTO SYS_AUDIT_LOGS (log_id, changed_by, table_name, record_id, action_type, changed_field, old_value, new_value)
            VALUES (SEQ_AUDIT_LOGS.NEXTVAL, NULL, 'MST_EMPLOYEES', :OLD.employee_id, v_action, 'grade', :OLD.grade, :NEW.grade);
        END IF;
        IF :OLD.promotion_date != :NEW.promotion_date THEN
            INSERT INTO SYS_AUDIT_LOGS (log_id, changed_by, table_name, record_id, action_type, changed_field, old_value, new_value)
            VALUES (SEQ_AUDIT_LOGS.NEXTVAL, NULL, 'MST_EMPLOYEES', :OLD.employee_id, v_action, 'promotion_date', TO_CHAR(:OLD.promotion_date, 'YYYY-MM-DD'), TO_CHAR(:NEW.promotion_date, 'YYYY-MM-DD'));
        END IF;
    ELSIF DELETING THEN
        v_action := 'DELETE';
        INSERT INTO SYS_AUDIT_LOGS (log_id, changed_by, table_name, record_id, action_type, changed_field, old_value, new_value)
        VALUES (SEQ_AUDIT_LOGS.NEXTVAL, NULL, 'MST_EMPLOYEES', :OLD.employee_id, v_action, 'ALL_FIELDS', :OLD.employee_name, NULL);
    END IF;
END;
/

-- 8. INDEXES FOR PERFORMANCE OPTIMIZATION
CREATE INDEX idx_emp_grade_lookup ON MST_EMPLOYEES(grade);
CREATE INDEX idx_promo_emp_lookup ON TRN_PROMOTIONS(employee_id);

-- 9. SEED EMPLOYEES & PROMOTION HISTORY TO TEST ALL SENIORITY RULES
-- Rule 1: Higher Grade is senior.
-- Rule 2: Earlier promotion date inside grade is senior.
-- Rule 3-4: Same promotion date -> Check previous promotion dates grade-by-grade.
-- Rule 5: Same promotion history -> Compare Date of Joining (DOJ).
-- Rule 6: Same DOJ -> Compare Date of Birth (DOB) (Older is senior).
-- Rule 7: Everything identical -> Deterministic tie-breaker: Employee ID.

-- 9. SEED EMPLOYEES & PROMOTION HISTORY TO TEST ALL SENIORITY RULES
-- Seed Employees (Current Profiles)
INSERT INTO MST_EMPLOYEES VALUES (
    '103225', 'Rajesh Kumar Sharma', 'Grade 9', 'Level 2', 
    TO_DATE('2025-07-01', 'YYYY-MM-DD'), TO_DATE('1995-07-01', 'YYYY-MM-DD'), TO_DATE('1970-04-12', 'YYYY-MM-DD'), 
    'LCA Division', 'Additional General Manager', 17
);

INSERT INTO MST_EMPLOYEES VALUES (
    '103499', 'M. Visvesvaraya', 'Grade 10', 'Level 3', 
    TO_DATE('2025-07-01', 'YYYY-MM-DD'), TO_DATE('1992-06-01', 'YYYY-MM-DD'), TO_DATE('1967-11-20', 'YYYY-MM-DD'), 
    'Overhaul Division', 'General Manager', 17
);

INSERT INTO MST_EMPLOYEES VALUES (
    '104725', 'Sunil Dev', 'Grade 7', 'Level 1', 
    TO_DATE('2024-07-01', 'YYYY-MM-DD'), TO_DATE('2005-01-01', 'YYYY-MM-DD'), TO_DATE('1980-08-15', 'YYYY-MM-DD'), 
    'Services Dept', 'Chief Manager', 17
);

INSERT INTO MST_EMPLOYEES VALUES (
    '120016', 'Anil K. V.', 'Grade 4', 'Level 1', 
    TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2012-12-14', 'YYYY-MM-DD'), TO_DATE('1992-05-05', 'YYYY-MM-DD'), 
    'Jet Engine Overhaul', 'Highly Skilled Technician', 17
);

INSERT INTO MST_EMPLOYEES VALUES (
    '120018', 'Balaji Prasad', 'Grade 4', 'Level 1', 
    TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2012-12-17', 'YYYY-MM-DD'), TO_DATE('1991-03-14', 'YYYY-MM-DD'), 
    'Jet Engine Overhaul', 'Highly Skilled Technician', 17
);

INSERT INTO MST_EMPLOYEES VALUES (
    '120020', 'Chinnaswamy M.', 'Grade 4', 'Level 1', 
    TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2012-12-26', 'YYYY-MM-DD'), TO_DATE('1990-10-10', 'YYYY-MM-DD'), 
    'Jet Engine Overhaul', 'Highly Skilled Technician', 17
);

-- Seed Assignment & Promotion History (Multi-row per employee matching the spreadsheet)
-- Employee 103225 (DGM -> AGM)
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '103225', 'Grade 8', TO_DATE('2015-07-01', 'YYYY-MM-DD'), 
    'ORD-2015-DGM', 17, 'DGM-SH-LCA', TO_DATE('2022-09-01', 'YYYY-MM-DD'), TO_DATE('2022-12-30', 'YYYY-MM-DD'), 0, 'TRANSFER'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '103225', 'Grade 8', TO_DATE('2015-07-01', 'YYYY-MM-DD'), 
    'ORD-2024-DGM-ROT', 17, 'DGM(MS)-IT', TO_DATE('2024-05-24', 'YYYY-MM-DD'), TO_DATE('2025-06-30', 'YYYY-MM-DD'), 0, 'JOB ROTATION'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '103225', 'Grade 9', TO_DATE('2025-07-01', 'YYYY-MM-DD'), 
    'ORD-2025-AGM', 17, 'AGM-MSITPM', TO_DATE('2025-07-22', 'YYYY-MM-DD'), TO_DATE('2026-08-31', 'YYYY-MM-DD'), 1, 'ADDITIONAL RESPONSIBILITIES'
);

-- Employee 103499 (AGM -> GM)
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '103499', 'Grade 9', TO_DATE('2020-07-01', 'YYYY-MM-DD'), 
    'ORD-2020-AGM', 17, 'AGM-D', TO_DATE('2024-05-21', 'YYYY-MM-DD'), TO_DATE('2026-06-30', 'YYYY-MM-DD'), 0, 'TRANSFER'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '103499', 'Grade 10', TO_DATE('2025-07-01', 'YYYY-MM-DD'), 
    'ORD-2025-GM', 17, 'GM(O)', TO_DATE('2025-11-01', 'YYYY-MM-DD'), TO_DATE('2030-12-31', 'YYYY-MM-DD'), 1, 'JOB ROTATION'
);

-- Employee 104725 (Manager -> SM -> CM)
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '104725', 'Grade 5', TO_DATE('2013-07-01', 'YYYY-MM-DD'), 
    'ORD-2013-M', 17, 'M-S-HK', TO_DATE('2018-05-03', 'YYYY-MM-DD'), TO_DATE('2019-06-30', 'YYYY-MM-DD'), 0, 'TRANSFER'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '104725', 'Grade 6', TO_DATE('2019-07-01', 'YYYY-MM-DD'), 
    'ORD-2019-SM', 17, 'SM-S-HK', TO_DATE('2019-07-01', 'YYYY-MM-DD'), TO_DATE('2024-06-30', 'YYYY-MM-DD'), 0, 'DPC'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '104725', 'Grade 7', TO_DATE('2024-07-01', 'YYYY-MM-DD'), 
    'ORD-2024-CM', 17, 'CM-S-HK', TO_DATE('2024-07-01', 'YYYY-MM-DD'), TO_DATE('2039-02-28', 'YYYY-MM-DD'), 1, 'DPC'
);

-- Employee 120016 (Trainee -> Technician -> ST -> HST)
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '120016', 'Grade 1', TO_DATE('2012-12-14', 'YYYY-MM-DD'), 
    'ORD-2012-TT', 17, 'TT-D3', TO_DATE('2012-12-14', 'YYYY-MM-DD'), TO_DATE('2013-12-13', 'YYYY-MM-DD'), 0, 'TRAINEE'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '120016', 'Grade 2', TO_DATE('2012-12-14', 'YYYY-MM-DD'), 
    'ORD-2013-T', 17, 'T(F)-D3', TO_DATE('2013-12-14', 'YYYY-MM-DD'), TO_DATE('2015-03-05', 'YYYY-MM-DD'), 0, 'ABSORPTION'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '120016', 'Grade 3', TO_DATE('2017-01-01', 'YYYY-MM-DD'), 
    'ORD-2017-ST', 17, 'ST(F)-D3', TO_DATE('2017-01-01', 'YYYY-MM-DD'), TO_DATE('2020-01-13', 'YYYY-MM-DD'), 0, 'CPS'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '120016', 'Grade 4', TO_DATE('2023-01-01', 'YYYY-MM-DD'), 
    'ORD-2023-HST', 17, 'HST(F)-J', TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2045-02-28', 'YYYY-MM-DD'), 1, 'CPS'
);

-- Employee 120018 (Trainee -> Technician -> ST -> HST)
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '120018', 'Grade 1', TO_DATE('2012-12-17', 'YYYY-MM-DD'), 
    'ORD-2012-TT', 17, 'TT-D3', TO_DATE('2012-12-17', 'YYYY-MM-DD'), TO_DATE('2013-12-16', 'YYYY-MM-DD'), 0, 'TRAINEE'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '120018', 'Grade 2', TO_DATE('2012-12-17', 'YYYY-MM-DD'), 
    'ORD-2013-T', 17, 'T(F)-D3', TO_DATE('2013-12-17', 'YYYY-MM-DD'), TO_DATE('2015-03-05', 'YYYY-MM-DD'), 0, 'ABSORPTION'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '120018', 'Grade 3', TO_DATE('2017-01-01', 'YYYY-MM-DD'), 
    'ORD-2017-ST', 17, 'ST(F)-D3', TO_DATE('2017-01-01', 'YYYY-MM-DD'), TO_DATE('2020-01-13', 'YYYY-MM-DD'), 0, 'CPS'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '120018', 'Grade 4', TO_DATE('2023-01-01', 'YYYY-MM-DD'), 
    'ORD-2023-HST', 17, 'HST(F)-J', TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2048-08-31', 'YYYY-MM-DD'), 1, 'CPS'
);

-- Employee 120020 (Trainee -> Technician -> ST -> HST)
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '120020', 'Grade 1', TO_DATE('2012-12-26', 'YYYY-MM-DD'), 
    'ORD-2012-TT', 17, 'TT-D3', TO_DATE('2012-12-26', 'YYYY-MM-DD'), TO_DATE('2013-12-25', 'YYYY-MM-DD'), 0, 'TRAINEE'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '120020', 'Grade 2', TO_DATE('2012-12-26', 'YYYY-MM-DD'), 
    'ORD-2013-T', 17, 'T(F)-D3', TO_DATE('2013-12-26', 'YYYY-MM-DD'), TO_DATE('2015-03-05', 'YYYY-MM-DD'), 0, 'ABSORPTION'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '120020', 'Grade 3', TO_DATE('2017-01-01', 'YYYY-MM-DD'), 
    'ORD-2017-ST', 17, 'ST(F)-D3', TO_DATE('2017-01-01', 'YYYY-MM-DD'), TO_DATE('2020-01-13', 'YYYY-MM-DD'), 0, 'CPS'
);
INSERT INTO TRN_PROMOTIONS VALUES (
    SEQ_PROMOTIONS.NEXTVAL, '120020', 'Grade 4', TO_DATE('2023-01-01', 'YYYY-MM-DD'), 
    'ORD-2023-HST', 17, 'HST(F)-J', TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2044-06-30', 'YYYY-MM-DD'), 1, 'CPS'
);

COMMIT;

