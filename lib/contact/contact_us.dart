import 'package:flutter/material.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight:110,
        flexibleSpace: const Column(
          children: [
            SizedBox(
              height: 50 ,
            ),
         SizedBox(
               height:100,
                child: Image(image: AssetImage('assets/animation/pp.png'),
                ),
                ),
          ],
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
             SizedBox(
              height: 10,
            ),
            ContactUsItemCard(
                titleString: 'संपर्क साधा',
                infoString: 'कॉल (किंवा) व्हॉट्सअ‍ॅप फोन नंबर :\n +91 7769032792\n',
                iconPath: 'assets/phone-call.png',
          ),
            SizedBox(
              height: 10,
            ),
            ContactUsItemCard(
                titleString: 'ईमेल आयडी',
                infoString: 'कुठल्याही प्रश्नांसाठी\nsiddheshwarshingare99@gmail.com',
                iconPath: 'assets/gmail.png',
              ),
            SizedBox(
              height: 10,
            ),
            ContactUsItemCard(
                titleString: 'पत्ता',
                infoString:
                    'पोस्ट चनाई येथे (आमचा शेताचा पत्ता) : Near to Dyaneshwar maharaj chowk Near adas phata chanai Tq : Ambajogai \nDist : Beed (431517)',
                iconPath: 'assets/map.png',
              ),
          ],
        ),
      ),
    );
  }
}

class ContactUsItemCard extends StatelessWidget {
  final String titleString;
  final String infoString;
  final String iconPath;

  const ContactUsItemCard({
    super.key,
    required this.titleString,
    required this.infoString,
    required this.iconPath,

  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(17),
              ),
            ),
            child: Column(
              children: [
                Text(
                  titleString,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 24
                      ),
                ),
                const Divider(
                  thickness: 1.5,
                  color: Colors.green,
                ),
                const SizedBox(
                  height: 10,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: infoString,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.normal,
                          fontSize: 17
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: Image.asset(
            iconPath,
            width: 20,
            height: 20,
          ),
        ),
      ],
    );
  }
}
