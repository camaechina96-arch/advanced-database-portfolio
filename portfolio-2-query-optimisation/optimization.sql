-- ============================================================
-- MIT 8103 Advanced Database Systems
-- Portfolio 2: Query Processing and Optimisation
-- File: optimization.sql
-- Description: Before/After index comparison for performance
-- Author: Charles Amaechina
-- Date: 2026-10-05
-- ============================================================

-- ============================================================
-- OPTIMISATION 1: Overdue loans query
-- Purpose: Compare Sequential Scan vs Index Scan
-- ============================================================

-- Step 1: Baseline WITHOUT index
DROP INDEX IF EXISTS idx_loans_status;

EXPLAIN ANALYZE
SELECT 
    l.loan_id,
    m.first_name || ' ' || m.last_name AS member_name,
    b.title AS book_title,
    l.due_date,
    CURRENT_DATE - l.due_date AS days_overdue
FROM Loans l
INNER JOIN Members m ON l.member_id = m.member_id
INNER JOIN Books b ON l.book_id = b.book_id
WHERE l.status = 'Overdue';

-- Step 2: Create the index
CREATE INDEX idx_loans_status ON Loans(status);

-- Step 3: Re-run WITH index
EXPLAIN ANALYZE
SELECT 
    l.loan_id,
    m.first_name || ' ' || m.last_name AS member_name,
    b.title AS book_title,
    l.due_date,
    CURRENT_DATE - l.due_date AS days_overdue
FROM Loans l
INNER JOIN Members m ON l.member_id = m.member_id
INNER JOIN Books b ON l.book_id = b.book_id
WHERE l.status = 'Overdue';

-- ============================================================
-- OPTIMISATION 2: Find books by author
-- ============================================================

DROP INDEX IF EXISTS idx_books_author_id;

EXPLAIN ANALYZE
SELECT b.book_id, b.title, b.category
FROM Books b
WHERE b.author_id = 6;

CREATE INDEX idx_books_author_id ON Books(author_id);

EXPLAIN ANALYZE
SELECT b.book_id, b.title, b.category
FROM Books b
WHERE b.author_id = 6;

-- ============================================================
-- OPTIMISATION 3: Book reviews lookup
-- ============================================================

DROP INDEX IF EXISTS idx_reviews_book_id;

EXPLAIN ANALYZE
SELECT r.review_id, r.rating, r.comment
FROM Reviews r
WHERE r.book_id = 5;

CREATE INDEX idx_reviews_book_id ON Reviews(book_id);

EXPLAIN ANALYZE
SELECT r.review_id, r.rating, r.comment
FROM Reviews r
WHERE r.book_id = 5;

-- ============================================================
-- End of optimization.sql
-- ============================================================