# Normalisation Analysis

**Case Study:** University Library Management System  
**Portfolio:** Portfolio 1 — Database Design and Modelling  
**Author:** Charles Amaechina  
**Date:** 2026-10-05

---

## 1. Introduction

Normalisation is the process of organising data in a relational database to reduce redundancy and improve data integrity. This document explains how the library database schema satisfies the requirements of the first four normal forms: 1NF, 2NF, 3NF, and BCNF.

The schema consists of six tables:
- **Authors** — stores author information
- **Members** — stores library member information
- **Books** — stores book information, linked to Authors
- **Loans** — stores loan transactions, linked to Books and Members
- **Fines** — stores fines, linked to Loans and Members
- **Reviews** — stores book reviews, linked to Books and Members

---

## 2. First Normal Form (1NF)

**Rule:** All attributes must be atomic (no repeating groups, no multi-valued attributes). Each row must be uniquely identifiable by a primary key.

**Compliance:**
- Every table has a single-column primary key:
  - `Authors(author_id)`
  - `Members(member_id)`
  - `Books(book_id)`
  - `Loans(loan_id)`
  - `Fines(fine_id)`
  - `Reviews(review_id)`
- No column contains multiple values:
  - Author names split into `first_name` and `last_name`
  - Member contact split into `email` and `phone`
  - Categories stored as single VARCHAR, not comma-separated lists
- No repeating groups — each loan, fine, review is a separate row.

**Result:** ✅ Satisfies 1NF.

---

## 3. Second Normal Form (2NF)

**Rule:** Table must be in 1NF, and every non-key attribute must be fully functionally dependent on the entire primary key (no partial dependencies).

**Compliance:**
- All tables use single-column primary keys (surrogate keys).
- Because there are no composite primary keys, partial dependencies cannot exist.
- Each non-key attribute depends on the whole primary key:
  - In `Books`, `title` depends on `book_id`.
  - In `Loans`, `loan_date` depends on `loan_id`.

**Result:** ✅ Satisfies 2NF.

---

## 4. Third Normal Form (3NF)

**Rule:** Table must be in 2NF, and no transitive dependencies (non-key attributes must not depend on other non-key attributes).

**Compliance — key decoupling decisions:**
- In `Books`, author information is NOT stored; only `author_id` as FK. This removes `book_id → author_id → author_name` transitive dependency.
- In `Loans`, member details are NOT stored; only `member_id` as FK.
- In `Fines`, loan and member details accessed via `loan_id` and `member_id`.
- In `Reviews`, book and member details accessed via FK.

**Result:** ✅ Satisfies 3NF.

---

## 5. Boyce-Codd Normal Form (BCNF)

**Rule:** Every determinant must be a candidate key.

**Compliance:**
- In every table, the primary key is the only determinant.
- In `Members`, `email` is UNIQUE and could be a candidate key. Since both `member_id → email` and `email → member_id` hold, it satisfies BCNF.
- No other non-trivial functional dependencies where non-candidate-key attributes determine other attributes.

**Result:** ✅ Satisfies BCNF.

---

## 6. Summary Table

| Normal Form | Requirement | Status |
|-------------|-------------|--------|
| 1NF | Atomic attributes, unique PK | ✅ Passed |
| 2NF | No partial dependencies | ✅ Passed |
| 3NF | No transitive dependencies | ✅ Passed |
| BCNF | Every determinant is a candidate key | ✅ Passed |

---

## 7. Design Decisions and Trade-offs

### 7.1 Surrogate Keys
Every table uses auto-incrementing `SERIAL` keys instead of natural keys (e.g., ISBN).  
**Reason:** Stability and performance for FK references.  
**Trade-off:** ISBN still stored as UNIQUE for external reference.

### 7.2 Separation of Authors from Books
Authors in separate table rather than columns in `Books`.  
**Reason:** Avoids redundancy (author with 50 books would repeat details 50 times).  
**Trade-off:** Book + author retrieval requires a JOIN.

### 7.3 Separation of Loans, Fines, Reviews
Separate tables for distinct business events.  
**Reason:** Minimises NULL values, improves query clarity.

### 7.4 Constraint Enforcement
CHECK constraints (e.g., `rating BETWEEN 1 AND 5`, `status IN (...)`) enforce business rules at the DB level rather than relying only on application code.

---

## 8. Conclusion

The library database schema is in **BCNF**, the strongest practical normal form for most OLTP systems. This ensures minimal redundancy, strong integrity, efficient updates, and clear relationships. The schema is ready for Portfolio 2: query processing and optimisation.

---

*End of normalization.md*