import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google';
import 'package:google_sign_in/google_sign_in.dart';

import '../../widgets/chat/auth_form.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;
  void _submitAuthForm(
    String email,
    String password,
    String username,
    // File image,
    var isSignIn,
    BuildContext ctx,
  ) async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isSignIn) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        print('authResut: $authResult');
        // final ref = FirebaseStorage.instance
        //     .ref() //access root clould strage
        //     .child('user_image') //sub folder
        //     .child(authResult.user.uid + '.jpg'); //filename

        // await ref.putFile(image).onComplete;

        // final url = await ref.getDownloadURL();

        // await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(authResult.user.uid)
        //     .set({
        //   'username': username,
        //   'email': email,
        //   'image_url':url,
        // });
      }
    } catch (err) {
      print(err.message);
      if (err != null) {
        Scaffold.of(ctx).showSnackBar(
          SnackBar(
            content: Text(err.message),
            backgroundColor: Theme.of(ctx).errorColor,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle(BuildContext ctx) async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });
    // model.state =ViewState.Busy;
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
      authResult = await _auth.signInWithCredential(credential);
    User _user = authResult.user;
    assert(!_user.isAnonymous);
    assert(await _user.getIdToken() != null);
    // User currentUser = await _auth.currentUser();
    User currentUser = _auth.currentUser;
    assert(_user.uid == currentUser.uid);
    // model.state = ViewState.Idle;
    print("User Name: ${_user.displayName}");
    print("User Email ${_user.email}");
    }
    catch (err) {
      print(err.message);
      if (err != null) {
        Scaffold.of(ctx).showSnackBar(
          SnackBar(
            content: Text(err.message),
            backgroundColor: Theme.of(ctx).errorColor,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _signInWithGoogle, _isLoading),
    );
  }
}
