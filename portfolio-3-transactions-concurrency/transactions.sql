-- ============================================================
-- MIT 8103 Advanced Database Systems
-- Portfolio 3: Transactions and Concurrency
-- Case Study: University Library Management System
-- File: transactions.sql
-- Description: Demonstrates COMMIT, ROLLBACK, SAVEPOINT, and isolation
-- Author: Charles Amaechina
-- Date: 2026-10-05
-- ============================================================

-- ============================================================
-- DEMO 1: Basic COMMIT — successful transaction
-- Business scenario: A librarian adds a new book and commits
-- ============================================================

BEGIN;

INSERT INTO Books (title, isbn, publication_year, author_id, category, total_copies, available_copies)
VALUES ('Transaction Demo Book', '999-9999999999', 2026, 1, 'Database', 1, 1);

-- Verify the row is visible INSIDE the transaction
SELECT book_id, title, isbn FROM Books WHERE isbn = '999-9999999999';

COMMIT;

-- Verify the row is persisted AFTER commit
SELECT book_id, title, isbn FROM Books WHERE isbn = '999-9999999999';

-- ============================================================
-- DEMO 2: ROLLBACK — abort a transaction
-- Business scenario: A librarian makes a mistake and rolls back
-- ============================================================

BEGIN;

INSERT INTO Books (title, isbn, publication_year, author_id, category, total_copies, available_copies)
VALUES ('Should Be Rolled Back', '888-8888888888', 2026, 1, 'Database', 1, 1);

-- Verify the row is visible INSIDE the transaction
SELECT book_id, title, isbn FROM Books WHERE isbn = '888-8888888888';

ROLLBACK;

-- Verify the row is GONE after rollback
SELECT book_id, title, isbn FROM Books WHERE isbn = '888-8888888888';

-- ============================================================
-- DEMO 3: SAVEPOINT — partial rollback
-- Business scenario: A librarian adds 2 books, but only 1 is valid
-- ============================================================

BEGIN;

INSERT INTO Books (title, isbn, publication_year, author_id, category, total_copies, available_copies)
VALUES ('Valid Book 1', '777-7777777777', 2026, 1, 'Database', 1, 1);

SAVEPOINT after_first_book;

INSERT INTO Books (title, isbn, publication_year, author_id, category, total_copies, available_copies)
VALUES ('Invalid Book — will rollback this only', '666-6666666666', 2026, 999, 'Database', 1, 1);
-- This will fail because author_id 999 doesn't exist (FK constraint)

ROLLBACK TO SAVEPOINT after_first_book;

-- Verify only the first book is committed
SELECT book_id, title, isbn FROM Books WHERE isbn IN ('777-7777777777', '666-6666666666');

COMMIT;

-- ============================================================
-- DEMO 4: Isolation Level — READ COMMITTED (PostgreSQL default)
-- Business scenario: Show that a transaction only sees committed data
-- ============================================================

-- Session 1 (terminal A):
-- BEGIN;
-- UPDATE Books SET available_copies = 0 WHERE book_id = 1;
-- (do not commit yet)

-- Session 2 (terminal B):
-- BEGIN;
-- SELECT available_copies FROM Books WHERE book_id = 1;
-- This returns 5 (the OLD value) because session 1 hasn't committed.

-- After session 1 commits:
-- COMMIT;
-- Session 2 re-runs SELECT:
-- SELECT available_copies FROM Books WHERE book_id = 1;
-- This now returns 0 (the NEW value).

-- (This demonstrates READ COMMITTED behaviour.)

-- ============================================================
-- DEMO 5: Isolation Level — SERIALIZABLE (strictest)
-- Business scenario: A serializable transaction will detect conflicts
-- ============================================================

-- Set the isolation level for this transaction
BEGIN ISOLATION LEVEL SERIALIZABLE;

SELECT book_id, title, available_copies
FROM Books
WHERE book_id = 1;

COMMIT;

-- ============================================================
-- DEMO 6: Clean up demo data (optional, keep database tidy)
-- ============================================================

DELETE FROM Books WHERE isbn IN ('999-9999999999', '777-7777777777');

-- Confirm cleanup
SELECT COUNT(*) FROM Books;

-- ============================================================
-- End of transactions.sql
-- ============================================================