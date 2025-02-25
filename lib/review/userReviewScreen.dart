import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
    if (timestamp == null) return "अज्ञात तारीख";
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        
        
        title: const Text(
          
          "All Reviews",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 207, 180, 230), Color.fromARGB(255, 110, 63, 205)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: fetchAllMoodReviews(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white),);
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
                            style: TextStyle(fontSize: 18, color: Colors.white70),
                          ),
                        );
                      }

                      var reviews = snapshot.data!.docs;

                      return Column(
                        children: [
                          // Display total reviews
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Total Reviews: ${reviews.length}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              itemCount: reviews.length,
                              itemBuilder: (context, index) {
                                var review = reviews[index];
                                String formattedDate = formatTimestamp(review['timestamp']);
                                String userName = review['name'] ?? 'Unknown';
                                String mobileNumber = review['mobileNumber'] ?? 'N/A';

                                return Card(
                                  elevation: 20,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.deepPurple.shade100,
                                      child: Text(
                                        userName.isNotEmpty ? userName[0] : "?",
                                        style: const TextStyle(
                                            fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      review['reflection'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(Icons.person, size: 16, color: Colors.grey),
                                            const SizedBox(width: 5),
                                            Text(
                                              "User: $userName",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone, size: 16, color: Colors.grey),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Mobile: $mobileNumber",
                                              style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Date: $formattedDate",
                                              style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      review['emoji'],
                                      style: const TextStyle(fontSize: 30),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
