# NoSQL Implementation Analysis

**Case Study:** University Library Management System  
**Portfolio:** Portfolio 4 — NoSQL and Advanced Data Models  
**Author:** Charles Amaechina  
**Date:** 2026-10-05

---

## 1. Introduction

This document presents a **MongoDB document model** for the University Library Management System. The relational PostgreSQL schema (from Portfolio 1) remains the source of truth for Books, Members, Loans, and Fines. MongoDB handles **book reviews and user-generated content**, which are semi-structured, read-heavy, and schema-flexible.

This is an example of **polyglot persistence** — using the right database for the right job.

---

## 2. Why NoSQL for Reviews?

Reviews have properties that make them poor fits for a relational schema:

| Property | Relational (SQL) Pain Point | NoSQL (MongoDB) Advantage |
|----------|------------------------------|----------------------------|
| Free-text comments | VARCHAR/TEXT with fixed limits | Native string, no limits |
| Nested data (tags, reactions) | Separate tables + JOINs | Native arrays and sub-documents |
| Schema changes | ALTER TABLE migrations | Schema-less |
| Read patterns | Multiple JOINs | Single document read |
| Development velocity | Slower | Fast iteration |

---

## 3. Document Model Design

### 3.1 Sample Document

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
  comment: "This book fundamentally changed how I think about distributed systems...",
  tags: ["distributed-systems", "databases", "architecture"],
  helpful_votes: 12,
  verified_borrow: true,
  created_at: ISODate("2026-09-20T10:30:00Z")
}

---

## 🛑 STEP 4: Copy and Run the MongoDB Script

**Run these commands in PowerShell, one at a time:**

### Command 4.1 — Copy the JS file into the MongoDB container

```powershell
docker cp portfolio-4-nosql/mongo_queries.js mit8103_mongodb:/tmp/mongo_queries.js