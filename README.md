# MIT 8103 Advanced Database Systems — Portfolio

**Name:** AMAECHINA CHIJIOKE CHARLES
**Student ID:** 30171734
**Course:** MIT 8103 Advanced Database Systems
**Session:** 2026/2027 First Semester
**Submission:** LMS + GitHub

---

## My Case Study: A University Library

For this portfolio, I chose a University Library Management System. I picked this because
a library has all the ingredients a database course needs — structured master data
(books, members), transactional data (loans, fines), unstructured content (reviews),
and scaling requirements (multi-campus replication).

**Who uses the system:**
- Librarians — add books, register members, process returns
- Students — search the catalogue, borrow, review
- Admin staff — chase overdue loans, manage fines

**What the database stores:**
- Books, authors, categories, ISBNs
- Members (students and staff)
- Loans (who borrowed what and when)
- Fines (unpaid, paid, waived)
- Reviews (a newer feature — this is where MongoDB comes in)

**Main operations:**
- Add a book, register a member
- Borrow a book, return a book
- Search the catalogue by title or author
- Generate overdue reports
- Store and read reviews

---

## Portfolio Status

| # | Portfolio | Marks | Status |
|---|-----------|-------|--------|
| 1 | Database Design and Modelling | 7 | Done |
| 2 | Query Processing and Optimisation | 7 | Done |
| 3 | Transactions and Concurrency | 7 | Done |
| 4 | NoSQL and Advanced Data Models | 7 | Done |
| 5 | Distributed and Cloud Database Exercise | 6 | Done |
| Final | Documentation and Reflection | 6 | Done |
| **Total** | | **40** | |

---

## Tools I Used

- **VS Code** — writing code and docs
- **Docker Desktop** — running all databases
- **PostgreSQL 15** — the main relational database
- **MongoDB 6.0** — for review documents
- **Python 3 with pg8000** — for the concurrency test
- **Git + GitHub** — version control and evidence
- **dbdiagram.io** — drawing the ER diagram

Why Docker? Because installing PostgreSQL, MongoDB, and a replica cluster
directly on Windows is messy. Docker lets me run everything in isolation,
and the same docker-compose file works on any machine.

---

## How to Run This Project

### Start the basic databases

```bash
docker compose up -d
docker ps

My Reflection on Each Portfolio
Setting Up the Environment
I set up Docker on Windows. The trickiest part was that Docker Desktop on Windows
needs WSL 2 (Windows Subsystem for Linux) to run Linux containers. Installing it took
a couple of attempts — my first wsl --install failed with a network error, but
running it again after a restart worked.

Once Docker was running, I created the folder structure and committed everything to
GitHub. This was the foundation for all five portfolios.

Portfolio 1 — Database Design
I designed a six-table schema: Authors, Members, Books, Loans, Fines, and Reviews.
Getting the design to 3NF meant splitting Authors out of Books (otherwise each book
would repeat the author's name, nationality, and birth year). That decision alone
eliminated a lot of potential update anomalies.

I added CHECK constraints so the database itself enforces rules — a rating must be
between 1 and 5, a loan's due date must be after the loan date, a fine amount can't
be negative. To prove these worked, I deliberately tried to insert bad data and
watched PostgreSQL reject it. That was the moment constraints clicked for me.

One thing I learned: the seed data script wasn't idempotent at first. When I ran it
twice, I got unique constraint errors. The fix was to always run schema.sql first
(which drops the tables) before running seed_data.sql.

Portfolio 2 — Query Optimisation
I wrote eight queries covering the main library operations: catalogue search,
overdue reports, top borrowers, top-rated books, unpaid fines, unborrowed books,
monthly trends, and author productivity.

The interesting part was the optimisation analysis. PostgreSQL's planner didn't
always use my indexes. On a table with only 12 rows, a Sequential Scan is cheaper
than an Index Scan — so the planner correctly ignored my index. That was
counter-intuitive at first, but it makes sense: reading 12 rows in order is faster
than a B-tree lookup.

To prove the indexes were working, I forced them with SET enable_seqscan = OFF.
Suddenly the query plan showed "Index Scan using idx_loans_status on loans" and
the timing dropped. On a table with a million rows, that difference is the
difference between a fast system and a slow one.

Portfolio 3 — Transactions and Concurrency
This was the most technically interesting portfolio. I wrote two things:

First, a transactions.sql file with demos of COMMIT, ROLLBACK, and SAVEPOINT.
The SAVEPOINT example was nice — I inserted a valid book, marked a savepoint,
inserted an invalid book (foreign key would fail), then rolled back to the savepoint.
The valid book stayed, the invalid one was gone.

Second, a Python script that has two threads try to borrow the same book at the
same time. Without locking, both threads would see available_copies = 6,
decrement it, and we'd end up with 4 copies but 2 loans — a classic race condition.

The fix was SELECT ... FOR UPDATE, which locks the row. When I ran the script,
Member-2 waited a couple of seconds and then read available_copies = 5 — not 6.
That proved the lock was working.

One thing I had to work around: the psycopg2 library wouldn't import on my
Windows machine — Windows Application Control blocked its DLL. I switched to
pg8000, which is pure Python and doesn't need native binaries. Same logic,
different library.

Portfolio 4 — NoSQL
For reviews, I used MongoDB. Reviews are a good fit for a document store because
they have variable fields (tags, reactions, comment length) and they're read
much more than written.

I embedded the book and member data directly in each review document — so one
query gets everything needed to render a review page, no JOINs. The trade-off is
that if a member changes their name, existing reviews show the old name. For
reviews, that's actually fine — it's a snapshot of who wrote it at the time.

I wrote five queries including an aggregation pipeline that computes average
rating per book with $group and $avg. That pipeline replaces what would be
several SQL JOINs and GROUP BYs.

I wouldn't use MongoDB for loans or fines though. Those need ACID. This is the
idea of "polyglot persistence" — different databases for different jobs.

Portfolio 5 — Distributed and Cloud
I set up a primary-replica PostgreSQL cluster using Docker Compose. The primary
runs on port 5433, the replica on 5434. The replica streams the primary's
Write-Ahead Log so it stays in sync.

To prove it worked, I inserted a book into the primary. Three seconds later, the
same book was on the replica. Then I tried inserting directly into the replica and
got: ERROR: cannot execute INSERT in a read-only transaction. That error is the
proof — the replica is a true read-only standby.

I also wrote an architecture.md covering CAP theorem, sharding, and cloud options.
The library is a good case study because it needs Availability for catalogue
searches (a slightly stale count is fine) but Consistency for borrowing (you
cannot lend a book twice).

AI Use Declaration
Tool used: ChatGPT (OpenAI) — as a learning aid and reviewer.

What I used it for:

Understanding database concepts (normalisation, isolation levels, CAP theorem)

Debugging errors I hit during setup

Reviewing my approach

How I verified it:

Every SQL script, Python script, and Docker command was run by me locally

I checked query outputs, execution plans, and container logs myself

Every screenshot in the evidence/ folder is from my own runs

The reflection sections above are written in my own words based on what I
actually observed

What went wrong that I fixed myself:

psycopg2 DLL blocked → switched to pg8000

Bitnami deprecated their images → switched to bitnamilegacy

PowerShell interpreted $ in MongoDB commands → moved to standalone JS files

Duplicate key errors on re-run → always run schema.sql first

Declaration: I understand that I am responsible for everything in this
submission and can explain any part of it if asked.