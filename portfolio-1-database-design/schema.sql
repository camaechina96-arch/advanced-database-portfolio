-- ============================================================
-- MIT 8103 Advanced Database Systems
-- Portfolio 1: Database Design and Modelling
-- Case Study: University Library Management System
-- File: schema.sql
-- Description: Creates the relational schema for the library
-- Author: Charles Amaechina
-- Date: 2026-10-05
-- ============================================================

-- ============================================================
-- Drop tables if they exist (clean re-run)
-- ============================================================
DROP TABLE IF EXISTS Reviews CASCADE;
DROP TABLE IF EXISTS Fines CASCADE;
DROP TABLE IF EXISTS Loans CASCADE;
DROP TABLE IF EXISTS Books CASCADE;
DROP TABLE IF EXISTS Authors CASCADE;
DROP TABLE IF EXISTS Members CASCADE;

-- ============================================================
-- Table: Authors
-- Stores information about book authors
-- ============================================================
CREATE TABLE Authors (
    author_id       SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    nationality     VARCHAR(50),
    birth_year      INT CHECK (birth_year >= 1000 AND birth_year <= 2100),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Table: Members
-- Stores information about library members (students/staff)
-- ============================================================
CREATE TABLE Members (
    member_id       SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    phone           VARCHAR(20),
    join_date       DATE DEFAULT CURRENT_DATE,
    status          VARCHAR(20) DEFAULT 'Active'
                    CHECK (status IN ('Active', 'Suspended', 'Expired')),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Table: Books
-- Stores information about books in the library
-- ============================================================
CREATE TABLE Books (
    book_id             SERIAL PRIMARY KEY,
    title               VARCHAR(200) NOT NULL,
    isbn                VARCHAR(20) UNIQUE,
    publication_year    INT CHECK (publication_year >= 1000 AND publication_year <= 2100),
    author_id           INT NOT NULL REFERENCES Authors(author_id) ON DELETE RESTRICT,
    category            VARCHAR(50),
    total_copies        INT DEFAULT 1 CHECK (total_copies >= 0),
    available_copies    INT DEFAULT 1 CHECK (available_copies >= 0),
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Table: Loans
-- Stores information about book loans
-- ============================================================
CREATE TABLE Loans (
    loan_id         SERIAL PRIMARY KEY,
    book_id         INT NOT NULL REFERENCES Books(book_id) ON DELETE RESTRICT,
    member_id       INT NOT NULL REFERENCES Members(member_id) ON DELETE RESTRICT,
    loan_date       DATE DEFAULT CURRENT_DATE,
    due_date        DATE NOT NULL,
    return_date     DATE,
    status          VARCHAR(20) DEFAULT 'Active'
                    CHECK (status IN ('Active', 'Returned', 'Overdue')),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (due_date >= loan_date)
);

-- ============================================================
-- Table: Fines
-- Stores information about fines issued to members
-- ============================================================
CREATE TABLE Fines (
    fine_id         SERIAL PRIMARY KEY,
    loan_id         INT NOT NULL REFERENCES Loans(loan_id) ON DELETE CASCADE,
    member_id       INT NOT NULL REFERENCES Members(member_id) ON DELETE RESTRICT,
    amount          DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    reason          VARCHAR(200),
    paid_status     VARCHAR(20) DEFAULT 'Unpaid'
                    CHECK (paid_status IN ('Paid', 'Unpaid', 'Waived')),
    issued_date     DATE DEFAULT CURRENT_DATE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Table: Reviews
-- Stores member reviews of books
-- ============================================================
CREATE TABLE Reviews (
    review_id       SERIAL PRIMARY KEY,
    book_id         INT NOT NULL REFERENCES Books(book_id) ON DELETE CASCADE,
    member_id       INT NOT NULL REFERENCES Members(member_id) ON DELETE CASCADE,
    rating          INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment         TEXT,
    review_date     DATE DEFAULT CURRENT_DATE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (book_id, member_id)
);

-- ============================================================
-- Indexes for performance (Portfolio 2 will use these)
-- ============================================================
CREATE INDEX idx_books_author_id ON Books(author_id);
CREATE INDEX idx_loans_member_id ON Loans(member_id);
CREATE INDEX idx_loans_book_id ON Loans(book_id);
CREATE INDEX idx_loans_status ON Loans(status);
CREATE INDEX idx_fines_member_id ON Fines(member_id);
CREATE INDEX idx_fines_paid_status ON Fines(paid_status);
CREATE INDEX idx_reviews_book_id ON Reviews(book_id);

-- ============================================================
-- End of schema.sql
-- ============================================================