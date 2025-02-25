import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gromore_application/cart/addToCartScreen.dart';
import 'package:gromore_application/connectivity/networkError.dart';
import 'package:gromore_application/connectivity/connectivityService.dart';
import 'package:gromore_application/language/languageSelector.dart';
import 'package:gromore_application/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()), // ✅ Register Connectivity Service
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('te'),
          ],
          locale: localeProvider.locale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          // ✅ UI updates dynamically based on connectivity status
          home: connectivityService.isConnected ? Splashscreen() : const NetworkError(),
           builder: (context, child) {
            return connectivityService.isConnected
                ? child!
                : const NetworkError(); // ✅ Shows NetworkError on top of the app
          },
        );
      },
    );
  }
}
