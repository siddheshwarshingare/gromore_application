import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';



class MoodReviewScreen extends StatefulWidget {
  const MoodReviewScreen({super.key});

  @override
  _MoodReviewScreenState createState() => _MoodReviewScreenState();
}

class _MoodReviewScreenState extends State<MoodReviewScreen> {
  final TextEditingController _reflectionController = TextEditingController();
  final List<String> moodEmojis = ["😊", "😌", "😡", "😢", "😔"];
  String? username;
  String? password;
  String? mobileNumber;
  String? selectedEmoji;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('userName');
    String? savedPassword = prefs.getString('passWord');
    String? savedMobileNumber = prefs.getString('mobileNumber');

    if (savedUsername != null && savedPassword != null) {
      // User logged in using username/password
      setState(() {
        username = savedUsername;
        password = savedPassword;
        mobileNumber = savedMobileNumber; // Might be null
      });
      fetchUserDataFromFirestoreWithUserCredential(username!);
    } else if (savedMobileNumber != null) {
      // User logged in using mobile number, fetch details from Firestore
      await fetchUserDataFromFirestore(savedMobileNumber);
    }
  }

 Future<void> fetchUserDataFromFirestoreWithUserCredential(String mobile) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('CustomerDetails')
          .where('userName', isEqualTo: mobile)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        setState(() {
         // username = userDoc['user'];
          mobileNumber = userDoc['mobileNumber'];
           print("No user found with this mobile number.${mobileNumber}");
        });
      } else {
        print("No user found with this mobile number.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }
  /// Fetch user details from Firestore using mobile number
  Future<void> fetchUserDataFromFirestore(String mobile) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('CustomerDetails')
          .where('mobileNumber', isEqualTo: mobile)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        setState(() {
          username = userDoc['user'];
          mobileNumber = userDoc['mobileNumber'];
        });
      } else {
        print("No user found with this mobile number.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  /// Saves mood and reflection to Firebase
  Future<void> saveMoodData() async {
  if (_reflectionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text(
      "कृपया आपले मत लिहा...",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
      ), // Increased font size
    ),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
  ),
);

    return;
  }

  if (selectedEmoji == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("कृपया एक भावना निवडा..."),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  setState(() {
    isSaving = true;
  });

  User? user = FirebaseAuth.instance.currentUser;

  if (username != null || mobileNumber != null) {
    await FirebaseFirestore.instance.collection('moods').add({
      'name': username,
      'mobileNumber': mobileNumber,
      'reflection': _reflectionController.text,
      'emoji': selectedEmoji,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      isSaving = false;
      selectedEmoji = null;
      _reflectionController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("अभिप्राय यशस्वीपणे सबमिट झाला!",style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE7),
      appBar: AppBar(
        title: const Text(
          "अभिप्राय नोंदवा",
          style: TextStyle(fontSize: 27),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Container(
              height: 300,
              child: Card(
                elevation: 13,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: const Color.fromARGB(255, 235, 232, 209),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          Text(
                            "हॅलो, ${username ?? 'User'}",
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.sentiment_very_satisfied, 
                            size: 35
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text("तुम्हाला कसे वाटते आमच्या भाजीपाल्या बद्दल?",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SizedBox(
                          height: 70,
                          child: TextField(
                            
                            controller: _reflectionController,
                            decoration: const InputDecoration(
                              hintText: "आपले मत लिहा......",
                              hintStyle: TextStyle(fontSize: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
             Text("ईमोजी निवडा..",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: moodEmojis.map((emoji) {
                bool isSelected = emoji == selectedEmoji;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedEmoji = emoji;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: isSelected
                        ? const EdgeInsets.all(6)
                        : const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.deepPurple : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? Colors.deepPurple.withOpacity(0.5)
                              : Colors.grey.shade300,
                          blurRadius: isSelected ? 10 : 5,
                          spreadRadius: isSelected ? 3 : 1,
                        ),
                      ],
                    ),
                    child: Text(
                      emoji,
                      style: TextStyle(
                          fontSize: 28,
                          color: isSelected ? Colors.white : Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
           // Text('3333444444${mobileNumber}'),
            const SizedBox(height:90),
            Center(
              child: isSaving
                  ? Lottie.asset('assets/animation/save.json', height: 200)
                  : ElevatedButton.icon(
                    
                      onPressed: saveMoodData,
                      style: 
                      ElevatedButton.styleFrom(
                        
                        elevation: 20,
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text("अभिप्राय सबमिट करा",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
