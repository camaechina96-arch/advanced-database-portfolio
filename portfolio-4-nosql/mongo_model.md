# NoSQL Data Model — MongoDB Design

**Case Study:** University Library Management System  
**Portfolio:** Portfolio 4 — NoSQL and Advanced Data Models  
**Author:** Charles Amaechina  
**Date:** 2026-10-05

---

## 1. Why NoSQL for Book Reviews?

The University Library Management System uses **PostgreSQL** for the transactional core (Books, Members, Loans, Fines) because those entities are highly structured and require ACID transactions.

However, **book reviews** have very different characteristics:

| Characteristic | SQL Suitability | NoSQL Suitability |
|----------------|-----------------|-------------------|
| Structured fields | Good | Good |
| Free-text comments (variable length) | Awkward | Excellent |
| Frequently changing schema | Requires ALTER TABLE | Schema-less |
| Nested/variable data (tags, reactions) | Requires extra tables | Natural |
| Read-heavy with denormalised data | Requires JOINs | Single-document read |
| Rapid iteration during development | Slow migrations | Fast |

**Decision:** Use **MongoDB (document model)** for reviews and user activity. This is a **polyglot persistence** architecture — using the right database for the right job.

---

## 2. Document Model Design

### 2.1 Collection: `reviews`

Each document represents one review by one member for one book.

```javascript
{
  _id: ObjectId("..."),
  book: {
    book_id: 5,
    title: "Designing Data-Intensive Applications",
    isbn: "978-1449373320"
  },
  member: {
    member_id: 1,
    name: "Charles Amaechina",
    email: "charles@example.com"
  },
  rating: 5,
  title: "Essential reading for modern engineers",
  comment: "This book fundamentally changed how I think about...",
  tags: ["distributed-systems", "databases", "architecture"],
  helpful_votes: 12,
  verified_borrow: true,
  created_at: ISODate("2026-10-05T10:30:00Z"),
  updated_at: ISODate("2026-10-05T10:30:00Z")
}

---

## 🛑 STEP 2: Create `mongo_queries.js`

**In VS Code:**
1. Right-click `portfolio-4-nosql/` → **New File**.
2. Name it: `mongo_queries.js`
3. Paste the **complete** content below.
4. Save (**Ctrl + S**).

```javascript
// ============================================================
// MIT 8103 Advanced Database Systems
// Portfolio 4: NoSQL and Advanced Data Models
// Case Study: University Library Management System
// File: mongo_queries.js
// Description: MongoDB implementation for book reviews
// Author: Charles Amaechina
// Date: 2026-10-05
// ============================================================

db = db.getSiblingDB('library_reviews');

// ============================================================
// 1. CLEANUP (safe to re-run)
// ============================================================
db.reviews.drop();

// ============================================================
// 2. INSERT SAMPLE REVIEWS
// ============================================================
db.reviews.insertMany([
  {
    book: { book_id: 5, title: "Designing Data-Intensive Applications", isbn: "978-1449373320" },
    member: { member_id: 1, name: "Charles Amaechina", email: "charles@example.com" },
    rating: 5,
    title: "Essential reading for modern engineers",
    comment: "This book fundamentally changed how I think about distributed systems. The chapters on replication and partitioning are worth the price alone.",
    tags: ["distributed-systems", "databases", "architecture"],
    helpful_votes: 12,
    verified_borrow: true,
    created_at: new Date("2026-09-20T10:30:00Z")
  },
  {
    book: { book_id: 5, title: "Designing Data-Intensive Applications", isbn: "978-1449373320" },
    member: { member_id: 4, name: "Mary Johnson", email: "mary.johnson@example.com" },
    rating: 5,
    title: "Comprehensive and practical",
    comment: "The best technical book I have read this year. The examples are clear and the reasoning behind design decisions is excellent.",
    tags: ["architecture", "systems-design"],
    helpful_votes: 8,
    verified_borrow: true,
    created_at: new Date("2026-09-25T14:15:00Z")
  },
  {
    book: { book_id: 6, title: "NoSQL Distilled", isbn: "978-0321826268" },
    member: { member_id: 5, name: "Ahmed Hassan", email: "ahmed.hassan@example.com" },
    rating: 4,
    title: "Good introduction but slightly outdated",
    comment: "Excellent for understanding the theory behind NoSQL, though some examples feel dated given how the ecosystem has evolved.",
    tags: ["nosql", "databases"],
    helpful_votes: 5,
    verified_borrow: false,
    created_at: new Date("2026-09-28T09:00:00Z")
  },
  {
    book: { book_id: 9, title: "MongoDB: The Definitive Guide", isbn: "978-1491954461" },
    member: { member_id: 7, name: "David Kimani", email: "david.kimani@example.com" },
    rating: 5,
    title: "The MongoDB reference I keep coming back to",
    comment: "Well-organised, deep coverage, and practical examples. Covers aggregation pipelines thoroughly.",
    tags: ["mongodb", "nosql", "reference"],
    helpful_votes: 15,
    verified_borrow: true,
    created_at: new Date("2026-09-30T16:45:00Z")
  },
  {
    book: { book_id: 1, title: "Database System Concepts", isbn: "978-0078022159" },
    member: { member_id: 2, name: "Ada Okafor", email: "ada.okafor@example.com" },
    rating: 4,
    title: "Excellent foundation",
    comment: "Great textbook for database theory. Slightly dense in places, but the exercises are excellent.",
    tags: ["textbook", "database-theory"],
    helpful_votes: 6,
    verified_borrow: true,
    created_at: new Date("2026-10-01T11:20:00Z")
  }
]);

