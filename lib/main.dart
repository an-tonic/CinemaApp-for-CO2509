import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'registration_page.dart';
import 'home_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return MaterialApp(
            navigatorKey: navigatorKey,
            initialRoute: snapshot.data ?? '/',
            routes: {
              '/': (context) => LoginPage(),
              '/register': (context) => RegistrationPage(),
              '/home': (context) => const HomePage(),
            },
          );
        }
      },
    );
  }

  Future<String> _getInitialRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? userIsLogged = prefs.getBool('userIsLogged');
    if (userIsLogged == true) {
      return '/home';
    } else {
      return '/';
    }
  }
}
