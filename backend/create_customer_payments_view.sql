-- View to display customer payment transactions with customer details
DROP VIEW IF EXISTS vw_customer_payments
CASCADE;

CREATE OR REPLACE VIEW vw_customer_payments AS
SELECT
    cp.payment_id,
    cp.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    cp.datetime_payment,
    cp.payment_method_code,
    rpm.payment_method_description,
    cp.amount_payment,
    cp.other_payment_details
FROM
    customer_payments cp
    INNER JOIN customers c ON cp.customer_id = c.customer_id
    LEFT JOIN ref_payment_methods rpm ON cp.payment_method_code = rpm.payment_method_code
ORDER BY 
    cp.datetime_payment DESC;

-- Grant SELECT permissions
GRANT SELECT ON vw_customer_payments TO anon, authenticated;
