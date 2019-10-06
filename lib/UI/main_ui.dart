import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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
        body: Center(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: true,
              pinned: true,
              elevation: 0.0,
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: Colors.red,
              flexibleSpace: FlexibleSpaceBar(
                title: FutureBuilder<FirebaseUser>(
                  future: FirebaseAuth.instance.currentUser(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                        Row(
                  children: <Widget>[
                   Card(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(100.0)),
                          elevation: 10,
                          color: Colors.blue,
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data.photoUrl,
                            placeholder: (context, url) => new CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>   new Icon(Icons.error),
                          ),

                          //  Image.network(snapshot.data.photoUrl).image)
                        ),
                      
                    Text(
                      snapshot.data.displayName,
                      style: TextStyle(color: Colors.white, fontSize: 16.0,fontFamily: 'Quicksand')
                    ),
                  ],
                );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return CircularProgressIndicator();
                  },
                ),

          

                background: Image.asset('assets/background.png'),
              ),
            )
          ];
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
