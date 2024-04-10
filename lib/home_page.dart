import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'feed_page.dart';
import 'search_page.dart';
import 'favourites_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> with TickerProviderStateMixin  {
  int _selectedIndex = 0;
  late DatabaseReference _db;
  final List<Widget> _pages = [];
  late AnimationController _colorAnimationController;
  late Animation _colorTween;



  @override
  void initState() {
    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween =
        ColorTween(begin: Colors.blue.shade900, end: Colors.red.shade900)
            .animate(_colorAnimationController);
    _db =  FirebaseDatabase.instance.ref();
  
    super.initState();
  }

  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.depth == 0) {
      _colorAnimationController.animateTo(
          scrollInfo.metrics.pixels / scrollInfo.metrics.maxScrollExtent);
    }
    return true;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _submit(int? movieID) async {
    var uid = FirebaseAuth.instance.currentUser?.uid;

    // Perform action only if movieID is not null and uid is not null
    if (movieID != null && uid != null) {
      _db.child('favorite_movie_id').child(uid).child(movieID.toString()).set('');
    }
  }


  @override
  Widget build(BuildContext context) {
    _pages.addAll([
      FeedPage(_submit, _scrollListener),
      SearchPage(_submit, _scrollListener),
      FavPage(_db, _scrollListener),
    ]);
  
    return Scaffold(
      backgroundColor: _colorTween.value,
      body: AnimatedBuilder(
        animation: _colorAnimationController,
        builder: (context, child) => Stack(
          children: [
            Container(
              color: _colorTween.value,
            ),
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
                      Colors.blue.withOpacity(1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,

                  iconSize: 30,
                  items:  const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(

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
      ),
    );
  }
}

