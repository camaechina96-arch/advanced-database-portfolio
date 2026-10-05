# Distributed and Cloud Database Architecture

**Case Study:** University Library Management System  
**Portfolio:** Portfolio 5 — Distributed and Cloud Database Exercise  
**Author:** Charles Amaechina  
**Date:** 2026-10-05

---

## 1. Introduction

The University Library Management System currently runs on a single PostgreSQL instance. For a real-world university library, high availability, disaster recovery, and geographic distribution are essential. This document covers:

1. **CAP theorem** — the fundamental trade-off in distributed systems.
2. **Primary-Replica replication** — a working implementation.
3. **Sharding** — horizontal scaling strategy.
4. **Cloud deployment options** — AWS RDS, Azure Database, Google Cloud SQL.
5. **Availability and consistency** decisions for the library.

The accompanying files in this portfolio are:

- `docker-compose-cluster.yml` — the primary + replica cluster setup.
- `replication_test.sh` — an automated test that proves replication works.
- `architecture.md` — this document.

---

## 2. The CAP Theorem

In a distributed system, you can guarantee only **two of three** properties at the same time:

| Property | Meaning | Library Example |
|----------|---------|-----------------|
| **Consistency (C)** | Every read sees the latest write | All library branches see the same book count |
| **Availability (A)** | Every request gets a response (success or failure) | The catalogue is always reachable |
| **Partition Tolerance (P)** | The system keeps working despite network failures | A branch's internet drops; system still functions |

**The reality:** Network partitions WILL happen. So a distributed system must choose between **Consistency** and **Availability** during a partition.

### 2.1 Which Does the Library Need?

**Decision:** Prioritise **Availability (AP)** for reads and **Consistency (CP)** for writes.

- A student searching for a book should always get a fast response, even if the replica is slightly stale. → Availability.
- A student borrowing a book must decrement the exact copy count — no over-borrowing. → Consistency.

This is called **tunable consistency** — the right choice depends on the operation.

### 2.2 Real-World Example

If the network between the Main Campus and the Engineering Campus fails:

- **AP choice:** Both campuses keep serving reads. Engineering may see a slightly outdated book count.
- **CP choice:** Engineering refuses reads/writes until network is restored, ensuring perfect accuracy.

For a library, **AP is preferable** — it is better to serve students a slightly stale count than to make the catalogue unavailable.

---

## 3. Primary-Replica Replication (Implementation)

### 3.1 Architecture


### 3.2 How It Works

1. Applications write to the **primary**.
2. The primary writes to its **Write-Ahead Log (WAL)**.
3. A background process streams WAL records to the **replica**.
4. The replica replays the WAL, keeping data in sync.

The replica is a **hot standby** — it is always ready to be promoted to primary if the primary fails.

### 3.3 What This Buys Us

| Benefit | Description |
|---------|-------------|
| **High Availability** | If the primary fails, the replica can be promoted |
| **Read Scaling** | Read queries can hit the replica, reducing primary load |
| **Disaster Recovery** | Replica on a different server/region survives primary loss |
| **Backup Source** | Backups can run on replica without affecting primary performance |

### 3.4 Synchronous vs Asynchronous Replication

| Type | Behaviour | Trade-off |
|------|-----------|-----------|
| **Synchronous** | Primary waits for replica to confirm before returning to client | Higher latency, but zero data loss |
| **Asynchronous** | Primary returns immediately; replica catches up later | Lower latency, but risk of data loss if primary fails before replication |

**Our choice:** Asynchronous (PostgreSQL default). This keeps write latency low. For critical writes (e.g., a loan that must not be lost), we could switch to synchronous mode.

### 3.5 Implementation Evidence

The cluster is defined in `docker-compose-cluster.yml` using Bitnami's PostgreSQL image. The `replication_test.sh` script demonstrates:

1. Initial counts on both nodes (both should match).
2. A new book inserted into the primary.
3. The book appearing on the replica after ~3 seconds.
4. **A failed write to the replica** (proving it is read-only).

**Evidence:** See `evidence/portfolio5_*.png` files.

---

## 4. Sharding (Horizontal Partitioning)

For a large university with millions of books and members, replication is not enough — the primary becomes a bottleneck. **Sharding** splits the data across multiple independent databases.

### 4.1 Sharding Strategy

**Shard key:** `library_branch_id` (each campus library is its own shard).

Each shard is itself a primary-replica cluster for high availability.

### 4.2 Benefits and Challenges

