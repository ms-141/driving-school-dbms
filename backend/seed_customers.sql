-- Data population script for Requirement 5
-- Populates one main table: customers (10 records)
-- Safe to re-run using ON CONFLICT

-- Make sure status lookup values exist
insert into public.ref_customer_status (customer_status_code, customer_status_description)
values
  ('GOOD', 'Good standing'),
  ('BAD', 'Needs attention')
on conflict (customer_status_code)
do update set customer_status_description = excluded.customer_status_description;

-- Seed customers table with 10 rows
insert into public.customers (
  customer_id,
  customer_address_id,
  customer_status_code,
  date_became_customer,
  date_of_birth,
  first_name,
  last_name,
  amount_outstanding,
  email_address,
  phone_number,
  cell_mobile_phone_number,
  other_customer_details
)
values
  (101, null, 'GOOD', '2026-01-05', '2001-03-14', 'Ava', 'Nguyen', 0.00, 'ava.nguyen@example.com', '604-555-0101', '604-555-1101', 'Seed script row'),
  (102, null, 'GOOD', '2026-01-10', '1999-08-21', 'Liam', 'Patel', 35.50, 'liam.patel@example.com', '604-555-0102', '604-555-1102', 'Seed script row'),
  (103, null, 'BAD',  '2026-01-15', '2000-11-02', 'Mia', 'Lopez', 120.00, 'mia.lopez@example.com', '604-555-0103', '604-555-1103', 'Seed script row'),
  (104, null, 'GOOD', '2026-01-20', '2002-05-09', 'Noah', 'Kim', 0.00, 'noah.kim@example.com', '604-555-0104', '604-555-1104', 'Seed script row'),
  (105, null, 'GOOD', '2026-01-27', '1998-12-30', 'Emma', 'Singh', 18.75, 'emma.singh@example.com', '604-555-0105', '604-555-1105', 'Seed script row'),
  (106, null, 'BAD',  '2026-02-02', '2003-04-11', 'Lucas', 'Chen', 210.00, 'lucas.chen@example.com', '604-555-0106', '604-555-1106', 'Seed script row'),
  (107, null, 'GOOD', '2026-02-09', '2001-09-17', 'Sophia', 'Brown', 0.00, 'sophia.brown@example.com', '604-555-0107', '604-555-1107', 'Seed script row'),
  (108, null, 'GOOD', '2026-02-15', '2000-01-22', 'Ethan', 'Wong', 42.00, 'ethan.wong@example.com', '604-555-0108', '604-555-1108', 'Seed script row'),
  (109, null, 'BAD',  '2026-02-20', '1997-06-06', 'Olivia', 'Garcia', 95.00, 'olivia.garcia@example.com', '604-555-0109', '604-555-1109', 'Seed script row'),
  (110, null, 'GOOD', '2026-02-28', '2002-10-25', 'James', 'Davis', 0.00, 'james.davis@example.com', '604-555-0110', '604-555-1110', 'Seed script row')
on conflict (customer_id)
do update set
  customer_address_id = excluded.customer_address_id,
  customer_status_code = excluded.customer_status_code,
  date_became_customer = excluded.date_became_customer,
  date_of_birth = excluded.date_of_birth,
  first_name = excluded.first_name,
  last_name = excluded.last_name,
  amount_outstanding = excluded.amount_outstanding,
  email_address = excluded.email_address,
  phone_number = excluded.phone_number,
  cell_mobile_phone_number = excluded.cell_mobile_phone_number,
  other_customer_details = excluded.other_customer_details;

-- Quick check
select customer_id, first_name, last_name, customer_status_code, amount_outstanding
from public.customers
where customer_id between 101 and 110
order by customer_id;
