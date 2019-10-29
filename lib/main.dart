import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:behavio/Constants/constants.dart';

import 'UI/Widgets/onboardingScreen.dart';
import 'UI/Widgets/splashScreen.dart';
import 'UI/login_ui.dart';
import 'UI/main_ui.dart';
import 'UI/rating_ui.dart';

void main() {
  Admob.initialize("ca-app-pub-2109400871305297~8133378377");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'behavio',
      theme: ThemeData(primaryColor: Colors.red, fontFamily: 'Quicksand'),
      routes: <String, WidgetBuilder>{
        MAIN_UI: (BuildContext context) => MainUI(title: 'behavio'),
        ONBOARDING_UI: (BuildContext context) => OnboardingUI(),
        SPLASH_SCREEN: (BuildContext context) => AnimatedSplashScreen(),
        LOGIN_UI: (BuildContext context) => LoginUI(),
        RATING_UI: (BuildContext context) => RatingUI(isLink: false,),
      },
      initialRoute: SPLASH_SCREEN,
    );
  }
}