| Aspect | Benefit | Challenge |
|--------|---------|-----------|
| Write scaling | Each shard handles 1/4 of writes | Cross-shard queries |
| Storage scaling | Each shard stores 1/4 of data | Rebalancing when adding shards |
| Failure isolation | One shard failure is not total failure | Distributed transactions across shards |

### 4.3 Cross-Shard Queries

For queries like "find all books by Author X across all campuses", we use a **query router** that fans out to all shards and merges results. This adds latency but scales writes.

**When to shard:** Only when a single primary can no longer handle the write volume. For a university library with thousands of transactions per day, replication is enough. Sharding becomes necessary at 10,000+ writes per second.

---

## 5. Cloud Deployment Options

For a real university, a self-managed Docker cluster is impractical. Cloud-managed databases provide replication, backups, and failover out of the box.

### 5.1 Comparison

| Provider | Service | Best For |
|----------|---------|----------|
| **AWS** | RDS for PostgreSQL or Aurora | Global scale, mature ecosystem |
| **Azure** | Azure Database for PostgreSQL | Microsoft ecosystem integration |
| **Google Cloud** | Cloud SQL for PostgreSQL | Analytics and ML integration |
| **MongoDB Atlas** | Managed MongoDB | Fully-managed NoSQL |

### 5.2 Recommended Cloud Architecture


**Key features:**

- **Multi-AZ** — automatic failover within a region in under 60 seconds.
- **Read Replicas** — scale reads horizontally.
- **Cross-Region** — disaster recovery if an entire region fails.
- **Automated Backups** — point-in-time recovery.
- **Encryption at rest** — compliance with data protection laws.

### 5.3 Cost Consideration

| Approach | Monthly Cost (Estimate) | Operational Effort |
|----------|-------------------------|---------------------|
| Self-hosted Docker cluster | 50 USD (VPS plus storage) | High (you manage everything) |
| AWS RDS Multi-AZ | 300 USD and above | Low (AWS manages failover, backups) |
| Managed PostgreSQL (small) | 100 USD | Low |

For a university, the operational savings usually outweigh the higher cloud costs.

---

## 6. Consistency Model for the Library

### 6.1 Operations and Their Consistency Needs

| Operation | Consistency | Why |
|-----------|-------------|-----|
| Search books | Eventual | Slight staleness is fine |
| View reviews | Eventual | Reviews are historical |
| Borrow book | Strong | Cannot over-lend |
| Return book | Strong | Cannot lose a return |
| Pay fine | Strong | Financial accuracy |
| View reports | Eventual | Analytics, not real-time |

### 6.2 Implementation

- **Writes go to primary** with synchronous commit (`synchronous_commit = on`).
- **Reads split by type:** catalogue search goes to replica; borrow and return checks go to primary.
- **Replica promotion** is automated via cloud failover.

---

## 7. Availability Design

**Target SLA:** 99.95 percent uptime (approximately 4.4 hours downtime per year).

Achieved through:

- Multi-AZ deployment (survives single data center failure).
- Automated failover in under 60 seconds to promote replica.
- Rolling maintenance windows.
- Health checks and alerting.
- Connection pooling (PgBouncer) to survive brief outages.

---

## 8. Trade-offs and Lessons Learned

1. **Replication is not a silver bullet.** It provides read scaling and high availability but adds write latency (synchronous) or risk of data loss (asynchronous).
2. **CAP is a spectrum, not a binary.** Modern databases let you tune per-operation.
3. **Sharding adds complexity.** Only shard when you must — replication solves 90 percent of scaling problems.
4. **Cloud simplifies operations but at a cost.** Managed databases are more expensive than self-hosted but save significant engineer time.
5. **Monitoring matters.** Distributed systems fail in subtle ways — you need observability through metrics, logs, and traces.
6. **Failover must be tested.** A failover that has never been exercised is a failover that will fail when needed.

---

## 9. Conclusion

Portfolio 5 demonstrated a working **primary-replica PostgreSQL cluster** with streaming replication, along with a discussion of sharding strategies and cloud deployment options. I verified that writes to the primary replicated to the replica, and that the replica rejected direct writes (proving it is read-only). This provides a realistic distributed database architecture for the library system, with clear trade-offs between consistency, availability, and partition tolerance.

The portfolio also reinforced the importance of designing for failure: choosing the right consistency model per operation, testing failover regularly, and understanding that replication and sharding solve different scaling problems.

---

*End of architecture.md*