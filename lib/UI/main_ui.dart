import 'dart:async';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:behavio/Constants/constants.dart';
import 'package:behavio/UI/rating_list_ui.dart';
import 'package:behavio/UI/rating_ui.dart';
import 'package:behavio/firebase/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:share/share.dart';

class MainUI extends StatefulWidget {
  MainUI({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainUIState createState() => _MainUIState();
}

class _MainUIState extends State<MainUI> {
  Map<String, double> dataMap = new Map();
  final TextEditingController txtPhoneNumberController =
      new TextEditingController();

  String dropDownValue;
  double positive = 0;
  double neutral = 0;
  double negative = 0;
  double positiveAverage = 0;
  double neutralAverage = 0;
  double negativeAverage = 0;
  bool isRefreshing = false;
  int positiveCount = 0;
  int negativeCount = 0;
  int neutralCount = 0;
  String lastRating = "...";
  Color color = Colors.green;
  bool hasPhoneNumber = true;
  bool _loading = false;
  bool toggle = false;
  List<Color> colorList = [
    Colors.green,
    Colors.orange,
    Colors.red,
  ];
  AdmobInterstitial interstitialAd;

  void refresh(
      double positiveTrait, double negativeTrait, double neutralTrait) {
    dataMap.putIfAbsent("Positive", () => positiveTrait);
    dataMap.putIfAbsent("Neutral", () => neutralTrait);
    dataMap.putIfAbsent("Negative", () => negativeTrait);
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new RatingUI(
                    isLink: true,
                    phoneNumber: deepLink.query.toString(),
                  )));
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new RatingUI(
                      isLink: true,
                      phoneNumber: deepLink.query.toString(),
                    )));
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.initDynamicLinks();

    authService.loading.listen((state) {
      if (mounted) {
        setState(() => _loading = state);
      }
    });

