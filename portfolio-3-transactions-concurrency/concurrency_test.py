"""
MIT 8103 Advanced Database Systems
Portfolio 3: Transactions and Concurrency
Case Study: University Library Management System
File: concurrency_test.py
Description: Simulates two members borrowing the same book simultaneously
             to demonstrate row-level locking and concurrency control.
Author: Charles Amaechina
Date: 2026-10-05

Note: Uses pg8000 (pure Python driver) instead of psycopg2 due to
      Windows Application Control policy blocking psycopg2 DLLs.

Transaction handling with pg8000.native:
    - Statements run in autocommit mode by default.
    - To run an explicit transaction, execute "BEGIN" first,
      then "COMMIT" or "ROLLBACK" as SQL statements.
"""

import threading
import time
import pg8000.native


# Database connection parameters
DB_CONFIG = {
    "user": "student",
    "password": "password",
    "host": "localhost",
    "port": 5432,
    "database": "library_db",
}


def borrow_book(member_id, book_id, thread_name):
    """
    Simulates a member borrowing a book.

    Uses SELECT ... FOR UPDATE inside an explicit transaction to lock
    the book row, preventing another transaction from modifying it
    until this transaction commits or rolls back.
    """
    print(f"[{thread_name}] Starting borrow for Member {member_id}, Book {book_id}")
    conn = None
    try:
        conn = pg8000.native.Connection(**DB_CONFIG)

        # Step 1: Begin an explicit transaction
        conn.run("BEGIN")

        # Step 2: Lock the book row with FOR UPDATE
        print(f"[{thread_name}] Acquiring lock on Book {book_id}...")
        result = conn.run(
            "SELECT book_id, available_copies FROM Books WHERE book_id = :book_id FOR UPDATE;",
            book_id=book_id,
        )

        if not result:
            print(f"[{thread_name}] ERROR: Book {book_id} not found.")
            conn.run("ROLLBACK")
            return

        current_available = result[0][1]
        print(f"[{thread_name}] Lock acquired. Available copies: {current_available}")

        # Simulate processing time (the librarian checking the member record)
        time.sleep(2)

        # Step 3: Check availability
        if current_available <= 0:
            print(f"[{thread_name}] No copies available - rolling back.")
            conn.run("ROLLBACK")
            return

        # Step 4: Decrement available copies
        conn.run(
            "UPDATE Books SET available_copies = available_copies - 1 WHERE book_id = :book_id;",
            book_id=book_id,
        )

        # Step 5: Create a loan record
        conn.run(
            """
            INSERT INTO Loans (book_id, member_id, loan_date, due_date, status)
            VALUES (:book_id, :member_id, CURRENT_DATE, CURRENT_DATE + INTERVAL '14 days', 'Active');
            """,
            book_id=book_id,
            member_id=member_id,
        )

        # Step 6: Commit the transaction
        conn.run("COMMIT")
        print(f"[{thread_name}] COMMITTED - Member {member_id} borrowed Book {book_id}")

    except Exception as e:
        print(f"[{thread_name}] ERROR: {e}")
        if conn:
            try:
                conn.run("ROLLBACK")
            except Exception:
                pass
    finally:
        if conn:
            conn.close()
        print(f"[{thread_name}] Connection closed.\n")


def main():
    """
    Launches two threads simultaneously to simulate two members
    trying to borrow the SAME book at the SAME time.
    """
    print("=" * 60)
    print("CONCURRENCY TEST: Two members borrowing the same book")
    print("=" * 60)
    print()

    BOOK_ID = 5  # Designing Data-Intensive Applications (6 copies available)

    # Create two threads
    thread_1 = threading.Thread(target=borrow_book, args=(1, BOOK_ID, "Member-1"))
    thread_2 = threading.Thread(target=borrow_book, args=(2, BOOK_ID, "Member-2"))

    # Start both threads at nearly the same time
    print("Launching both threads simultaneously...\n")
    thread_1.start()
    thread_2.start()

    # Wait for both to finish
    thread_1.join()
    thread_2.join()

    print("=" * 60)
    print("CONCURRENCY TEST COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()