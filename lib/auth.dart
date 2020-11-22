// import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User> user; //firebase user
  Stream<Map<String, dynamic>> profile; //custom user data in Firestore
  PublishSubject loading = PublishSubject();

  //constructor
  AuthService() {
 //   user = Observable(_auth.authStateChanges());
    profile = user.switchMap((User u) {
      if (u != null) {
        return _db
            .collection('users')
            .doc(u.uid)
            .snapshots()
            .map((snap) => snap.data());
      }
      // else {
      //   return Observable.just({});
      // }
    });
  }

  Future<UserCredential> _handleSignIn() async {
    loading.add(true);
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential user = await _auth.signInWithCredential(credential);

    updateUserData(user);
    print("signed in" + user.user.displayName);

    loading.add(false);
    return user;
  }

  void updateUserData(UserCredential user) async {
    DocumentReference ref = _db.collection('users').doc(user.user.uid);

    return ref.set({
      'uid': user.user.uid,
      'email': user.user.email,
      'photoURL': user.user.photoURL,
      'displayName': user.user.displayName,
      'lastSeen': DateTime.now()
    });
  }

  void signOut() {
    _auth.signOut();
  }
}

class Observable {
}

final AuthService authService = AuthService();
