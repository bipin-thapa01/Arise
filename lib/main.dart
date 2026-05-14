import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:fitness/Screens/splash_screen.dart';
import 'package:fitness/notification_service.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fitness/firebase_notification.dart';
import 'package:intl/date_symbol_data_local.dart';

void initOpenFoodFacts() {
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'fitness_app',
    version: '1.0',
  );
  OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.ENGLISH];
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.NEPAL;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initOpenFoodFacts();
  await Firebase.initializeApp();
  await FirebaseNotification().initFCM();
  await initializeDateFormatting();
  // await NotificationService.instance.initNotification();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isFetching = true;
  bool isLogin = false;
  final storage = FlutterSecureStorage();
  late String? email;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetch() async {
    fb.User? user = fb.FirebaseAuth.instance.currentUser;
    email = (await storage.read(key: "email"));
    if (user == null) {
      setState(() {
        isFetching = false;
      });
    } else {
      setState(() {
        isFetching = false;
        isLogin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: StandardData.mainBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: StandardData.mainBackground,
          surfaceTintColor: Colors.transparent,
        ),
        colorScheme: ColorScheme.dark(
          surface: StandardData.mainBackground,
          background: StandardData.mainBackground,
          primary: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SpinKitThreeBounce(color: StandardData.primaryColor, size: 30.0),
    );
  }
}
