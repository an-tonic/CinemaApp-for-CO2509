import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import  'home_page.dart';
import 'search_page.dart';
import 'favourites_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _pages = [
    HomePage(), // Example content for the Home Page
    SearchPage(), // Example content for the Search Page
    FavPage(), // Example content for the Favorites Page
  ];



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
        //title: Text('My App'),
      //),
      body: Stack(
        children: [
          // Page content
          Positioned.fill(
            child: _pages[_selectedIndex],
          ),
          // Bottom navigation bar
          Positioned(

            left: 0,
            right: 0,
            bottom: 0,
            child: Container(

              decoration: BoxDecoration(

                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0),
                    //Colors.blue.withOpacity(0.5),// Adjust opacity as needed
                    Colors.blue.withOpacity(1), // Adjust opacity as needed
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,

                iconSize: 30,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    backgroundColor: Colors.transparent,
                    icon: Icon(Icons.home),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bookmarks),
                    label: '',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.white70,
                unselectedItemColor: Colors.white30,
                onTap: _onItemTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

