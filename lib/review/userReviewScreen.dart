import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

class UserReviewsScreen extends StatefulWidget {
  const UserReviewsScreen({super.key});

  @override
  _UserReviewsScreenState createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> {
  /// Fetch all mood reviews from Firestore
  Stream<QuerySnapshot> fetchAllMoodReviews() {
    return FirebaseFirestore.instance
        .collection('moods')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Convert timestamp to Indian Date Format (DD/MM/YYYY)
  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "अज्ञात तारीख"; // "Unknown Date" in Marathi
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(dateTime); // Indian format
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE7),
      appBar: AppBar(
        title: const Text(
          "सर्व अभिप्राय",
          style: TextStyle(fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchAllMoodReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "डेटा लोड करताना त्रुटी आली!",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "सध्या कोणतेही अभिप्राय उपलब्ध नाहीत.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          var reviews = snapshot.data!.docs;

          return Column(
            children: [
              // Display review count at the top
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Total Reviews: ${reviews.length}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    var review = reviews[index];
                    String formattedDate = formatTimestamp(review['timestamp']);

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: Text(
                          review['emoji'],
                          style: const TextStyle(fontSize: 30),
                        ),
                        title: Text(
                          review['reflection'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "User: ${review['name'] ?? 'Unknown'}",
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Mobile: ${review['mobileNumber'] ?? 'N/A'}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              "Date: $formattedDate", // DD/MM/YYYY format
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
