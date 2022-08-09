import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shopkeeper/app_config.dart';
import 'package:shopkeeper/pages/choose_mode_page.dart';
import 'package:shopkeeper/pages/detail_promotion_page.dart';
import 'package:shopkeeper/pages/root_page.dart';
import 'package:shopkeeper/pages/login_page.dart';
import 'package:shopkeeper/pages/register_page.dart';
import 'package:shopkeeper/pages/home_page.dart';
import 'package:shopkeeper/pages/tab_bar_page.dart';
import 'package:flutter/services.dart';
import 'package:shopkeeper/pages/terms_and_conditions_page.dart';
import 'package:shopkeeper/utils/options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  //FirebaseCrashlytics.instance.crash();
  final FirebaseMessaging _firebaseMessaging =  FirebaseMessaging.instance;
  final token = await _firebaseMessaging.getToken();
  print(token);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  const MethodChannel('flavor')
      .invokeMethod<String>('getFlavor')
      .then((String flavor) {
    if (flavor == 'production') {
      startProduction();
    } else if (flavor == 'qa') {
      startQA();
    }
  }).catchError((error) {
    //print(error);
    print('FAILED TO LOAD FLAVOR => initializing qa by default');
    startQA();
  });

  runApp(ShopKeeperApp());
}

void startProduction() {
  AppConfig.getInstance(
    appName: 'Cuponix Tienda',
    flavorName: 'production',
    apiBaseUrl: 'omega-dot-activaciones.appspot.com',
  );
}

void startQA() {
  AppConfig.getInstance(
    appName: 'Cuponix Tendero QA',
    flavorName: 'qa',
    apiBaseUrl: 'https://cpnx-backend-dot-test-id-qa.appspot.com/api',
  );
}

class ShopKeeperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Cuponix Tienda',
      theme: ThemeData(
        fontFamily: 'Raleway',
        primarySwatch: Colors.purple,
      ),
      home: RootPage(),
      routes: {
        "/chooseMode": (BuildContext context) => ChooseModePage(),
        "/login": (BuildContext context) => LoginPage(),
        "/register": (BuildContext context) => RegisterPage(),
        "/home": (BuildContext context) => HomePage(),
        "/tabs": (BuildContext context) => TabBarPage(),
        "/detailPromotion": (BuildContext context) => DetailPromotionPage(),
        "/terms": (BuildContext context) => TermsAndConditionsPage(),
      },
    );
  }
}
