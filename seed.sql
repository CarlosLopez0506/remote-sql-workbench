-- =============================================================
-- Remote SQL Architect and Explorer
-- Phase A: Seed Data (DML)
-- 10+ rows per table — realistic fintech mock data
-- =============================================================

-- -------------------------------------------------------------
-- users (12 rows)
-- -------------------------------------------------------------
INSERT INTO users (email, full_name, phone, created_at) VALUES
    ('alice.morgan@email.com',    'Alice Morgan',    '+1-555-0101', '2023-01-15 09:00:00'),
    ('bob.hayes@email.com',       'Bob Hayes',       '+1-555-0102', '2023-02-03 10:30:00'),
    ('carlos.vega@email.com',     'Carlos Vega',     '+52-55-1234', '2023-02-20 14:15:00'),
    ('diana.wu@email.com',        'Diana Wu',        '+1-555-0104', '2023-03-08 08:45:00'),
    ('ethan.cole@email.com',      'Ethan Cole',      '+1-555-0105', '2023-04-01 11:00:00'),
    ('fatima.ali@email.com',      'Fatima Ali',      '+1-555-0106', '2023-04-18 13:20:00'),
    ('gabriel.rojas@email.com',   'Gabriel Rojas',   '+52-33-5678', '2023-05-05 09:50:00'),
    ('hannah.schmidt@email.com',  'Hannah Schmidt',  '+1-555-0108', '2023-05-22 16:00:00'),
    ('ivan.petrov@email.com',     'Ivan Petrov',     '+1-555-0109', '2023-06-10 12:30:00'),
    ('julia.santos@email.com',    'Julia Santos',    '+55-11-9900', '2023-07-07 08:00:00'),
    ('kevin.park@email.com',      'Kevin Park',      '+1-555-0111', '2023-08-14 10:10:00'),
    ('laura.nguyen@email.com',    'Laura Nguyen',    '+1-555-0112', '2023-09-01 15:45:00');

-- -------------------------------------------------------------
-- accounts (14 rows — some users have more than one)
-- -------------------------------------------------------------
INSERT INTO accounts (user_id, account_number, account_type, balance, status, opened_at) VALUES
    (1,  'ACC-0001', 'CHECKING',   12450.75, 'ACTIVE',  '2023-01-15 09:05:00'),
    (1,  'ACC-0002', 'SAVINGS',    35000.00, 'ACTIVE',  '2023-01-15 09:10:00'),
    (2,  'ACC-0003', 'CHECKING',    8200.50, 'ACTIVE',  '2023-02-03 10:35:00'),
    (3,  'ACC-0004', 'SAVINGS',    22000.00, 'ACTIVE',  '2023-02-20 14:20:00'),
    (3,  'ACC-0005', 'INVESTMENT', 75000.00, 'ACTIVE',  '2023-02-20 14:25:00'),
    (4,  'ACC-0006', 'CHECKING',    5500.00, 'ACTIVE',  '2023-03-08 08:50:00'),
    (5,  'ACC-0007', 'SAVINGS',    18750.25, 'ACTIVE',  '2023-04-01 11:05:00'),
    (6,  'ACC-0008', 'CHECKING',    3200.00, 'FROZEN',  '2023-04-18 13:25:00'),
    (7,  'ACC-0009', 'CHECKING',    9800.80, 'ACTIVE',  '2023-05-05 09:55:00'),
    (8,  'ACC-0010', 'INVESTMENT', 120000.00,'ACTIVE',  '2023-05-22 16:05:00'),
    (9,  'ACC-0011', 'SAVINGS',    45500.00, 'ACTIVE',  '2023-06-10 12:35:00'),
    (10, 'ACC-0012', 'CHECKING',    6700.00, 'ACTIVE',  '2023-07-07 08:05:00'),
    (11, 'ACC-0013', 'CHECKING',   11200.30, 'ACTIVE',  '2023-08-14 10:15:00'),
    (12, 'ACC-0014', 'SAVINGS',    28900.00, 'CLOSED',  '2023-09-01 15:50:00');

-- -------------------------------------------------------------
-- transactions (20 rows)
-- -------------------------------------------------------------
INSERT INTO transactions (account_id, amount, type, description, status, created_at) VALUES
    (1,   500.00, 'DEBIT',  'Grocery store purchase',          'COMPLETED', '2024-01-05 10:00:00'),
    (1,  3000.00, 'CREDIT', 'Salary deposit January',          'COMPLETED', '2024-01-31 08:00:00'),
    (2,  1200.00, 'CREDIT', 'Transfer from checking ACC-0001', 'COMPLETED', '2024-02-01 09:00:00'),
    (3,   250.50, 'DEBIT',  'Online subscription',             'COMPLETED', '2024-02-10 14:30:00'),
    (3,  2800.00, 'CREDIT', 'Salary deposit February',         'COMPLETED', '2024-02-28 08:00:00'),
    (4,   800.00, 'DEBIT',  'Utility bill payment',            'COMPLETED', '2024-03-02 11:00:00'),
    (5, 15000.00, 'CREDIT', 'Investment return Q1',            'COMPLETED', '2024-03-31 16:00:00'),
    (6,  1500.00, 'DEBIT',  'Rent payment March',              'COMPLETED', '2024-03-05 08:30:00'),
    (7,  3500.00, 'CREDIT', 'Freelance payment',               'COMPLETED', '2024-03-15 10:00:00'),
    (8,   120.00, 'DEBIT',  'ATM withdrawal',                  'FAILED',    '2024-03-20 09:00:00'),
    (9,   450.00, 'DEBIT',  'Restaurant payment',              'COMPLETED', '2024-04-01 20:00:00'),
    (9,  2500.00, 'CREDIT', 'Salary deposit April',            'COMPLETED', '2024-04-30 08:00:00'),
    (10,50000.00, 'CREDIT', 'Stock dividend payout',           'COMPLETED', '2024-04-15 12:00:00'),
    (11, 2000.00, 'DEBIT',  'International wire transfer',     'COMPLETED', '2024-05-03 11:00:00'),
    (11,10000.00, 'CREDIT', 'Bonus deposit',                   'COMPLETED', '2024-05-10 09:00:00'),
    (12,  300.00, 'DEBIT',  'Phone bill',                      'COMPLETED', '2024-05-15 08:00:00'),
    (13, 1800.00, 'CREDIT', 'Consulting invoice payment',      'COMPLETED', '2024-06-01 10:00:00'),
    (13,  750.00, 'DEBIT',  'Flight booking',                  'PENDING',   '2024-06-10 14:00:00'),
    (1,  2200.00, 'DEBIT',  'Car insurance annual payment',    'COMPLETED', '2024-06-15 09:00:00'),
    (7,   180.00, 'DEBIT',  'Streaming services bundle',       'COMPLETED', '2024-06-20 19:00:00');
