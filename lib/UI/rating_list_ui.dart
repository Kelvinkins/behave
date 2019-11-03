import 'dart:async';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// import 'package:behavio/models/asset.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share/share.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';

// import 'assetEnrollment.dart';

class RatingList extends StatefulWidget {
  @override
  _RatingListState createState() => new _RatingListState();
  RatingList({this.phoneNumber});
  final String phoneNumber;
  final FirebaseAuth _auth = FirebaseAuth.instance;
}

class _RatingListState extends State<RatingList>
    with AutomaticKeepAliveClientMixin<RatingList> {
  // List<Item> _items = [];
  @override
  bool get wantKeepAlive => true;

  // int _selectedIndex = 1;

  // List<Asset> assets;
  StreamSubscription<QuerySnapshot> allTracks;
  ScrollController scrollController;
  bool dialVisible = true;
  TextEditingController txtBlockStatus = new TextEditingController();
  TextEditingController txtTracksBlockStatus = new TextEditingController();

  @override
  void initState() {
    super.initState();
    txtBlockStatus.text = "Block";
    txtTracksBlockStatus.text = "Block";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.1,
          backgroundColor: Colors.white,
          title: Text(
            "Rating Details",
            style: TextStyle(color: Colors.red),
          ),
          iconTheme: IconThemeData(color: Colors.red),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection("ratings")
              .document(widget.phoneNumber)
              .collection("myratings")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                return new ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return Card(
                        elevation: 1.0,
                        margin: new EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0),
                        child: Container(
                            // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                            child: Column(children: <Widget>[
                          Text(
                            document['trait'],
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          document['comment'].toString() != "" &&
                                  document['comment'].toString() != null
                              ? Text(document['comment'])
                              : Text("No comment",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic)),
                          Text(
                              DateFormat("dd-MM-yy hh:mm")
                                  .format(document["ratedOn"].toDate()),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic)),
                          Row(
                            children: <Widget>[
                              Text(document['category']),
                              // IconButton(
                              //   icon: Icon(
                              //     Icons.report_problem,
                              //     color: Colors.red,
                              //   ),
                              //   onPressed: () {},
                              // ),
                              IconButton(
                                icon: Icon(
                                  Icons.share,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  Share.share(document["category"].toString() +
                                      ":" +
                                      document["trait"].toString()+":"+document['comment'].toString());
                                },
                              )
                            ],
                          ),
                        
                        ])));
                  }).toList(),
                );
            }
          },
        ),
        bottomNavigationBar:       AdmobBanner(
              adSize: AdmobBannerSize.BANNER,
              //  adUnitId: "ca-app-pub-3940256099942544/6300978111",
              adUnitId: "ca-app-pub-2109400871305297/8189218691",
            ),
        );
  }
}
