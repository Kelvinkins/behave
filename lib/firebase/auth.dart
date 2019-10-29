import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  // Dependencies

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  // Shared State for Widgets
  Observable<FirebaseUser> user; // firebase user
  Observable<Map<String, dynamic>> profile; // custom user data in Firestore
  PublishSubject loading = PublishSubject();
  final analytics = new FirebaseAnalytics();
  FacebookLogin fbLogin = new FacebookLogin();

  // constructor
  // AuthService() {

  // }
  AuthService() {
    user = Observable(_auth.onAuthStateChanged);

    profile = user.switchMap((FirebaseUser u) {
      if (u != null) {
        return _db
            .collection('users')
            .document(u.uid)
            .snapshots()
            .map((snap) => snap.data);
      } else {
        return Observable.just({});
      }
    });
  }

  Future<String> getUserPhoto(String userId) async {
    loading.add(true);
    final DocumentReference docRef =
        Firestore.instance.document('users/' + userId);
    DocumentSnapshot user = await docRef.get();
    loading.add(false);

    return user.data["photoUrl"];
  }

  Future<String> collectPhoneNumber(
      FirebaseUser user, String phoneNumber, String gender) async {
    String message = "";
    try {
      Firestore.instance.document('users/' + user.uid).updateData({
        'phoneNumber': phoneNumber,
        'gender': gender,
      });
      message = "Thanks for the update!";
    } on PlatformException catch (error) {
      message = "Something went wrong";
    }
    return message;
  }

  Future<bool> userHasPhoneNumber(FirebaseUser user) async {
    var userDocRef = Firestore.instance.document('users/' + user.uid);
    DocumentSnapshot userSnapshot = await userDocRef.get();
    if (userSnapshot.data["phoneNumber"] != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<FirebaseUser> localSignUp(String username, String password,
      String phoneNumber, String gender, String displayName) async {
    AuthResult authResult;

    try {
      loading.add(true);

      authResult = await _auth.createUserWithEmailAndPassword(
          email: username, password: password);
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      userUpdateInfo.displayName = displayName;
      // userUpdateInfo.photoUrl=user.photoUrl;
      if (authResult.additionalUserInfo.isNewUser) {
        await authResult.user.updateProfile(userUpdateInfo);
        // updateUserData(authResult.user, phoneNumber, gender);
      }
      authResult.user.sendEmailVerification();

      loading.add(false);
    } on PlatformException catch (ex) {
      loading.add(false);
    }
    return authResult.user;
  }

  Future<FirebaseUser> signInLocal(String username, String password) async {
    loading.add(true);
    AuthResult authResult;
    try {
      authResult = await _auth.signInWithEmailAndPassword(
          email: username, password: password);

      loading.add(false);
    } on PlatformException catch (ex) {
      user = null;
      loading.add(false);
    }
    return authResult.user;
  }

  updateRecord(document, newValues) {
    Firestore.instance
        .collection("tracks")
        .document(document)
        .updateData(newValues)
        .catchError((onError) {
      print(onError);
    });
  }

  Future<String> shareLink(FirebaseUser user) async {
    String message;
    // int balance = 0;
    String phoneNumber;
    String dynamicLink;

    loading.add(true);
    try {
      // final DocumentReference postRef =
      var docRef = Firestore.instance.document('users/' + user.uid);
      DocumentSnapshot postSnapshot = await docRef.get();
      if (postSnapshot.exists) {
        phoneNumber = postSnapshot.data["phoneNumber"].toString();
        dynamicLink = postSnapshot.data["dynamicLink"];
      }
      if (phoneNumber == null) {
        message = null;
      } else {
        if (dynamicLink == null) {
          final DynamicLinkParameters parameters = DynamicLinkParameters(
            uriPrefix: 'https://behave.page.link',
            link: Uri.parse("http://www.hulia.com.ng/phone?" + phoneNumber),
            androidParameters: AndroidParameters(
              packageName: 'com.hulia.behave',
              // minimumVersion: 125,
            ),
          );
          ShortDynamicLink dynamicUrl = await parameters.buildShortLink();
          message = dynamicUrl.shortUrl.toString();
          Firestore.instance
              .document('users/' + user.uid)
              .updateData({'dynamicLink': message});
          print(message);
          // message = " Successful\n, Reason: " + reasonForCode+"\n Code: " + code ;
        } else {
          message = postSnapshot.data["dynamicLink"].toString();
        }
      }

      loading.add(false);
    } on PlatformException catch (error) {
      loading.add(false);

      message = null;
    }

    return message;
  }

  Future<FirebaseUser> googleSignIn() async {
    // Start
    loading.add(true);
    AuthResult authResult;
    try {
      // Step 1
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();

      // Step 2
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      authResult = await _auth.signInWithCredential(credential);
      if (authResult.additionalUserInfo.isNewUser) {
        UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
        userUpdateInfo.displayName = authResult.user.displayName;
        userUpdateInfo.photoUrl = authResult.user.photoUrl;
        await authResult.user.updateProfile(userUpdateInfo);
        // Step 3
        updateUserData(authResult.user, null, null);
        saveDeviceToken();
      }

      // Done
      loading.add(false);
    } on PlatformException catch (e) {
      loading.add(false);
      user = null;
    }
    return authResult.user;
  }

  Future<FirebaseUser> fbookLogin() async {
    AuthResult authResult;
    // fbLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    // if you remove above comment then facebook login will take username and pasword for login in Webview
    try {
      final FacebookLoginResult facebookLoginResult =
          await fbLogin.logIn(['email', 'public_profile']);
      print(facebookLoginResult.errorMessage);
      if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
        FacebookAccessToken facebookAccessToken =
            facebookLoginResult.accessToken;
        final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: facebookAccessToken.token);

        authResult = await _auth.signInWithCredential(credential);
        if (authResult.additionalUserInfo.isNewUser) {
          UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
          userUpdateInfo.displayName = authResult.user.displayName;
          userUpdateInfo.photoUrl = authResult.user.photoUrl;
          await authResult.user.updateProfile(userUpdateInfo);
          // Step 3
          updateUserData(authResult.user, null, null);
          saveDeviceToken();
        }
      }
    } catch (e) {
      print(e);

      return authResult.user;
    }
    return authResult.user;
  }

  void updateUserData(
      FirebaseUser user, String phoneNumber, String gender) async {
    DocumentReference ref = _db.collection('users').document(user.uid);
    loading.add(true);
    ref.setData({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'lastSeen': DateTime.now(),
      'gender': gender,
      'phoneNumber': phoneNumber
    }, merge: true);
    loading.add(false);
  }

  void rate(FirebaseUser user, String phoneNumber, String trait, double rating,
      String comment, String ratingId, String traitCategory) async {
    DocumentReference ref = _db
        .collection("ratings")
        .document(phoneNumber)
        .collection("myratings")
        .document(ratingId);
    loading.add(true);
    try {
      ref.setData({
        'ratedByUid': user.uid,
        'rateBydisplayName': user.displayName,
        'ratedOn': DateTime.now(),
        'trait': trait,
        'rating': rating,
        'comment': comment,
        'category': traitCategory
      }, merge: true);
      loading.add(false);
    } on PlatformException catch (ex) {
      loading.add(false);
    }
  }

  void saveDeviceToken() async {
    String fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      Firestore.instance.document('users/' + user.uid).updateData({
        'deviceToken': fcmToken,
        'platform': Platform.operatingSystem,
        'platformVersion': Platform.operatingSystemVersion,
        'lastSeen': DateTime.now()
      });
    }
  }

  // Future<bool> sendChatNotification(
  //     String message, String messageContent, String deviceToken) async {
  //   FirebaseUser user = await FirebaseAuth.instance.currentUser();
  //   // final DocumentReference docRef =
  //   //     Firestore.instance.document('users/' + uid);
  //   // DocumentSnapshot token = await docRef.get();

  //   final postUrl = 'https://fcm.googleapis.com/fcm/send';
  //   final data = {
  //     "to": deviceToken,
  //     "notification": {
  //       "title": message,
  //       "body": user.displayName + messageContent,
  //       "click_action": 'FLUTTER_NOTIFICATION_CLICK',
  //     }
  //   };
  //   final headers = {
  //     "content-type": 'application/json',
  //     "Authorization":
  //         'key=AAAAqRdhNNY:APA91bG1b1Ihq-CfyczbUBuiR0C4RHaVV4m_qHHqsWig_16-5QZptWkas89-1SNlJNhTjPnr3KjzlefnKkzjra9IoRfEeBgxXgikNQihkrxyB4kzKCvmP6UdgvGnR0SrCD7sP3i18eSW'
  //   };
  //   final response = await http.post(
  //     postUrl,
  //     body: json.encode(data),
  //     encoding: Encoding.getByName("utf-8"),
  //     headers: headers,
  //   );

  //   if (response.statusCode == 200) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  Future<bool> PanicSignal(bool panicing) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance.document('users/' + user.uid).updateData({
      'lastSeen': DateTime.now(),
      'panicing': panicing,
    });
    return true;
  }

  bool delegateTrustCircleCheckHelper(String userId) {
    bool delegateResult = false;
    existInTrustCircle(userId).then((bool result) {
      delegateResult = result;
    });
    return delegateResult;
  }

  Future<bool> existInTrustCircle(String userId) async {
    bool result = false;

    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      DocumentSnapshot trustCircleUser = await _db
          .collection('users')
          .document(user.uid)
          .collection("trustCircle")
          .document(userId)
          .get();
      if (trustCircleUser.exists) {
        result = true;
      } else {
        result = false;
      }
    } on PlatformException catch (error) {
      return false;
    }
    return result;
  }

  Future<bool> removeFromTrustCircle(String userId) async {
    bool result = false;
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      final DocumentReference docRef =
          Firestore.instance.document('users/' + userId);
      DocumentSnapshot trustCircleUser = await docRef.get();
      if (trustCircleUser.exists) {
        DocumentReference ref = _db
            .collection('users')
            .document(user.uid)
            .collection("trustCircle")
            .document(userId);
        ref.delete();
        result = true;
      } else {
        result = false;
      }
      return result;
    } on PlatformException catch (ex) {
      return false;
    }
  }

  Future<bool> isSelfRating(String phoneNumber, FirebaseUser user) async {
    bool result = false;
    try {
      final DocumentReference docRef =
          Firestore.instance.document('users/' + user.uid);
      DocumentSnapshot userDs = await docRef.get();
      if (userDs.exists) {
        if (phoneNumber == userDs.data["phoneNumber"].toString()) {
          result = true;
        } else {
          result = false;
        }
      }
      return result;
    } on PlatformException catch (err) {
      return true;
    }
  }

  Future<bool> isDuplicateRating(
      String phoneNumber, FirebaseUser user, String trait) async {
    bool result = false;
    try {
      // final DocumentReference docRef =
      //     Firestore.instance.document('users/' + user.uid);
      Query ref = Firestore.instance
          .collection("ratings")
          .document(phoneNumber)
          .collection("myratings")
          .where("ratedByUid", isEqualTo: user.uid)
          .where("trait", isEqualTo: trait);
      // DocumentSnapshot userDs = await ref.;
      QuerySnapshot qs = await ref.getDocuments();
      if (qs.documents.length > 0) {
        result = true;
      } else {
        result = false;
      }
      return result;
    } on PlatformException catch (err) {
      return true;
    }
  }

  Future<bool> addToTrustCircle(String userId, String displayName) async {
    bool result = false;
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      final DocumentReference docRef =
          Firestore.instance.document('users/' + userId);
      DocumentSnapshot trustCircleUser = await docRef.get();
      if (trustCircleUser.exists) {
        DocumentReference ref = _db
            .collection('users')
            .document(user.uid)
            .collection("trustCircle")
            .document(userId);
        ref.setData({
          'userId': userId,
          'email': trustCircleUser.data["email"],
          'phoneNumber': trustCircleUser.data["phoneNumber"],
          'deviceToken': trustCircleUser.data["deviceToken"],
          'photoUrl': trustCircleUser.data["photoUrl"],
          'dateAdded': DateTime.now(),
          'displayName': displayName
        });
        result = true;
      } else {
        result = true;
      }
      return result;
    } on PlatformException catch (ex) {
      return false;
    }
  }

  Future signOut() async {
    await _auth.signOut();
    await fbLogin.logOut();
  }
}

final AuthService authService = AuthService();
