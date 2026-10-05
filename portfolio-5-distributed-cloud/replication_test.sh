#!/bin/bash
# ============================================================
# MIT 8103 Advanced Database Systems
# Portfolio 5: Distributed and Cloud Database Exercise
# File: replication_test.sh
# Description: Tests that data written to primary replicates to replica
# Author: Charles Amaechina
# Date: 2026-10-05
# ============================================================

set -e

PRIMARY="library_primary"
REPLICA="library_replica"
DB_USER="student"
DB_PASS="password"
DB_NAME="library_db"

echo "============================================================"
echo "REPLICATION TEST: Primary -> Replica"
echo "============================================================"
echo ""

# Step 1: Show initial state on both nodes
echo "[1] Initial state on PRIMARY:"
docker exec -e PGPASSWORD=$DB_PASS $PRIMARY psql -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) AS books_on_primary FROM Books;"

echo ""
echo "[2] Initial state on REPLICA:"
docker exec -e PGPASSWORD=$DB_PASS $REPLICA psql -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) AS books_on_replica FROM Books;"

# Step 2: Insert a new book into the PRIMARY
echo ""
echo "[3] Inserting a new book into PRIMARY..."
docker exec -e PGPASSWORD=$DB_PASS $PRIMARY psql -U $DB_USER -d $DB_NAME -c "INSERT INTO Books (title, isbn, publication_year, author_id, category, total_copies, available_copies) VALUES ('Replication Test Book', '999-REPL-TEST', 2026, 1, 'Database', 1, 1);"

# Step 3: Wait briefly for replication to propagate
echo ""
echo "[4] Waiting 3 seconds for replication..."
sleep 3

# Step 4: Verify the row appears on both nodes
echo ""
echo "[5] PRIMARY count (after insert):"
docker exec -e PGPASSWORD=$DB_PASS $PRIMARY psql -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) AS books_on_primary FROM Books;"

echo ""
echo "[6] REPLICA count (after replication):"
docker exec -e PGPASSWORD=$DB_PASS $REPLICA psql -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) AS books_on_replica FROM Books;"

# Step 5: Show the specific row on both nodes
echo ""
echo "[7] The replicated row on PRIMARY:"
docker exec -e PGPASSWORD=$DB_PASS $PRIMARY psql -U $DB_USER -d $DB_NAME -c "SELECT book_id, title, isbn FROM Books WHERE isbn = '999-REPL-TEST';"

echo ""
echo "[8] The replicated row on REPLICA:"
docker exec -e PGPASSWORD=$DB_PASS $REPLICA psql -U $DB_USER -d $DB_NAME -c "SELECT book_id, title, isbn FROM Books WHERE isbn = '999-REPL-TEST';"

# Step 6: Attempt to write to the REPLICA (should fail — replica is read-only)
echo ""
echo "[9] Attempting to write directly to REPLICA (should FAIL):"
docker exec -e PGPASSWORD=$DB_PASS $REPLICA psql -U $DB_USER -d $DB_NAME -c "INSERT INTO Books (title, isbn, publication_year, author_id, category, total_copies, available_copies) VALUES ('Should Fail', '000-FAIL-TEST', 2026, 1, 'Test', 1, 1);" 2>&1 || echo "   >>> Expected error: replica is read-only <<<"

echo ""
echo "============================================================"
echo "REPLICATION TEST COMPLETE"
echo "============================================================"