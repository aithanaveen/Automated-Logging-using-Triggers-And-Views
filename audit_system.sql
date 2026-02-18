CREATE DATABASE audit_system;
USE audit_system;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    department VARCHAR(100),
    salary DECIMAL(10,2),
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE employee_audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    action_type VARCHAR(20),
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER after_employee_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit_log
    (emp_id, action_type, old_salary, new_salary)
    VALUES
    (NEW.emp_id, 'INSERT', NULL, NEW.salary);
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_employee_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit_log
    (emp_id, action_type, old_salary, new_salary)
    VALUES
    (NEW.emp_id, 'UPDATE', OLD.salary, NEW.salary);
END //

DELIMITER ;

INSERT INTO employees (name, department, salary)
VALUES ('Naveen', 'IT', 30000);

UPDATE employees
SET salary = 35000
WHERE emp_id = 1;

SELECT * FROM employee_audit_log;

CREATE VIEW daily_activity_report AS
SELECT 
    DATE(changed_at) AS activity_date,
    action_type,
    COUNT(*) AS total_actions
FROM employee_audit_log
GROUP BY DATE(changed_at), action_type;

SELECT * FROM daily_activity_report;
