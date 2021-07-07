import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static String screenKey = 'Registration_Screen_Key';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email, password, confirmPassword;
  FirebaseAuth _auth;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeFireBase();
  }

  void initializeFireBase() async {
    await Firebase.initializeApp();
    print('Done');
    _auth = FirebaseAuth.instance;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Error!',
        ),
        content: Text(
          message,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              'OK',
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: Hero(
                tag: 'Logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
              //style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
              onChanged: (value) {
                email = value;
              },
              decoration: docurationTextField.copyWith(
                hintText: 'Enter your email',
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              //style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
              obscureText: true,
              onChanged: (value) {
                password = value;
              },
              decoration: docurationTextField.copyWith(
                hintText: 'Enter your password',
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              //style: TextStyle(color: Colors.black),
              obscureText: true,
              textAlign: TextAlign.center,
              onChanged: (value) {
                confirmPassword = value;
              },
              decoration: docurationTextField.copyWith(
                hintText: 'Confirm your password',
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () async {
                    if (password != confirmPassword) {
                      _showErrorDialog(
                          'Please confirm your password correctly!');
                    } else if (password.length < 6) {
                      _showErrorDialog(
                          'Your password is too short please enter a stronger one!');
                    } else if (!email.contains('@') ||
                        !email.contains('.com')) {
                      _showErrorDialog(
                          'This is a wrong email pleas enter a correct one!');
                    } else {
                      print(!email.contains('.com'));
                      print(!email.contains('@'));
                      try {
                        setState(() {
                          isLoading = true;
                        });
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        isLoading = false;
                        if (newUser != null) {
                          Navigator.of(context).pushNamed(ChatScreen.screenKey);
                        }
                      } catch (e) {
                        _showErrorDialog(e.toString().split(']')[1].trim());
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
