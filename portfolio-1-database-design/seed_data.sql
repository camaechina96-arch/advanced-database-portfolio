-- ============================================================
-- MIT 8103 Advanced Database Systems
-- Portfolio 1: Database Design and Modelling
-- Case Study: University Library Management System
-- File: seed_data.sql
-- Description: Inserts realistic test data into the library DB
-- Author: Charles Amaechina
-- Date: 2026-10-05
-- ============================================================

-- ============================================================
-- Insert Authors (8 rows)
-- ============================================================
INSERT INTO Authors (first_name, last_name, nationality, birth_year) VALUES
('Abraham', 'Silberschatz', 'American', 1947),
('Ramez', 'Elmasri', 'Egyptian-American', 1950),
('Shamkant', 'Navathe', 'Indian-American', 1950),
('Thomas', 'Connolly', 'British', 1952),
('Carolyn', 'Beggs', 'British', 1955),
('Martin', 'Kleppmann', 'German', 1982),
('Hector', 'Garcia-Molina', 'Mexican-American', 1954),
('Jennifer', 'Widom', 'American', 1960);

-- ============================================================
-- Insert Members (10 rows)
-- ============================================================
INSERT INTO Members (first_name, last_name, email, phone, status) VALUES
('Charles', 'Amaechina', 'charles@example.com', '+2348012345678', 'Active'),
('Ada', 'Okafor', 'ada.okafor@example.com', '+2348023456789', 'Active'),
('John', 'Smith', 'john.smith@example.com', '+1234567890', 'Active'),
('Mary', 'Johnson', 'mary.johnson@example.com', '+1234567891', 'Active'),
('Ahmed', 'Hassan', 'ahmed.hassan@example.com', '+201234567890', 'Active'),
('Fatima', 'Ali', 'fatima.ali@example.com', '+201234567891', 'Suspended'),
('David', 'Kimani', 'david.kimani@example.com', '+254701234567', 'Active'),
('Grace', 'Mwangi', 'grace.mwangi@example.com', '+254701234568', 'Active'),
('Peter', 'Obi', 'peter.obi@example.com', '+2348034567890', 'Expired'),
('Sarah', 'Williams', 'sarah.williams@example.com', '+1234567892', 'Active');

-- ============================================================
-- Insert Books (10 rows)
-- ============================================================
INSERT INTO Books (title, isbn, publication_year, author_id, category, total_copies, available_copies) VALUES
('Database System Concepts', '978-0078022159', 2019, 1, 'Database', 5, 5),
('Fundamentals of Database Systems', '978-0133970777', 2015, 2, 'Database', 3, 3),
('Database Systems: The Complete Book', '978-0131873254', 2008, 7, 'Database', 4, 4),
('Database Systems: A Practical Approach', '978-1447938937', 2014, 4, 'Database', 2, 2),
('Designing Data-Intensive Applications', '978-1449373320', 2017, 6, 'Distributed Systems', 6, 6),
('NoSQL Distilled', '978-0321826268', 2012, 7, 'NoSQL', 3, 3),
('Modern Database Management', '978-0133544619', 2015, 5, 'Database', 4, 4),
('SQL Performance Explained', '978-3950307825', 2012, 6, 'Database', 2, 2),
('MongoDB: The Definitive Guide', '978-1491954461', 2019, 6, 'NoSQL', 5, 5),
('Introduction to Algorithms', '978-0262046305', 2022, 3, 'Algorithms', 8, 8);

-- ============================================================
-- Insert Loans (12 rows)
-- ============================================================
INSERT INTO Loans (book_id, member_id, loan_date, due_date, return_date, status) VALUES
(1, 1, '2026-09-01', '2026-09-15', '2026-09-12', 'Returned'),
(2, 2, '2026-09-05', '2026-09-19', '2026-09-18', 'Returned'),
(3, 3, '2026-09-10', '2026-09-24', NULL, 'Overdue'),
(4, 4, '2026-09-12', '2026-09-26', NULL, 'Active'),
(5, 5, '2026-09-15', '2026-09-29', '2026-09-28', 'Returned'),
(6, 6, '2026-09-18', '2026-10-02', NULL, 'Overdue'),
(7, 7, '2026-09-20', '2026-10-04', NULL, 'Active'),
(8, 8, '2026-09-22', '2026-10-06', NULL, 'Active'),
(9, 9, '2026-09-25', '2026-10-09', NULL, 'Active'),
(10, 10, '2026-09-28', '2026-10-12', NULL, 'Active'),
(1, 2, '2026-09-30', '2026-10-14', NULL, 'Active'),
(2, 3, '2026-10-01', '2026-10-15', NULL, 'Active');

-- ============================================================
-- Insert Fines (3 rows)
-- ============================================================
INSERT INTO Fines (loan_id, member_id, amount, reason, paid_status) VALUES
(3, 3, 5.00, 'Late return - 5 days overdue', 'Unpaid'),
(6, 6, 7.50, 'Late return - 7 days overdue', 'Unpaid'),
(1, 1, 0.00, 'No fine - returned on time', 'Paid');

-- ============================================================
-- Insert Reviews (8 rows)
-- ============================================================
INSERT INTO Reviews (book_id, member_id, rating, comment) VALUES
(1, 1, 5, 'Excellent textbook for database fundamentals. Highly recommended.'),
(2, 2, 4, 'Good book but slightly outdated examples.'),
(3, 3, 5, 'Comprehensive coverage of database theory.'),
(5, 4, 5, 'Essential reading for distributed systems engineers.'),
(6, 5, 4, 'Good introduction to NoSQL concepts.'),
(9, 7, 5, 'Best MongoDB reference available.'),
(10, 8, 5, 'Classic algorithm textbook, updated edition.'),
(5, 1, 5, 'Changed the way I think about data systems.');

-- ============================================================
-- End of seed_data.sql
-- ============================================================