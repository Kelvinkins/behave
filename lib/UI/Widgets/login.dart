import 'package:behave/Constants/constants.dart';
import 'package:behave/firebase/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => new _LoginState();
}



class _LoginState extends State<Login> {
    bool _loading = false;

  @override
  void initState() {
   
    authService.loading.listen((state) {
      if (mounted) {
        setState(() => _loading = state);
      }
      });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.3),
        ),
        _loading
            ? new Center(
                child: CircularProgressIndicator(),
              ):
        Column(
          children: <Widget>[
            RaisedButton(
                child: roundedRectButton("Google", signUpGradients, false),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                color: Colors.red,
                onPressed: () async {
                  FirebaseUser user = await authService.googleSignIn();

                  if (user != null) {
                    authService.analytics.logLogin(loginMethod: "googleLogin");
                    //  Navigator.push(context, new MaterialPageRoute(builder: (context)=>new HomeView(title: "hulia", user: user)));
                    // Navigator.of(context)
                    //     .pushReplacementNamed(
                    //         '/home');
                    Navigator.of(context).pushReplacementNamed(MAIN_UI);
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Error signing in with google"),
                            content: Text("Sorry, Something went wrong."),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  }
                }),
            Divider(height: 5),
            // roundedRectButton("Google", signUpGradients, false),

            RaisedButton(
              child: roundedRectButton("Facebook", signInGradients, false),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              onPressed: () {},
            )
          ],
        )
      ],
    );
  }
}

Widget roundedRectButton(
    String title, List<Color> gradient, bool isEndIconVisible) {
  return Builder(builder: (BuildContext mContext) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Stack(
        alignment: Alignment(1.0, 0.0),
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(mContext).size.width / 1.7,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Text(title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500)),
            padding: EdgeInsets.only(top: 16, bottom: 16),
          ),
          Visibility(
            visible: isEndIconVisible,
            child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: ImageIcon(
                  AssetImage("assets/ic_forward.png"),
                  size: 30,
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  });
}

const List<Color> signInGradients = [
  Colors.blue,
  Color(0xFF03A0FE),
];

const List<Color> signUpGradients = [
  Colors.red,
  Color(0xFFFc6076),
];
