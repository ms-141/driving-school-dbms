-- Data population script for Requirement 5
-- Populates customers (11 records), staff (5 records), vehicles (5 records), and lessons (10 records)
-- Safe to re-run using ON CONFLICT

-- Make sure status lookup values exist
insert into public.ref_customer_status (customer_status_code, customer_status_description)
values
  ('GOOD', 'Good standing'),
  ('BAD', 'Needs attention')
on conflict (customer_status_code)
do update set customer_status_description = excluded.customer_status_description;

-- Seed customers table with 11 rows
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
OVERRIDING SYSTEM VALUE
values
  (101, null, 'GOOD', '2026-01-05', '2001-03-14', 'Ava', 'Nguyen', 370.00, 'ava.nguyen@example.com', '604-555-0101', '604-555-1101', 'Seed script row'),
  (102, null, 'GOOD', '2026-01-10', '1999-08-21', 'Liam', 'Patel', 305.50, 'liam.patel@example.com', '604-555-0102', '604-555-1102', 'Seed script row'),
  (103, null, 'BAD',  '2026-01-15', '2000-11-02', 'Mia', 'Lopez', 480.00, 'mia.lopez@example.com', '604-555-0103', '604-555-1103', 'Seed script row'),
  (104, null, 'GOOD', '2026-01-20', '2002-05-09', 'Noah', 'Kim', 320.00, 'noah.kim@example.com', '604-555-0104', '604-555-1104', 'Seed script row'),
  (105, null, 'GOOD', '2026-01-27', '1998-12-30', 'Emma', 'Singh', 408.75, 'emma.singh@example.com', '604-555-0105', '604-555-1105', 'Seed script row'),
  (106, null, 'BAD',  '2026-02-02', '2003-04-11', 'Lucas', 'Chen', 520.00, 'lucas.chen@example.com', '604-555-0106', '604-555-1106', 'Seed script row'),
  (107, null, 'GOOD', '2026-02-09', '2001-09-17', 'Sophia', 'Brown', 410.00, 'sophia.brown@example.com', '604-555-0107', '604-555-1107', 'Seed script row'),
  (108, null, 'GOOD', '2026-02-15', '2000-01-22', 'Ethan', 'Wong', 372.00, 'ethan.wong@example.com', '604-555-0108', '604-555-1108', 'Seed script row'),
  (109, null, 'BAD',  '2026-02-20', '1997-06-06', 'Olivia', 'Garcia', 445.00, 'olivia.garcia@example.com', '604-555-0109', '604-555-1109', 'Seed script row'),
  (110, null, 'GOOD', '2026-02-28', '2002-10-25', 'James', 'Davis', 310.00, 'james.davis@example.com', '604-555-0110', '604-555-1110', 'Seed script row'),
  (111, null, 'GOOD', '2026-06-12', '2001-07-19', 'Sahib', 'Singh', 0.00, 'ssing791@mtroyal.ca', 'hello this', '604-555-1111', 'Recently added customer')
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

-- Make sure lesson status lookup values exist
insert into public.ref_lesson_status (lesson_status_code, lesson_status_description)
values
  ('SCH', 'Scheduled'),
  ('COMP', 'Completed'),
  ('CANC', 'Cancelled'),
  ('NOSH', 'No-show')
on conflict (lesson_status_code)
do update set lesson_status_description = excluded.lesson_status_description;

-- Instructor and vehicle rows for lesson foreign keys
insert into public.staff (staff_id, first_name, last_name)
OVERRIDING SYSTEM VALUE
values
  (1, 'Alex', 'Rivera'),
  (2, 'Jordan', 'Chen'),
  (3, 'Marcus', 'Thompson'),
  (4, 'Priya', 'Singh'),
  (5, 'Sarah', 'Kim')
on conflict (staff_id)
do update set
  first_name = excluded.first_name,
  last_name = excluded.last_name;

insert into public.vehicles (vehicle_id, vehicle_details)
OVERRIDING SYSTEM VALUE
values
  (1, 'Honda Civic - Auto'),
  (2, 'Toyota Corolla - Manual'),
  (3, 'Ford F-150 - Auto'),
  (4, 'Chevrolet Camaro - Manual'),
  (5, 'Nissan Skyline R34 GT-R - Manual')
on conflict (vehicle_id)
do update set vehicle_details = excluded.vehicle_details;

-- Seed lessons table with 10 records (mix of past and future dates, all vehicles and instructors)
insert into public.lessons (
  lesson_id,
  customer_id,
  lesson_status_code,
  vehicle_id,
  staff_id,
  lesson_date,
  lesson_time,
  price,
  other_lesson_details
)
OVERRIDING SYSTEM VALUE
values
  (201, 101, 'SCH',  1, 1, '2026-07-03', '09:00', 65.00, 'City driving practice'),
  (202, 102, 'COMP', 2, 3, '2026-05-15', '10:00', 70.00, 'Completed highway session'),
  (203, 103, 'SCH',  3, 2, '2026-07-18', '11:00', 85.00, 'Parking focus with F-150'),
  (204, 104, 'CANC', 4, 4, '2026-05-20', '13:00', 95.00, 'Cancelled by student'),
  (205, 105, 'COMP', 1, 5, '2026-05-22', '14:00', 75.00, 'Completed defensive driving'),
  (206, 106, 'NOSH', 2, 2, '2026-06-01', '15:00', 70.00, 'No-show'),
  (207, 107, 'SCH',  5, 3, '2026-07-25', '09:30', 120.00, 'Special R34 Skyline session'),
  (208, 108, 'SCH',  4, 4, '2026-08-02', '10:30', 95.00, 'Manual Camaro clutch practice'),
  (209, 109, 'COMP', 1, 1, '2026-06-05', '12:00', 80.00, 'Road test prep'),
  (210, 110, 'SCH',  3, 5, '2026-08-10', '16:00', 85.00, 'Evening F-150 session')
on conflict (lesson_id)
do update set
  customer_id = excluded.customer_id,
  lesson_status_code = excluded.lesson_status_code,
  vehicle_id = excluded.vehicle_id,
  staff_id = excluded.staff_id,
  lesson_date = excluded.lesson_date,
  lesson_time = excluded.lesson_time,
  price = excluded.price,
  other_lesson_details = excluded.other_lesson_details;

-- Quick checks
select customer_id, first_name, last_name, customer_status_code, amount_outstanding
from public.customers
where customer_id between 101 and 111
order by customer_id;

select lesson_id, customer_id, staff_id, vehicle_id, lesson_status_code, lesson_date, lesson_time, price
from public.lessons
where lesson_id between 201 and 210
order by lesson_id;
