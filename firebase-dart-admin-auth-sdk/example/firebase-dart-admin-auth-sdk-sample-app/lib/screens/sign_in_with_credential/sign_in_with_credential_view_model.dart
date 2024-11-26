import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase/utils/platform_provider.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../home_screen/home_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class SignInWithCredentialViewModel extends ChangeNotifier {
  List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: scopes,
  );

  bool loading = false;
  void setLoading(bool load) {
    loading = load;
    notifyListeners();
  }

  Future<void> signInWithCredential(VoidCallback onSuccess) async {
    try {
      setLoading(true);

      var signInAccount = await _googleSignIn.signIn();

      var signInAuth = await signInAccount?.authentication;

      if (signInAuth == null) {
        throw Exception("Something went wrong");
      }

      OAuthCredential credential = OAuthCredential(
        providerId: getPlatformId(),
        accessToken: signInAuth.accessToken,
        idToken: signInAuth.idToken,
      );

      await FirebaseApp.firebaseAuth?.signInWithCredential(credential);

      onSuccess();
    } catch (e) {
      BotToast.showText(text: e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> loginWithFacebook(BuildContext context) async {
    final LoginResult result =
        await FacebookAuth.instance.login(); // Trigger the sign-in flow
    log("12345result $result");
    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;

      try {
        var user1 = await FirebaseApp.firebaseAuth?.signInWithRedirect(
            'http://localhost', accessToken.token, 'facebook.com');

        BotToast.showText(text: '${user1?.user.email} just linked in11');

        if (user1 != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ));
        }
      } catch (e) {
        BotToast.showText(text: e.toString());
      }
      // Use this token to authenticate with your backend or Firebase
    } else if (result.status == LoginStatus.cancelled) {
      log('Login cancelled');
    } else {
      log('Facebook login failed: ${result.message}');
    }
  }

  void showError(dynamic ex, BuildContext context) {
    showMessage(ex.toString(), context);
  }

  void showMessage(String text, BuildContext context) {
    var alert = AlertDialog(content: Text(text), actions: <Widget>[
      TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }
}
