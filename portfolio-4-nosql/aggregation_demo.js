// Aggregation demo — Portfolio 4
db = db.getSiblingDB('library_reviews');

print("=== Aggregation: Avg rating per book ===\n");

db.reviews.aggregate([
  {
    $group: {
      _id: "$book.title",
      avg_rating: { $avg: "$rating" },
      reviews: { $sum: 1 },
      total_helpful: { $sum: "$helpful_votes" }
    }
  },
  { $sort: { avg_rating: -1 } }
]).forEach(printjson);