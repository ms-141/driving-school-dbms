-- NOTE: this is to generate reports located at the bottom of the fronttend interface



-- Report 1: Customers with No-Shows
-- Shows which customers have no-show history (payment, last date missed) and how many times
CREATE OR REPLACE VIEW vw_customers_noshows AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email_address,
    c.phone_number,
    cs.customer_status_description,
    COUNT(l.lesson_id) AS total_noshow_count,
    SUM(l.price) AS total_noshow_fees,
    MAX(l.lesson_date) AS last_noshow_date
FROM customers c
JOIN ref_customer_status cs ON c.customer_status_code = cs.customer_status_code
JOIN lessons l ON c.customer_id = l.customer_id
WHERE l.lesson_status_code = 'NOSH'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email_address, c.phone_number, cs.customer_status_description
ORDER BY total_noshow_count DESC;

-- Report 2: Revenue by Instructor
-- total revenue and lesson statistics per instructor
CREATE OR REPLACE VIEW vw_instructor_revenue AS
SELECT 
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS instructor_name,
    COUNT(l.lesson_id) AS total_lessons,
    SUM(CASE WHEN l.lesson_status_code = 'COMP' THEN 1 ELSE 0 END) AS completed_lessons,
    SUM(CASE WHEN l.lesson_status_code = 'CANC' THEN 1 ELSE 0 END) AS cancelled_lessons,
    SUM(CASE WHEN l.lesson_status_code = 'NOSH' THEN 1 ELSE 0 END) AS noshow_lessons,
    COALESCE(SUM(CASE WHEN l.lesson_status_code = 'COMP' THEN l.price ELSE 0 END), 0) AS total_revenue,
    ROUND(AVG(l.price), 2) AS avg_lesson_price
FROM staff s
LEFT JOIN lessons l ON s.staff_id = l.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name
ORDER BY total_revenue DESC;

-- Report 3: Completion Rate by Customer Status
-- For completion rates for GOOD vs BAD status customers
CREATE OR REPLACE VIEW vw_completion_rate_by_status AS
SELECT 
    cs.customer_status_description AS customer_status,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(l.lesson_id) AS total_lessons,
    SUM(CASE WHEN l.lesson_status_code = 'COMP' THEN 1 ELSE 0 END) AS completed_lessons,
    SUM(CASE WHEN l.lesson_status_code = 'NOSH' THEN 1 ELSE 0 END) AS noshow_lessons,
    SUM(CASE WHEN l.lesson_status_code = 'CANC' THEN 1 ELSE 0 END) AS cancelled_lessons,
    ROUND(
        CASE 
            WHEN COUNT(l.lesson_id) > 0 
            THEN (SUM(CASE WHEN l.lesson_status_code = 'COMP' THEN 1 ELSE 0 END)::NUMERIC / COUNT(l.lesson_id)::NUMERIC) * 100 
            ELSE 0 
        END, 
        2
    ) AS completion_rate_percent
FROM ref_customer_status cs
LEFT JOIN customers c ON cs.customer_status_code = c.customer_status_code
LEFT JOIN lessons l ON c.customer_id = l.customer_id
GROUP BY cs.customer_status_code, cs.customer_status_description
ORDER BY completion_rate_percent DESC;
