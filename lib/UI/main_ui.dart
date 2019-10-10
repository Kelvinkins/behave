import 'package:avatar_glow/avatar_glow.dart';
import 'package:behave/Constants/constants.dart';
import 'package:behave/firebase/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:pie_chart/pie_chart.dart';

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

  bool toggle = false;
  List<Color> colorList = [
    Colors.red,
    Colors.green,
    Colors.orange,
  ];

  void refresh(
      double positiveTrait, double negativeTrait, double neutralTrait) {
    dataMap.putIfAbsent("Negative Trait", () => negativeTrait);
    dataMap.putIfAbsent("Positive Trait", () => positiveTrait);
    dataMap.putIfAbsent("Neutral Trait", () => neutralTrait);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refresh(5, 10, 6);
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      authService.userHasPhoneNumber(user).then((bool value) {
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
                      child: DropdownButton<String>(
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
                if (txtPhoneNumberController.text != null ||
                    dropDownValue != null) {
                  FirebaseUser user = await FirebaseAuth.instance.currentUser();
                  authService.collectPhoneNumber(
                      user, txtPhoneNumberController.text, dropDownValue);
                  // showDialogSingleButton(context, "Thank you!", message, "OK");
                  Navigator.of(context).pop();
                }
              },
            ),
            new FlatButton(
              child: new Text("I will do this later"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text("Behave"),
        elevation: 0,
      ),

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
                          final DocumentReference docRef = Firestore.instance
                              .document('users/' + snapshot.data.uid);
                          return FutureBuilder(
                              future: docRef.get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.hasData) {
                                  return StreamBuilder(
                                    stream: Firestore.instance
                                        .collection("ratings")
                                        .document(userSnapshot
                                            .data['phoneNumber']
                                            .toString())
                                        .collection("myratings")
                                        .snapshots(),
                                    builder: (context, sSnanshot) {
                                      if(sSnanshot.hasData)
                                      {
                                      if (sSnanshot.data.documents==null) {
                                        return ListView(
                                          children: <Widget>[
                                            Card(
                                                elevation: 8.0,
                                                margin:
                                                    new EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 6.0),
                                                child: Container(
                                                  // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                                                  child: ListTile(
                                                      onTap: () {},
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
                                                          Icons.thumb_up,
                                                          color: Colors.green,
                                                          size: 30,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        "Attractive",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.green),
                                                      ),
                                                      subtitle: Row(
                                                        children: <Widget>[
                                                          Icon(
                                                              Icons
                                                                  .linear_scale,
                                                              color: Colors
                                                                  .green[300]),
                                                          Text("Your good side")
                                                        ],
                                                      ),
                                                      trailing: Icon(
                                                          Icons
                                                              .keyboard_arrow_right,
                                                          size: 30.0)),
                                                )),
                                            Divider(
                                              height: 5,
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.sentiment_very_satisfied,
                                                color: Colors.green,
                                                size: 40,
                                              ),
                                              title: Text(
                                                "90%",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                    fontSize: 20),
                                              ),
                                              subtitle: Text("Positive traits"),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                  Icons.sentiment_neutral,
                                                  color: Colors.orange,
                                                  size: 40),
                                              title: Text(
                                                "90%",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange,
                                                    fontSize: 20),
                                              ),
                                              subtitle: Text("Neutral traits"),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                  Icons
                                                      .sentiment_very_dissatisfied,
                                                  color: Colors.red,
                                                  size: 40),
                                              title: Text(
                                                "45%",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                    fontSize: 20),
                                              ),
                                              subtitle: Text("Negative traits"),
                                            ), // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),
                                            Card(
                                                elevation: 8.0,
                                                margin:
                                                    new EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 6.0),
                                                child: Container(
                                                  // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                                                  child: ListTile(
                                                      onTap: () {},
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
                                                          Text(
                                                              " View details of your ratings")
                                                        ],
                                                      ),
                                                      trailing: Icon(
                                                          Icons
                                                              .keyboard_arrow_right,
                                                          size: 30.0)),
                                                )),
                                            PieChart(
                                              dataMap: dataMap,
                                              legendFontColor:
                                                  Colors.blueGrey[900],
                                              legendFontSize: 14.0,
                                              legendFontWeight: FontWeight.w500,
                                              animationDuration:
                                                  Duration(milliseconds: 800),
                                              chartLegendSpacing: 32.0,
                                              chartRadius:
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2.7,
                                              showChartValuesInPercentage: true,
                                              showChartValues: true,
                                              showChartValuesOutside: false,
                                              chartValuesColor:
                                                  Colors.white.withOpacity(0.9),
                                              colorList: colorList,
                                              showLegends: true,
                                              decimalPlaces: 1,
                                            )
                                          ],
                                        );
                                      } else {
                                        return Center(
                                            child: Text("No data at this time.",
                                                style: TextStyle(
                                                    color: Colors.grey)));
                                      }
                                      }
                                      else{
                                          return Center(
                                            child: Text("Please wait...",
                                                style: TextStyle(
                                                    color: Colors.grey)));
                                      }
                                    },
                                  );
                                } else {
                                  return Center(
                                      child: Text(
                                    "No data at this time.",
                                    style: TextStyle(color: Colors.grey),
                                  ));
                                }
                              });
                        } else {
                          return Center(
                              child: Column(
                            children: <Widget>[
                              Text(
                                "You must enter your Phone Number and your gender to for your account to be active.",
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey),
                              ),
                              MaterialButton(
                                child: Text(
                                  "Start",
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Colors.red,
                                onPressed: () {
                                  phoneNumberRequestDialog(
                                      context,
                                      "Phone number and gender",
                                      "Please enter your phone number and your gender, this is only done once. Note that your phone number must include the the country code without the plus sign, without spaces. E.g 2348000000000",
                                      "OK");
                                },
                              )
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
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              forceElevated: true,
              elevation: 0.0,
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: Colors.red,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                title: FutureBuilder<FirebaseUser>(
                    future: FirebaseAuth.instance.currentUser(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Row(
                          children: <Widget>[
                            AvatarGlow(
                              startDelay: Duration(milliseconds: 1000),
                              glowColor: Colors.orange,
                              endRadius: 40.0,
                              duration: Duration(milliseconds: 2000),
                              repeat: true,
                              showTwoGlows: true,
                              repeatPauseDuration: Duration(microseconds: 100),
                              child: Material(
                                elevation: 8.0,
                                shape: CircleBorder(),
                                child: CircleAvatar(
                                  backgroundColor: Colors.green[100],
                                  backgroundImage:
                                      NetworkImage(snapshot.data.photoUrl),
                                  // CachedNetworkImage(
                                  //   imageUrl: snapshot.data.photoUrl,
                                  //   height: 60,
                                  //   placeholder: (context, url) =>
                                  //       new CircularProgressIndicator(),
                                  //   errorWidget: (context, url, error) =>
                                  //       new Icon(Icons.error),
                                  // ),
                                  radius: 20.0,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(snapshot.data.displayName,
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
                background: Image.asset('assets/background.png'),
              ),
            )
          ];
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(RATING_UI);
        },
        tooltip: 'rate',
        backgroundColor: Colors.red,
        child: Icon(Icons.rate_review),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
