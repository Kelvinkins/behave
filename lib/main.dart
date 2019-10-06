import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:behave/Constants/constants.dart';

import 'UI/Widgets/onboardingScreen.dart';
import 'UI/Widgets/splashScreen.dart';
import 'UI/login_ui.dart';
import 'UI/main_ui.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'behave',
      theme: ThemeData(primaryColor: Colors.red, fontFamily: 'Quicksand'),
      routes: <String, WidgetBuilder>{
        MAIN_UI: (BuildContext context) => MainUI(title:'Behave'),
        ONBOARDING_UI: (BuildContext context) => OnboardingUI(),
        SPLASH_SCREEN: (BuildContext context) => AnimatedSplashScreen(),
        LOGIN_UI: (BuildContext context) => LoginUI(),

      },
      initialRoute: SPLASH_SCREEN,
    );
  }
}
