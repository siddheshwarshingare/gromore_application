import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NetworkError extends StatefulWidget {
  const NetworkError({super.key});

  @override
  State<NetworkError> createState() => _NetworkErrorPageState();
}

class _NetworkErrorPageState extends State<NetworkError> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent going back
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(image: AssetImage("assets/connectionfailed.png")),
              Text(
                "Connection Failed", // Replace with your localized text
                textAlign: TextAlign.center,
                style:TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.red, // Use app theme color if needed
                    ),
              ),
              Text(
                "कृपया तुमचे इंटरनेट कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.",
                textAlign: TextAlign.center,
                style:TextStyle (
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Implement your retry logic
                  debugPrint('Retry button clicked');
                  // Optionally, call setState() or other methods to check the connection again.
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow, // Change to your theme color
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                ),
                child: Text(
                  "Try Again", // Replace with your localized text
                  style: TextStyle(
                        color: Colors.red, // Use app theme color if needed
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
