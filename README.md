# MIT 8103 Advanced Database Systems Portfolio

**Student Name:** AMAECHINA CHIJIOKE CHARLES  
**Student ID:** 30171734  
**Course:** MIT 8103 Advanced Database Systems  
**Academic Session:** 2026/2027 First Semester  
**Assessment Type:** Individual Practical Database Portfolio  
**Submission Platform:** LMS + GitHub  

---

## Selected Case Study

**Organisation:** University Library Management System  
**Nature of Business:** A university library that lends books to students and staff, tracks loans, manages fines, and maintains a catalogue of books and members.  

**Users of the Database:**
- Librarians (manage books, members, and loans)
- Students (borrow and return books)
- Administrative Staff (generate reports, manage fines)

**Major Data Stored:**
- Books (title, ISBN, author, publication year, availability)
- Members (name, email, membership date, status)
- Loans (which book, which member, loan date, return date, status)
- Fines (member, amount, reason, payment status)
- Reviews (member reviews of books)

**Key Operations Supported:**
- Register new members and add new books
- Borrow a book (create a loan record)
- Return a book (update loan status, calculate fine if late)
- Search the catalogue by title, author, or ISBN
- Generate reports on overdue loans and popular books
- Store and retrieve book reviews

---

## Portfolio Structure

| Portfolio | Title | Marks | Status |
|-----------|-------|-------|--------|
| Portfolio 1 | Database Design and Modelling | 7 | ✅ Complete |
| Portfolio 2 | Query Processing and Optimisation | 7 | ✅ Complete |
| Portfolio 3 | Transactions and Concurrency | 7 | ✅ Complete |
| Portfolio 4 | NoSQL and Advanced Data Models | 7 | 🟡 In Progress |
| Portfolio 5 | Distributed and Cloud Database Exercise | 6 | ⚪ Not Started |
| Final | Documentation and Technical Reflection | 6 | ⚪ Not Started |
| **Total** | | **40** | |

---

## Technology Stack

| Component | Tool | Purpose |
|-----------|------|---------|
| Editor | VS Code | Writing code and documentation |
| Version Control | Git + GitHub | Progressive commits and evidence |
| Relational DB | PostgreSQL 15 (Docker) | SQL schema, queries, transactions |
| NoSQL DB | MongoDB 6.0 (Docker) | Document model for reviews |
| Containerisation | Docker + Docker Compose | Cross-platform reproducibility |
| Language | Python 3 | Concurrency simulation scripts |
| Python Driver | pg8000 | Pure-Python PostgreSQL driver |
| Diagrams | dbdiagram.io | ER diagrams |

---

## How to Run This Project

### Prerequisites

- Docker Desktop installed and running
- Python 3 installed
- pg8000 installed (`pip install pg8000`)

### Starting the Databases

```bash
docker compose up -d
docker ps