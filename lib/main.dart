import 'package:flutter/material.dart';
import './screens/welcome_screen.dart';
import './screens/login_screen.dart';
import './screens/registration_screen.dart';
import './screens/chat_screen.dart';

void main() async {
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyText2: TextStyle(
            color: Colors.black54,
          ),
        ),
      ),
      initialRoute: WelcomeScreen.screenKey,
      routes: {
        ChatScreen.screenKey: (context) => ChatScreen(),
        LoginScreen.screenKey: (context) => LoginScreen(),
        RegistrationScreen.screenKey: (context) => RegistrationScreen(),
        WelcomeScreen.screenKey: (context) => WelcomeScreen(),
      },
    );
  }
}
