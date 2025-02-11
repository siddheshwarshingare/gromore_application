import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        toolbarHeight: 100,
        title: Center(
          child: Image.asset(
            "assets/animation/pp.png",
            height: 80,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // ✅ स्क्रोलिंग सक्षम करण्यासाठी
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'आमच्याबद्दल 🌿 🍅 🥦',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(height: 20),
              const Text(
                "ग्रोमोरे फार्ममिंग व्हेजिटेबल्समध्ये तुमचे स्वागत आहे!🌶️",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
               Text(
          

                ' तुमच्या घरी दर्जेदार  ताजा भाजीपाला पोहोचवण्याचा आमचा संकल्प आहे. '
                'आम्ही शेतीतून डायरेक्ट ग्राहकांपर्यंत थेट १००% सेंद्रिय 🥦 🥕 व फ्रेश भाज्या पुरवतो.',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const Text(
                
                "आमचे उद्दिष्ट तुम्हाला दर्जेदार आणि परवडणाऱ्या दरात सेंद्रिय भाजी उपलब्ध करून देणे आहे.🚀🍏 "
                "तुमच्या आरोग्यासाठी उत्तम दर्जाच्या  भाज्या  देणे ",
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              const Text(
                'आमची वचनबद्धता 🤝 🌟',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 10),
              const Text(
                'ग्रोमोरे  व्हेजिटेबल्स तर्फे आम्ही तुम्हाला चांगल्या जीवनशैलीसाठी आरोग्य चांगले राहण्यासाठी '
                'प्रत्येक कुटुंबाला पौष्टिक,शेतातील भाज्या मिळाव्यात, '
                'हे आमचे ध्येय आहे.',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              const Text(
                "आम्हालाच का निवडावे? 💯 🤩",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 8),
              const ListTile(
                leading: Icon(Icons.eco, color: Colors.green),
                title: Text(
                  "💚 १००% ताज्या आणि सेंद्रिय भाज्या",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.delivery_dining, color: Colors.green),
                title: Text(
                  "🚚 झटपट आणि मोफत होम डिलिव्हरी",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.local_florist, color: Colors.green),
                title: Text(
                  "👨‍🌾शेतीतून डायरेक्ट ग्राहकांपर्यंत पुरवठा",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.attach_money, color: Colors.green),
                title: Text(
                  "💰 परवडणारे आणि सर्वोत्तम दर",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  "© २०२५ फ्रेश व्हेजिटेबल्स. सर्व हक्क राखीव.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
