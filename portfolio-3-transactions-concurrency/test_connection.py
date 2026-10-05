"""
Test PostgreSQL connection using pg8000 (pure Python driver).
"""
import pg8000.native

try:
    conn = pg8000.native.Connection(
        user="student",
        password="password",
        host="localhost",
        port=5432,
        database="library_db",
    )
    print("✅ Connection successful!")
    result = conn.run("SELECT COUNT(*) FROM Books;")
    print(f"Books in DB: {result[0][0]}")
    conn.close()
except Exception as e:
    print(f"❌ Connection failed: {e}")