// _ratingController.text = "3.0";
    interstitialAd = AdmobInterstitial(
      // adUnitId: "ca-app-pub-3940256099942544/1033173712", //Test

      adUnitId: "ca-app-pub-2109400871305297/1330853228",
    );
    interstitialAd.load();

    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      authService.userHasPhoneNumber(user).then((bool value) {
        hasPhoneNumber = value;

        if (!value) {
          phoneNumberRequestDialog(
              context,
              "Phone number and gender",
              "Please enter your phone number and your gender, this is only done once.",
              "OK");
        }
      });
    });
  }

  void phoneNumberRequestDialog(
      BuildContext context, String title, String message, String buttonLabel) {
    // flutter defined function

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text(message),
              new TextField(
                keyboardType: TextInputType.phone,
                autocorrect: false,
                maxLines: 1,
                controller: txtPhoneNumberController,
                decoration: new InputDecoration(
                    labelText: 'Enter Phone Number',
                    hintText: 'Enter a Phone Number',
                    //filled: true,
                    icon: const Icon(Icons.phone),
                    labelStyle: new TextStyle(
                        decorationStyle: TextDecorationStyle.solid)),
              ),
              new Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Expanded(
                    child: new Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: new Text(
                        "Gender",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              new Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: Colors.blue,
                        width: 0.5,
                        style: BorderStyle.solid),
                  ),
                ),
                padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      child: DropdownButtonFormField<String>(
                        value: dropDownValue,
                        onChanged: (String newValue) {
                          setState(() {
                            if (newValue != null) {
                              dropDownValue = newValue;
                            }
                          });
                        },
                        items: <String>['Male', 'Female', 'Unknown']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(buttonLabel),
              onPressed: () async {
                if (txtPhoneNumberController.text == "" ||
                    txtPhoneNumberController.text == null ||
                    txtPhoneNumberController.text.contains("+") ||
                    txtPhoneNumberController.text.contains(" ")) {
                  messageDialogBox(
                      context,
                      "Input Error",
                      "You must enter a phone Number preceeded with the country code without the plus sign, without spaces. e.g 2348000000000",
                      "OK");
                } else if (dropDownValue == null) {
                  messageDialogBox(
                      context, "Input Error", "You must select gender", "OK");
                } else {
                  FirebaseUser user = await FirebaseAuth.instance.currentUser();
                  authService.collectPhoneNumber(
                      user, txtPhoneNumberController.text, dropDownValue);
                  // showDialogSingleButton(context, "Thank you!", message, "OK");
                  Navigator.of(context).pop();
                  if (await interstitialAd.isLoaded) {
                    interstitialAd.show();
                  }
                  Navigator.of(context).pushReplacementNamed(MAIN_UI);
                }
              },
            ),
            new FlatButton(
              child: new Text("I will do this later"),
              onPressed: () async {
                Navigator.of(context).pop();
                if (await interstitialAd.isLoaded) {
                  interstitialAd.show();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void messageDialogBox(
      BuildContext context, String title, String message, String buttonLabel) {
    // flutter defined function

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(buttonLabel),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void logoutMessageDialogBox(BuildContext context, String title,
      String message, String buttonLabel, String secondButtonLabel) {
    // flutter defined function

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(buttonLabel),
              onPressed: () async {
                authService.signOut();
                // Navigator.of(context).popAndPushNamed(MAIN_UI);
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(LOGIN_UI);
                if (await interstitialAd.isLoaded) {
                  interstitialAd.show();
                }
              },
            ),
            new FlatButton(
              child: new Text(secondButtonLabel),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text('Are you sure you want to exit behavio?'),
            content: AdmobBanner(
              adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
              //  adUnitId: "ca-app-pub-3940256099942544/6300978111",
              adUnitId: "ca-app-pub-2109400871305297/8189218691",
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () async {
                   Navigator.of(context).pop(false);
                     if (await interstitialAd.isLoaded) {
                    interstitialAd.show();
                  }
                   },
                child: new Text('No'),
                
              ),
              new FlatButton(
                onPressed: () async {
                  // AdmobBanner(
                  //   adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
                  //   adUnitId: "ca-app-pub-3940256099942544/6300978111",
                  //   // adUnitId: "ca-app-pub-2109400871305297/8189218691",
                  // );
                  if (await interstitialAd.isLoaded) {
                    interstitialAd.show();
                  }
                  SystemNavigator.pop();
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather

    // than having to individually change instances of widgets.
    return (new WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          
            // appBar: AppBar(
            //   title: Text("Behave"),
            //   elevation: 0,
            //   actions: [
            //     IconButton(
            //       icon: Icon(Icons.exit_to_app),
            //       color: Colors.white,
            //       onPressed: () async {
            //         messageDialogBox(context, "Sign out",
            //             "Are you sure you want to sign out?", "Yes", "No");
            //       },
            //     ),
            //   ],
            // ),

            // appBar: AppBar(
            //   // Here we take the value from the MainUI object that was created by
            //   // the App.build method, and use it to set our appbar title.
            //   title: Text(widget.title,),
            // ),
            body: NestedScrollView(
              body: FutureBuilder<FirebaseUser>(
                  future: FirebaseAuth.instance.currentUser(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return FutureBuilder<bool>(
                          future: authService.userHasPhoneNumber(snapshot.data),
                          builder: (context, ss) {
                            if (ss.hasData) {
                              if (ss.data) {
                                final DocumentReference docRef = Firestore
                                    .instance
                                    .document('users/' + snapshot.data.uid);
                                return FutureBuilder(
                                    future: docRef.get(),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.hasData) {
                                        // isRefreshing=true;
                                        // print(sSnapshot.data.documents[0].data["rating"]);
                                        Query qss = Firestore.instance
                                            .collection("ratings")
                                            .document(userSnapshot
                                                .data['phoneNumber']
                                                .toString())
                                            .collection("myratings")
                                            .orderBy("ratedOn",
                                                descending: true)
                                            .limit(1);
                                        qss.getDocuments().then(
                                            (QuerySnapshot querysnapshot) {
                                          var values = querysnapshot
                                              .documents.single.data["trait"]
                                              .toString();
                                          var category = querysnapshot
                                              .documents.single.data["category"]
                                              .toString();
                                          print(values);
                                          setState(() {
                                            lastRating = values;
                                            if (category == "Positive") {
                                              color = Colors.green;
                                            } else if (category == "Negative") {
                                              color = Colors.red;
                                            } else if (category == "Neutral") {
                                              color = Colors.orange;
                                            }
                                          });
                                        });
                                        return ListView(
                                          children: <Widget>[
                                            Card(
                                                elevation: 2.0,
                                                margin:
                                                    new EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 6.0),
                                                child: Container(
                                                  // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                                                  child:
                                                      FutureBuilder<
                                                              FirebaseUser>(
                                                          future: FirebaseAuth
                                                              .instance
                                                              .currentUser(),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              return ListTile(
                                                                  isThreeLine:
                                                                      true,
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          20.0,
                                                                      vertical:
                                                                          10.0),
                                                                  leading:
                                                                      AvatarGlow(
                                                                    startDelay: Duration(
                                                                        milliseconds:
                                                                            1000),
                                                                    glowColor:
                                                                        color,
                                                                    endRadius:
                                                                        40.0,
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            2000),
                                                                    repeat:
                                                                        true,
                                                                    showTwoGlows:
                                                                        true,
                                                                    repeatPauseDuration:
                                                                        Duration(
                                                                            microseconds:
                                                                                100),
                                                                    child:
                                                                        Material(
                                                                      elevation:
                                                                          8.0,
                                                                      shape:
                                                                          CircleBorder(),
                                                                      child:
                                                                          CircleAvatar(
                                                                        backgroundColor:
                                                                            Colors.green[100],
                                                                        backgroundImage: NetworkImage(snapshot
                                                                            .data
                                                                            .photoUrl),
                                                                        // CachedNetworkImage(
                                                                        //   imageUrl: snapshot.data.photoUrl,
                                                                        //   height: 60,
                                                                        //   placeholder: (context, url) =>
                                                                        //       new CircularProgressIndicator(),
                                                                        //   errorWidget: (context, url, error) =>
                                                                        //       new Icon(Icons.error),
                                                                        // ),
                                                                        radius:
                                                                            20.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  title: Text(
                                                                      snapshot
                                                                          .data
                                                                          .displayName,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                      )),
                                                                  subtitle:
                                                                      Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Row(
                                                                        children: <
                                                                            Widget>[
                                                                          Icon(
                                                                              Icons.linear_scale,
                                                                              color: color),
                                                                          Text(
                                                                              " Last rating"),
                                                                        ],
                                                                      ),
                                                                      Text(
                                                                          lastRating,
                                                                          style: TextStyle(
                                                                              color: color,
                                                                              fontWeight: FontWeight.bold))
                                                                    ],
                                                                  ),
                                                                  trailing: _loading
                                                                      ? CircularProgressIndicator()
                                                                      : IconButton(
                                                                          icon:
                                                                              Icon(
                                                                            Icons.share,
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            FirebaseUser
                                                                                user =
                                                                                await FirebaseAuth.instance.currentUser();
                                                                            String
                                                                                dynamicLink =
                                                                                await authService.shareLink(user);
                                                                            String
                                                                                message =
                                                                                "Rate my traits, Tell me something you like or dislike about me, I wont know you said it..\n" + dynamicLink;
                                                                            if (message !=
                                                                                null) {
                                                                              Share.share(message);
                                                                            }
                                                                          },
                                                                        ));
                                                            } else {
                                                              return CircularProgressIndicator(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                              );
                                                            }
                                                          }),
                                                )),

                                            Divider(
                                              height: 5,
                                            ),
                                            StreamBuilder(
                                                stream: Firestore.instance
                                                    .collection("ratings")
                                                    .document(userSnapshot
                                                        .data['phoneNumber']
                                                        .toString())
                                                    .collection("myratings")
                                                    .where("category",
                                                        isEqualTo: "Positive")
                                                    .snapshots(),
                                                builder: (context, sSnapshot) {
                                                  if (sSnapshot.hasData) {
                                                    if (sSnapshot
                                                            .data.documents !=
                                                        null) {
                                                      print("Lenght: " +
                                                          sSnapshot.data
                                                              .documents.length
                                                              .toString());
                                                      positive = 0;

                                                      sSnapshot.data.documents
                                                          .forEach((doc) {
                                                        positive = positive +
                                                            doc.data["rating"];
                                                        // refresh(10, 6, 5);
                                                      });
                                                      positiveCount = sSnapshot
                                                          .data
                                                          .documents
                                                          .length;
                                                      positiveAverage =
                                                          positive /
                                                              sSnapshot
                                                                  .data
                                                                  .documents
                                                                  .length;
                                                      return ListTile(
                                                          leading: Icon(
                                                            Icons
                                                                .sentiment_very_satisfied,
                                                            color: Colors.green,
                                                            size: 40,
                                                          ),
                                                          title: !positiveAverage
                                                                      .isNaN &&
                                                                  !positiveAverage
                                                                      .isInfinite
                                                              ? Text(
                                                                  positiveAverage
                                                                      .toStringAsFixed(
                                                                          1),
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .green,
                                                                      fontSize:
                                                                          20),
                                                                )
                                                              : Text(
                                                                  "Nothing yet",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic),
                                                                ),
                                                          subtitle: Row(
                                                            children: <Widget>[
                                                              Text("Positive "),
                                                              Icon(
                                                                Icons
                                                                    .rate_review,
                                                                size: 15,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              Text(
                                                                  " " +
                                                                      positiveCount
                                                                          .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  )),
                                                            ],
                                                          ));
                                                    } else {
                                                      return Text(
                                                          "No data at this time");
                                                    }
                                                  } else {
                                                    return Text(
                                                        "No data at this time");
                                                  }
                                                }),

                                            StreamBuilder(
                                                stream: Firestore.instance
                                                    .collection("ratings")
                                                    .document(userSnapshot
                                                        .data['phoneNumber']
                                                        .toString())
                                                    .collection("myratings")
                                                    .where("category",
                                                        isEqualTo: "Neutral")
                                                    .snapshots(),
                                                builder: (context, sSnapshot) {
                                                  if (sSnapshot.hasData) {
                                                    if (sSnapshot
                                                            .data.documents !=
                                                        null) {
                                                      neutral = 0;

                                                      sSnapshot.data.documents
                                                          .forEach((doc) {
                                                        neutral = neutral +
                                                            doc.data["rating"];
                                                        // refresh(10, 6, 5);
                                                        print(neutral);
                                                      });
                                                      neutralCount = sSnapshot
                                                          .data
                                                          .documents
                                                          .length;
                                                      neutralAverage = neutral /
                                                          sSnapshot.data
                                                              .documents.length;
                                                      return ListTile(
                                                          leading: Icon(
                                                              Icons
                                                                  .sentiment_neutral,
                                                              color:
                                                                  Colors.orange,
                                                              size: 40),
                                                          title: !neutralAverage
                                                                      .isNaN &&
                                                                  !neutralAverage
                                                                      .isInfinite
                                                              ? Text(
                                                                  neutralAverage
                                                                      .toStringAsFixed(
                                                                          1),
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .orange,
                                                                      fontSize:
                                                                          20),
                                                                )
                                                              : Text(
                                                                  "Nothing yet",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic),
                                                                ),
                                                          subtitle: Row(
                                                            children: <Widget>[
                                                              Text("Neutral "),
                                                              Icon(
                                                                Icons
                                                                    .rate_review,
                                                                size: 15,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              Text(
                                                                  " " +
                                                                      neutralCount
                                                                          .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  )),
                                                            ],
                                                          ));
                                                    } else {
                                                      return Text(
                                                          "No data at this time");
                                                    }
                                                  } else {
                                                    return Text(
                                                        "No data at this time");
                                                  }
                                                }),
                                            StreamBuilder(
                                                stream: Firestore.instance
                                                    .collection("ratings")
                                                    .document(userSnapshot
                                                        .data['phoneNumber']
                                                        .toString())
                                                    .collection("myratings")
                                                    .where("category",
                                                        isEqualTo: "Negative")
                                                    .snapshots(),
                                                builder: (context, sSnapshot) {
                                                  if (sSnapshot.hasData) {
                                                    if (sSnapshot
                                                            .data.documents !=
                                                        null) {
                                                      negative = 0;

                                                      sSnapshot.data.documents
                                                          .forEach((doc) {
                                                        negative = negative +
                                                            doc.data["rating"];
                                                        // refresh(10, 6, 5);
                                                        print(negative);
                                                      });
                                                      negativeCount = sSnapshot
                                                          .data
                                                          .documents
                                                          .length;
                                                      negativeAverage =
                                                          negative /
                                                              sSnapshot
                                                                  .data
                                                                  .documents
                                                                  .length;
                                                      return ListTile(
                                                          leading: Icon(
                                                              Icons
                                                                  .sentiment_very_dissatisfied,
                                                              color: Colors.red,
                                                              size: 40),
                                                          title: !negativeAverage
                                                                      .isNaN &&
                                                                  !negativeAverage
                                                                      .isInfinite
                                                              ? Text(
                                                                  negativeAverage
                                                                      .toStringAsFixed(
                                                                          1),
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          20),
                                                                )
                                                              : Text(
                                                                  "Nothing yet",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic),
                                                                ),
                                                          subtitle: Row(
                                                            children: <Widget>[
                                                              Text("Negative "),
                                                              Icon(
                                                                Icons
                                                                    .rate_review,
                                                                size: 15,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              Text(
                                                                  " " +
                                                                      negativeCount
                                                                          .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  )),
                                                            ],
                                                          ));
                                                    } else {
                                                      return Text(
                                                          "No data at this time");
                                                    }
                                                  } else {
                                                    return Text(
                                                        "No data at this time");
                                                  }
                                                }), // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                                            Card(
                                                elevation: 2.0,
                                                margin:
                                                    new EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 6.0),
                                                child: Container(
                                                  // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                                                  child: ListTile(
                                                      onTap: () async {
                                                        Navigator.push(
                                                            context,
                                                            new MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        new RatingList(
                                                                          phoneNumber: userSnapshot
                                                                              .data['phoneNumber']
                                                                              .toString(),
                                                                        )));
                                                        // if (await interstitialAd
                                                        //     .isLoaded) {
                                                        //   interstitialAd.show();
                                                        // }
                                                      },
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20.0,
                                                              vertical: 10.0),
                                                      leading: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 12.0),
                                                        decoration:
                                                            new BoxDecoration(
                                                                border:
                                                                    new Border(
                                                                        right:
                                                                            new BorderSide(
                                                          width: 1.0,
                                                        ))),
                                                        child: Icon(
                                                          Icons.details,
                                                          color: Colors.red,
                                                          size: 30,
                                                        ),
                                                      ),
                                                      title: Text("Details"),
                                                      subtitle: Row(
                                                        children: <Widget>[
                                                          Icon(
                                                              Icons
                                                                  .linear_scale,
                                                              color: Colors
                                                                  .green[300]),
                                                          Text(" Pos(" +
                                                              positiveCount
                                                                  .toString() +
                                                              ") Neu(" +
                                                              neutralCount
                                                                  .toString() +
                                                              ") Neg(" +
                                                              negativeCount
                                                                  .toString() +
                                                              ")"),
                                                        ],
                                                      ),
                                                      trailing: Icon(
                                                          Icons
                                                              .keyboard_arrow_right,
                                                          size: 30.0)),
                                                )),
                                            Divider(
                                              height: 30,
                                              color: Colors.white,
                                            ),
                                            isRefreshing
                                                ? PieChart(
                                                    dataMap: dataMap,
                                                    legendFontColor:
                                                        Colors.blueGrey[900],
                                                    legendFontSize: 14.0,
                                                    legendFontWeight:
                                                        FontWeight.w500,
                                                    animationDuration: Duration(
                                                        milliseconds: 800),
                                                    chartLegendSpacing: 32.0,
                                                    chartRadius:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2.7,
                                                    showChartValuesInPercentage:
                                                        true,
                                                    showChartValues: true,
                                                    showChartValuesOutside:
                                                        false,
                                                    chartValuesColor: Colors
                                                        .white
                                                        .withOpacity(0.9),
                                                    colorList: colorList,
                                                    showLegends: true,
                                                    decimalPlaces: 1,
                                                  )
                                                : Center(
                                                    child: Text(
                                                        "Chart is hidden",
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            color:
                                                                Colors.grey))),
                                            Center(
                                                child: FlatButton(
                                              child: isRefreshing
                                                  ? Text("Hide chart")
                                                  : Text("Show chart"),
                                              onPressed: () {
                                                refresh(positive, negative,
                                                    neutral);

                                                setState(() {
                                                  if (isRefreshing) {
                                                    isRefreshing = false;
                                                  } else {
                                                    isRefreshing = true;
                                                  }
                                                });
                                              },
                                            )),
                                          ],
                                        );
                                      } else {
                                        return Center(
                                            child: Text("No data at this time.",
                                                style: TextStyle(
                                                    color: Colors.grey)));
                                      }
                                      //     } else {
                                      //       return Center(
                                      //           child: Text("Please wait...",
                                      //               style: TextStyle(
                                      //                   color: Colors.grey)));
                                      //     }
                                      //   },
                                      // );
                                      // } else {
                                      //   return Center(
                                      //       child: Text(
                                      //     "No data at this time.",
                                      //     style: TextStyle(color: Colors.grey),
                                      //   ));
                                      // }
                                    });
                              } else {
                                return Center(
                                    child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Center(
                                        child: SafeArea(
                                            child: Text(
                                      "You must enter your Phone Number and your \n     gender for your account to be active.\n  Note that your phone number must include the the country code without the plus sign, without spaces. E.g 2348000000000",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey),
                                    ))),
                                    Center(
                                        child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: Text(
                                        "Get started",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Colors.green,
                                      onPressed: () {
                                        phoneNumberRequestDialog(
                                            context,
                                            "Phone number and gender",
                                            "Please enter your phone number and your gender, this is only done once.",
                                            "OK");
                                      },
                                    ))
                                  ],
                                ));
                              }
                            } else {
                              return Center(
                                child: Text("Loading..."),
                              );
                            }
                          });
                    } else {
                      return Center(
                        child: Text(
                          "Please wait...",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      );
                    }
                  }),
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 200.0,
                    forceElevated: true,
                    elevation: 0.0,
                    iconTheme: IconThemeData(color: Colors.white),
                    backgroundColor: Colors.red,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.exit_to_app),
                        color: Colors.white,
                        onPressed: () async {
                          logoutMessageDialogBox(
                              context,
                              "Sign out",
                              "Are you sure you want to sign out?",
                              "Yes",
                              "No");
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      title: FutureBuilder<FirebaseUser>(
                          future: FirebaseAuth.instance.currentUser(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Row(
                                children: <Widget>[
                                  Hero(
                                      tag: "start",
                                      child: AvatarGlow(
                                        startDelay:
                                            Duration(milliseconds: 1000),
                                        glowColor: Colors.green,
                                        endRadius: 30.0,
                                        duration: Duration(milliseconds: 2000),
                                        repeat: true,
                                        showTwoGlows: true,
                                        repeatPauseDuration:
                                            Duration(microseconds: 100),
                                        child: Material(
                                          elevation: 8.0,
                                          shape: CircleBorder(),
                                          child: new Image.asset(
                                            'assets/icon.png',
                                            width: 50,
                                            height: 50,
                                          ),
                                        ),
                                      )),
                                  Container(
                                    child: Text("ehavio",
                                        style: TextStyle(
                                          fontSize: 18,
                                        )),
                                    width: 100,
                                  )
                                ],
                              );
                            } else {
                              return CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              );
                            }
                          }),

                      // Text("Samuel Kingsley",
                      //     style: TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 16.0,
                      //         fontFamily: 'Quicksand')),

                      // } else if (snapshot.hasError) {
                      //   return Text("${snapshot.error}");
                      // }
                      // return CircularProgressIndicator();
                      //   },
                      // ),
                      background: SvgPicture.asset('assets/style3.svg'),
                    ),
                  ),
                ];
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                if (!hasPhoneNumber) {
                  messageDialogBox(
                      context,
                      "Account not active",
                      "You must activate your account first before you can rate anyone.",
                      "OK");
                } else {
                  Navigator.of(context).pushNamed(RATING_UI);
                }
              },
              tooltip: 'rate',
              heroTag: "rateUi",
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              icon: Icon(Icons.rate_review),
              label: Text("Rate"),
            )
            // This trailing comma makes auto-formatting nicer for build methods.
            )));
  }
}
