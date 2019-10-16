import 'package:admob_flutter/admob_flutter.dart';
import 'package:behavio/Constants/repository.dart';
import 'package:behavio/firebase/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:native_contact_picker/native_contact_picker.dart';
import 'package:uuid/uuid.dart';

class RatingUI extends StatefulWidget {
  @override
  _RatingUIState createState() => _RatingUIState();
}

class _RatingUIState extends State<RatingUI> {
  var _phoneNumberController = TextEditingController();
  var _commentController = TextEditingController();
  double _rating = 1.0;
  double _userRating = 3.0;
  int _ratingBarMode = 1;
  bool _isRTLMode = false;
  bool _isVertical = false;
  IconData _selectedIcon;
  String trait;
  String traitCategory;
  bool _loading = false;
  List<String> positiveTraits = ["Select..."];
  List<String> negativeTraits = ["Select..."];
  List<String> neutralTraits = ["Select..."];
  List<String> filteredTrailts = ["Select..."];
  Repository repo = Repository();
  AdmobInterstitial interstitialAd;

  @override
  void initState() {
    positiveTraits = List.from(positiveTraits)..addAll(repo.getPositive());
    negativeTraits = List.from(negativeTraits)..addAll(repo.getNegative());
    neutralTraits = List.from(neutralTraits)..addAll(repo.getNeutral());
    // traitCategory="Positive";
    // filteredTrailts=positiveTraits;
    // _ratingController.text = "3.0";
    interstitialAd = AdmobInterstitial(
      adUnitId: "ca-app-pub-2109400871305297/1330853228",
      // adUnitId: "ca-app-pub-3940256099942544/1033173712", //Test
    );
    interstitialAd.load();

    super.initState();
    authService.loading.listen((state) {
      if (mounted) {
        setState(() => _loading = state);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    interstitialAd.dispose();
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

  void welcomeMessage(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AssetGiffyDialog(
              image: Image.asset('assets/style1.png'),
              title: Text(
                'Rating submitted successfully',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
              ),
              description: Text(
                'Your  rating has been submitted successfully, thank you for doing this.',
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
              onOkButtonPressed: () async {
                Navigator.of(context).pop();
                if (await interstitialAd.isLoaded) {
                  interstitialAd.show();
                }
              },
              onlyOkButton: true,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('New Rating'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.white,
            onPressed: () async {
              _selectedIcon = await showDialog<IconData>(
                context: context,
                builder: (context) => IconAlert(),
              );
              _ratingBarMode = 1;
              setState(() {});
            },
          ),
        ],
      ),
      body: _loading
          ? new Center(
              child: CircularProgressIndicator(),
            )
          : Directionality(
              textDirection: _isRTLMode ? TextDirection.rtl : TextDirection.ltr,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 40.0,
                    ),
                    _heading('New Rating'),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter Phone Number",
                          labelText: "Enter Phone Number",
                          suffixIcon: MaterialButton(
                            onPressed: () async {
                              NativeContactPicker _contactPicker =
                                  new NativeContactPicker();
                              Contact contact =
                                  await _contactPicker.selectContact();
                              setState(() {
                                // _userRating =
                                //     double.parse(_ratingController.text ?? "0.0");
                                _phoneNumberController.text =
                                    contact.phoneNumber;
                              });
                            },
                            child: Text("pick from contact"),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButtonFormField<String>(
                        // controller: _ratingController,
                        // keyboardType: TextInputType.phone,
                        value: traitCategory,
                        onChanged: (String newValue) {
                          setState(() {
                            if (newValue != null) {
                              traitCategory = newValue;
                              if (newValue == "Positive") {
                                print(newValue);
                                trait = "Select...";
                                filteredTrailts = positiveTraits;
                              } else if (newValue == "Negative") {
                                print(newValue);
                                trait = "Select...";

                                filteredTrailts = negativeTraits;
                              } else if (newValue == "Neutral") {
                                print(newValue);
                                trait = "Select...";

                                filteredTrailts = neutralTraits;
                              }
                            }
                          });
                        },
                        items: <String>['Positive', 'Negative', 'Neutral']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Select trait category",
                          labelText: "Select trait category",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButtonFormField<String>(
                        // controller: _ratingController,
                        // keyboardType: TextInputType.phone,
                        value: trait,
                        onChanged: (String newValue) {
                          setState(() {
                            if (newValue != null) {
                              trait = newValue;
                            }
                          });
                        },
                        items: filteredTrailts
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Select trait",
                          labelText: "Select trait",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    _heading('Rate'),
                    _ratingBar(_ratingBarMode),
                    SizedBox(
                      height: 20.0,
                    ),
                    _rating != null
                        ? Text(
                            "Rating: $_rating",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        : Container(),
                    SizedBox(
                      height: 40.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextFormField(
                        controller: _commentController,
                        keyboardType: TextInputType.text,
                        maxLines: 8,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter comment",
                          labelText: "Enter comment",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    MaterialButton(
                      child: Text(
                        "Submit your rating",
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      color: Colors.red,
                      height: 50,
                      onPressed: () async {
                        print("Heelllo ");

                        if (_phoneNumberController.text == "" ||
                            _phoneNumberController.text == null ||
                            _phoneNumberController.text.contains("+") ||
                            _phoneNumberController.text.contains(" ")) {
                          messageDialogBox(
                              context,
                              "Input Error",
                              "You must enter a phone Number preceeded with the country code without the plus sign, without spaces. e.g 2348000000000",
                              "OK");
                        } else if (trait == "Select..." ||
                            trait == "" ||
                            trait == null ||
                            traitCategory == null ||
                            traitCategory == null) {
                          messageDialogBox(context, "Input Error",
                              "You must select trait", "OK");
                        } else if (_rating == null) {
                          messageDialogBox(context, "Input Error",
                              "You must select your rating", "OK");
                        } else {
                          FirebaseUser user =
                              await FirebaseAuth.instance.currentUser();
                          print("Heelllo " + user.uid);

                          bool duplicateResult =
                              await authService.isDuplicateRating(
                                  _phoneNumberController.text, user, trait);
                          // print("Heelllo " + duplicateResult.toString()+" "+_phoneNumberController.text;

                          bool result = await authService.isSelfRating(
                              _phoneNumberController.text, user);
                          if (result) {
                            messageDialogBox(context, "Self rating not allowed",
                                "Sorry, you cannot rate yourself.", "OK");
                          } else if (duplicateResult) {
                            print("Duplicate Result: " +
                                duplicateResult.toString());
                            messageDialogBox(
                                context,
                                "Duplicate rating not allowed",
                                "Sorry, you are not allowed to rate same trait of the same person more than once.",
                                "OK");
                          } else {
                            // print(duplicateResult.toString());
                            var uuid = new Uuid();
                            var ratingId = uuid.v4();
                            authService.rate(
                                user,
                                _phoneNumberController.text,
                                trait,
                                _rating,
                                _commentController.text,
                                ratingId,
                                traitCategory);
                            _phoneNumberController.text = "";
                            _commentController.text = "";
                            _rating = 3;
                            trait = "Select...";
                            // traitCategory = "";
                            welcomeMessage(context);
                          }
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _radio(int value) {
    return Expanded(
      child: RadioListTile(
        value: value,
        groupValue: _ratingBarMode,
        dense: true,
        title: Text(
          'Mode $value',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 12.0,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _ratingBarMode = value;
          });
        },
      ),
    );
  }

  Widget _ratingBar(int mode) {
    switch (mode) {
      case 1:
        return RatingBar(
          initialRating: 1.0,
          direction: _isVertical ? Axis.vertical : Axis.horizontal,
          allowHalfRating: true,
          unratedColor: Colors.grey[200],
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            _selectedIcon ?? Icons.star,
            color: Colors.red,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
          },
        );
      case 2:
        return RatingBar(
          initialRating: 3,
          direction: _isVertical ? Axis.vertical : Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          ratingWidget: RatingWidget(
            full: _image('assets/heart.png'),
            half: _image('assets/heart_half.png'),
            empty: _image('assets/heart_border.png'),
          ),
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
          },
        );
      case 3:
        return RatingBar(
          initialRating: 3,
          direction: _isVertical ? Axis.vertical : Axis.horizontal,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return Icon(
                  Icons.sentiment_very_dissatisfied,
                  color: Colors.red,
                );
              case 1:
                return Icon(
                  Icons.sentiment_dissatisfied,
                  color: Colors.redAccent,
                );
              case 2:
                return Icon(
                  Icons.sentiment_neutral,
                  color: Colors.amber,
                );
              case 3:
                return Icon(
                  Icons.sentiment_satisfied,
                  color: Colors.lightGreen,
                );
              case 4:
                return Icon(
                  Icons.sentiment_very_satisfied,
                  color: Colors.green,
                );
              default:
                return Container();
            }
          },
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
          },
        );
      default:
        return Container();
    }
  }

  Widget _image(String asset) {
    return Image.asset(
      asset,
      height: 30.0,
      width: 30.0,
      color: Colors.amber,
    );
  }

  Widget _heading(String text) => Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 24.0,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      );
}

class IconAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Select Icon',
        style: TextStyle(
          fontWeight: FontWeight.w300,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      titlePadding: EdgeInsets.all(12.0),
      contentPadding: EdgeInsets.all(0),
      content: Wrap(
        children: [
          _iconButton(context, Icons.home),
          _iconButton(context, Icons.airplanemode_active),
          _iconButton(context, Icons.euro_symbol),
          _iconButton(context, Icons.beach_access),
          _iconButton(context, Icons.attach_money),
          _iconButton(context, Icons.music_note),
          _iconButton(context, Icons.android),
          _iconButton(context, Icons.toys),
          _iconButton(context, Icons.language),
          _iconButton(context, Icons.landscape),
          _iconButton(context, Icons.ac_unit),
          _iconButton(context, Icons.star),
        ],
      ),
    );
  }

  _iconButton(BuildContext context, IconData icon) => IconButton(
        icon: Icon(icon),
        onPressed: () => Navigator.pop(context, icon),
        splashColor: Colors.amberAccent,
        color: Colors.red,
      );
}
