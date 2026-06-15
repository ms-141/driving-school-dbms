-- Fix for 5 Original Views
-- This file corrects the broken views to work with the actual database schema

-- =============================================================================
-- Drop existing views first (in case they're read-only)
-- =============================================================================
DROP VIEW IF EXISTS vw_upcominglessons
CASCADE;
DROP VIEW IF EXISTS vw_instructorschedule
CASCADE;
DROP VIEW IF EXISTS vw_customerlessonhistory
CASCADE;
DROP VIEW IF EXISTS vw_customerpaymentsummary
CASCADE;
DROP VIEW IF EXISTS vw_customerswithnolessons
CASCADE;

-- =============================================================================
-- 1. vw_UpcomingLessons - Shows future lessons (keeps original date filter)
-- =============================================================================

CREATE OR REPLACE VIEW vw_upcominglessons AS
SELECT
    l.lesson_id,
    l.lesson_date,
    l.lesson_time,
    l.price,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email_address,
    c.phone_number,
    CONCAT(s.first_name, ' ', s.last_name) AS instructor_name,
    v.vehicle_details,
    ls.lesson_status_description
FROM lessons l
    JOIN customers c ON l.customer_id = c.customer_id
    JOIN staff s ON l.staff_id = s.staff_id
    LEFT JOIN vehicles v ON l.vehicle_id = v.vehicle_id
    JOIN ref_lesson_status ls ON l.lesson_status_code = ls.lesson_status_code
WHERE l.lesson_date >= CURRENT_DATE
ORDER BY l.lesson_date, l.lesson_time;

ALTER VIEW vw_upcominglessons
SET
(security_invoker = on);


-- 2. vw_InstructorSchedule - Fixed to handle NULL vehicles

CREATE OR REPLACE VIEW vw_instructorschedule AS
SELECT
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS instructor_name,
    l.lesson_id,
    l.lesson_date,
    l.lesson_time,
    CONCAT(c.first_name, ' ', c.last_name) AS student_name,
    COALESCE(v.vehicle_details, 'No vehicle assigned') AS vehicle_details,
    ls.lesson_status_description AS lesson_status
FROM staff s
    LEFT JOIN lessons l ON s.staff_id = l.staff_id
    LEFT JOIN customers c ON l.customer_id = c.customer_id
    LEFT JOIN vehicles v ON l.vehicle_id = v.vehicle_id
    LEFT JOIN ref_lesson_status ls ON l.lesson_status_code = ls.lesson_status_code
ORDER BY s.staff_id, l.lesson_date, l.lesson_time;

ALTER VIEW vw_instructorschedule
SET
(security_invoker = on);


-- 3. vw_CustomerLessonHistory - Fixed GROUP BY clause

CREATE OR REPLACE VIEW vw_customerlessonhistory AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.date_of_birth,
    c.date_became_customer,
    COALESCE(COUNT(l.lesson_id), 0) AS total_lessons,
    COALESCE(SUM(CASE WHEN ls.lesson_status_code = 'COMP' THEN 1 ELSE 0 END), 0) AS completed_lessons,
    COALESCE(SUM(l.price), 0) AS total_lesson_fees
FROM customers c
    LEFT JOIN lessons l ON c.customer_id = l.customer_id
    LEFT JOIN ref_lesson_status ls ON l.lesson_status_code = ls.lesson_status_code
GROUP BY
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    c.date_of_birth, 
    c.date_became_customer
ORDER BY c.customer_id;

ALTER VIEW vw_customerlessonhistory
SET
(security_invoker = on);


-- 4. vw_CustomerPaymentSummary - Fixed to calculate from lessons table
-- (customer_payments table does not exist in the schema)

CREATE OR REPLACE VIEW vw_customerpaymentsummary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email_address,
    c.amount_outstanding,
    cs.customer_status_description AS customer_status,
    COALESCE(SUM(CASE WHEN l.lesson_status_code = 'COMP' THEN l.price ELSE 0 END), 0) AS total_lesson_fees,
    COALESCE(COUNT(CASE WHEN l.lesson_status_code = 'COMP' THEN 1 END), 0) AS completed_lesson_count
FROM customers c
    JOIN ref_customer_status cs ON c.customer_status_code = cs.customer_status_code
    LEFT JOIN lessons l ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    c.email_address, 
    c.amount_outstanding, 
    cs.customer_status_description
ORDER BY c.customer_id;

ALTER VIEW vw_customerpaymentsummary
SET
(security_invoker = on);


-- 5. vw_CustomersWithNoLessons - Already correct, no changes needed

CREATE OR REPLACE VIEW vw_customerswithnolessons AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email_address,
    c.phone_number,
    c.date_became_customer,
    cs.customer_status_description AS customer_status
FROM customers c
    JOIN ref_customer_status cs ON c.customer_status_code = cs.customer_status_code
    LEFT JOIN lessons l ON c.customer_id = l.customer_id
WHERE l.lesson_id IS NULL
ORDER BY c.date_became_customer;

ALTER VIEW vw_customerswithnolessons
SET
(security_invoker = on);

-- Verification queries (optional - comment out before running)

-- SELECT * FROM vw_upcominglessons;
-- SELECT * FROM vw_instructorschedule;
-- SELECT * FROM vw_customerlessonhistory;
-- SELECT * FROM vw_customerpaymentsummary;
-- SELECT * FROM vw_customerswithnolessons;
