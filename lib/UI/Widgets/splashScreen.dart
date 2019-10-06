import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:behave/Constants/constants.dart';

class AnimatedSplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  var _visible = false;

  AnimationController animationController;
  Animation<double> animation;
  bool seen = false;
  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    if (seen) {
      Navigator.of(context).pushReplacementNamed(MAIN_UI);
    } else {
      Navigator.of(context).pushReplacementNamed(ONBOARDING_UI);
    }
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 2));
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(bottom: 30.0),
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[Text("Powered by hulia")],
                  ))
            ],
          ),
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Behave",
                style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                    fontSize: animation.value * 30),
              ),
              Text(
                "You can be better...",
                style:
                    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              )
            ],
          ),
        ],
      ),
    );
  }
}
