-- ============================================================
-- MIT 8103 Advanced Database Systems
-- Portfolio 2: Query Processing and Optimisation
-- Case Study: University Library Management System
-- File: queries.sql
-- Description: Complex queries demonstrating library operations
-- Author: Charles Amaechina
-- Date: 2026-10-05
-- ============================================================

-- ============================================================
-- QUERY 1: List all books with their author names
-- Demonstrates: INNER JOIN between Books and Authors
-- Business purpose: Librarian searching the catalogue
-- ============================================================
SELECT 
    b.book_id,
    b.title,
    b.category,
    b.publication_year,
    a.first_name || ' ' || a.last_name AS author_name,
    b.available_copies
FROM Books b
INNER JOIN Authors a ON b.author_id = a.author_id
ORDER BY b.title;

-- ============================================================
-- QUERY 2: Find all overdue loans with member and book details
-- Demonstrates: Multiple JOINs, filtering, date arithmetic
-- Business purpose: Generate overdue books report
-- ============================================================
SELECT 
    l.loan_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.email,
    b.title AS book_title,
    l.loan_date,
    l.due_date,
    CURRENT_DATE - l.due_date AS days_overdue
FROM Loans l
INNER JOIN Members m ON l.member_id = m.member_id
INNER JOIN Books b ON l.book_id = b.book_id
WHERE l.status = 'Overdue'
ORDER BY days_overdue DESC;

-- ============================================================
-- QUERY 3: Count loans per member (Top borrowers)
-- Demonstrates: GROUP BY, aggregate functions, ORDER BY
-- Business purpose: Identify the most active library users
-- ============================================================
SELECT 
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    COUNT(l.loan_id) AS total_loans
FROM Members m
LEFT JOIN Loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.first_name, m.last_name
ORDER BY total_loans DESC
LIMIT 5;

-- ============================================================
-- QUERY 4: Books with average rating >= 4.5
-- Demonstrates: Aggregation with HAVING clause
-- Business purpose: Recommend top-rated books
-- ============================================================
SELECT 
    b.book_id,
    b.title,
    AVG(r.rating)::NUMERIC(3,2) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM Books b
INNER JOIN Reviews r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
HAVING AVG(r.rating) >= 4.5
ORDER BY avg_rating DESC;

-- ============================================================
-- QUERY 5: Members with unpaid fines (subquery)
-- Demonstrates: Subquery with IN clause
-- Business purpose: Generate fines collection list
-- ============================================================
SELECT 
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.email,
    m.status
FROM Members m
WHERE m.member_id IN (
    SELECT DISTINCT member_id 
    FROM Fines 
    WHERE paid_status = 'Unpaid'
);

-- ============================================================
-- QUERY 6: Books never borrowed (LEFT JOIN with NULL check)
-- Demonstrates: LEFT JOIN to find non-matching rows
-- Business purpose: Identify underutilised books
-- ============================================================
SELECT 
    b.book_id,
    b.title,
    b.category
FROM Books b
LEFT JOIN Loans l ON b.book_id = l.book_id
WHERE l.loan_id IS NULL;

-- ============================================================
-- QUERY 7: Monthly loan statistics
-- Demonstrates: Date grouping with DATE_TRUNC
-- Business purpose: Trend analysis for library management
-- ============================================================
SELECT 
    DATE_TRUNC('month', loan_date)::DATE AS loan_month,
    COUNT(*) AS total_loans,
    COUNT(DISTINCT member_id) AS unique_members
FROM Loans
GROUP BY DATE_TRUNC('month', loan_date)
ORDER BY loan_month;

-- ============================================================
-- QUERY 8: Author productivity (books published per author)
-- Demonstrates: GROUP BY with JOIN
-- Business purpose: Collection development insight
-- ============================================================
SELECT 
    a.author_id,
    a.first_name || ' ' || a.last_name AS author_name,
    COUNT(b.book_id) AS books_in_library
FROM Authors a
LEFT JOIN Books b ON a.author_id = b.author_id
GROUP BY a.author_id, a.first_name, a.last_name
ORDER BY books_in_library DESC;

-- ============================================================
-- End of queries.sql
-- ============================================================