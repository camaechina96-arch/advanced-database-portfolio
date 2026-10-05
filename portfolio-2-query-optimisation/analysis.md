# Query Processing and Optimisation Analysis

**Case Study:** University Library Management System  
**Portfolio:** Portfolio 2 — Query Processing and Optimisation  
**Author:** Charles Amaechina  
**Date:** 2026-10-05

---

## 1. Introduction

This document analyses the query performance of the University Library Management System. It presents SQL queries, execution plans captured via `EXPLAIN ANALYZE` in PostgreSQL 15, and demonstrates how strategic indexing can improve query performance.

**Environment:**
- Database: PostgreSQL 15.19 (running in Docker)
- Dataset: 8 Authors, 10 Members, 10 Books, 12 Loans, 3 Fines, 8 Reviews
- Tool: `EXPLAIN ANALYZE` (PostgreSQL's native query plan analyzer)

---

## 2. Complex SQL Queries

I developed 8 SQL queries covering the library's core operations:

| Query | Technique | Business Purpose |
|-------|-----------|------------------|
| Q1 | INNER JOIN (Books + Authors) | Catalogue search |
| Q2 | Multi-table JOIN + date arithmetic | Overdue report |
| Q3 | LEFT JOIN + GROUP BY | Top borrowers |
| Q4 | JOIN + HAVING clause | Top-rated books |
| Q5 | Subquery (IN) | Unpaid fines list |
| Q6 | LEFT JOIN + IS NULL | Unborrowed books |
| Q7 | DATE_TRUNC + aggregation | Monthly loan trends |
| Q8 | LEFT JOIN + COUNT | Author productivity |

Full scripts: see `queries.sql`.

**Actual results returned:**
- Q1: 10 books with author names.
- Q2: 2 overdue loans (John Smith 11 days, Fatima Ali 3 days).
- Q3: Ada Okafor and John Smith tied with 2 loans each.
- Q4: 5 books with average rating of 5.00.
- Q5: 2 members with unpaid fines (John Smith, Fatima Ali).
- Q6: 0 rows (all books have been borrowed at least once).
- Q7: September 2026 — 11 loans; October 2026 — 1 loan.
- Q8: Martin Kleppmann leads with 3 books; Jennifer Widom has 0.

---

## 3. Query Optimisation Strategy

### 3.1 Understanding Execution Plans

PostgreSQL's `EXPLAIN ANALYZE` returns the actual execution plan with:
- **Node Type** — how PostgreSQL accesses data (Seq Scan, Index Scan, Nested Loop, Hash Join)
- **Cost** — estimated cost (arbitrary units)
- **Actual Time** — real execution time in milliseconds
- **Rows** — number of rows returned

### 3.2 The Optimisation Approach

For each query we:
1. Ran it with **no relevant index** → captured a **Sequential Scan** baseline.
2. Created the appropriate **index**.
3. Ran it again → compared execution plans.
4. Used `SET enable_seqscan = OFF` to force PostgreSQL to use the index and demonstrate the difference.

---

## 4. Optimisation 1: Overdue Loans Query

### 4.1 Baseline — No Index

```sql
DROP INDEX IF EXISTS idx_loans_status;

EXPLAIN ANALYZE
SELECT l.loan_id, m.first_name, m.last_name, b.title
FROM Loans l
INNER JOIN Members m ON l.member_id = m.member_id
INNER JOIN Books b ON l.book_id = b.book_id
WHERE l.status = 'Overdue';