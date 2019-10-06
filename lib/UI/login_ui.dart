import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Widgets/background.dart';
import 'Widgets/login.dart';

class LoginUI extends StatefulWidget {
  LoginUI({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginUIState createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Background(),
            Center(
              child: Login(),
            )
          ],
        ));
  }
}