print("Inserted " + db.reviews.countDocuments() + " reviews.\n");

// ============================================================
// 3. CREATE INDEXES
// ============================================================
db.reviews.createIndex({ "book.book_id": 1 });
db.reviews.createIndex({ "member.member_id": 1 });
db.reviews.createIndex({ rating: -1 });
db.reviews.createIndex({ tags: 1 });
db.reviews.createIndex({ created_at: -1 });

print("Indexes created.\n");

// ============================================================
// 4. QUERY 1: Find all reviews for a specific book
// ============================================================
print("=== Q1: All reviews for Book 5 (Designing Data-Intensive Applications) ===");
db.reviews.find(
  { "book.book_id": 5 },
  { "member.name": 1, rating: 1, title: 1, helpful_votes: 1, _id: 0 }
).forEach(printjson);
print("\n");

// ============================================================
// 5. QUERY 2: Top-rated books (aggregation)
// ============================================================
print("=== Q2: Average rating per book ===");
db.reviews.aggregate([
  {
    $group: {
      _id: "$book.book_id",
      book_title: { $first: "$book.title" },
      avg_rating: { $avg: "$rating" },
      review_count: { $sum: 1 },
      total_helpful: { $sum: "$helpful_votes" }
    }
  },
  { $sort: { avg_rating: -1 } }
]).forEach(printjson);
print("\n");

// ============================================================
// 6. QUERY 3: Search by tag (array query)
// ============================================================
print("=== Q3: Reviews tagged 'nosql' ===");
db.reviews.find(
  { tags: "nosql" },
  { title: 1, "member.name": 1, rating: 1, _id: 0 }
).forEach(printjson);
print("\n");

// ============================================================
// 7. QUERY 4: Most helpful reviews
// ============================================================
print("=== Q4: Top 3 most helpful reviews ===");
db.reviews.find(
  {},
  { "book.title": 1, "member.name": 1, rating: 1, helpful_votes: 1, _id: 0 }
).sort({ helpful_votes: -1 }).limit(3).forEach(printjson);
print("\n");

// ============================================================
// 8. QUERY 5: Update a review (add a helpful vote)
// ============================================================
print("=== Q5: Add a helpful vote to Charles's review ===");
db.reviews.updateOne(
  { "member.member_id": 1, "book.book_id": 5 },
  { $inc: { helpful_votes: 1 }, $set: { updated_at: new Date() } }
);
db.reviews.find(
  { "member.member_id": 1, "book.book_id": 5 },
  { title: 1, helpful_votes: 1, updated_at: 1, _id: 0 }
).forEach(printjson);
print("\n");

// ============================================================
// 9. FINAL SUMMARY
// ============================================================
print("=== FINAL SUMMARY ===");
print("Total reviews: " + db.reviews.countDocuments());
print("Distinct books reviewed: " + db.reviews.distinct("book.book_id").length);
print("Distinct members: " + db.reviews.distinct("member.member_id").length);
print("All tags in use: " + db.reviews.distinct("tags").join(", "));