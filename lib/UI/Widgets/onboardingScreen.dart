import 'package:behave/Constants/constants.dart';
import 'package:fancy_on_boarding/fancy_on_boarding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingUI extends StatefulWidget {
  @override
  _OnboardingUIState createState() => _OnboardingUIState();
}

class _OnboardingUIState extends State<OnboardingUI> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setSeen();

  }

  void setSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('seen', true);
  }

  final pageList = [
    PageModel(
        color: Colors.deepOrange,
        heroAssetPath: 'assets/style1.png',
        title: Text('Welcome to Behave!',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 34.0,
            )),
        body: Text(
            'Get ratings about your personality traits from those who know you well.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            )),
        iconAssetPath: 'assets/style1.png'),
    PageModel(
        color: Colors.orange,
        heroAssetPath: 'assets/style2.png',
        title: Text('Learn',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 34.0,
            )),
        body: Text(
            'Learn what people say about you and make adjustments to become better',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            )),
        iconAssetPath: 'assets/style2.png'),
    PageModel(
      color: Colors.red,
      heroAssetPath: 'assets/style3.png',
      title: Text('Sounds like fun?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 34.0,
          )),
      body: Text(
          'Then, help other people to become better too by rating them. Now hit the Get started button. Ohh Yeah!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          )),
      iconAssetPath: 'assets/style3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: FancyOnBoarding(
          doneButtonText: "Get Started",
          skipButtonText: "Skip",
          pageList: pageList,
          onDoneButtonPressed: () =>
              Navigator.of(context).pushReplacementNamed(LOGIN_UI),
          onSkipButtonPressed: () =>
              Navigator.of(context).pushReplacementNamed(LOGIN_UI)),
    );
  }
}
