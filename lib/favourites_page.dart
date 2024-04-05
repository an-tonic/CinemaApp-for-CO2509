import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'util_cinema.dart';

class FavPage extends StatefulWidget {
  final DatabaseReference db;

  const FavPage(this.db, {Key? key}) : super(key: key);

  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> with TickerProviderStateMixin {
  List<dynamic> _favoriteMovies = [];
  late AnimationController _colorAnimationController;
  late Animation _colorTween;
  late String uid;
  int crossAxisCountUser = 2;
  double previousScale = 0.0;
  late SharedPreferences _prefs;

  @override
  initState() {
    uid = FirebaseAuth.instance.currentUser!.uid;
    _colorAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 0));
    _colorTween =
        ColorTween(begin: Colors.blue.shade900, end: Colors.red.shade900)
            .animate(_colorAnimationController);

    fetchFavoriteMovies();
    _initPrefs();
    super.initState();
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    _savePrefs();
    super.dispose();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      crossAxisCountUser = _prefs.getInt('crossAxisCountUser') ?? 2;
    });
  }

  Future<void> _savePrefs() async {
    await _prefs.setInt('crossAxisCountUser', crossAxisCountUser);
  }

  void _submit(int movieID) {
    widget.db
        .child('favorite_movie_id')
        .child(uid)
        .child(movieID.toString())
        .remove();
    setState(() {
      _favoriteMovies.removeWhere((movie) => movie['id'] == movieID);
    });
  }

  void fetchFavoriteMovies() async {
    // Fetch the IDs of favorite movies from the database
    DataSnapshot snapshot =
        await widget.db.child('favorite_movie_id').child(uid).get();
    List<String> movieIds = [];

    if (snapshot.value != null) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      movieIds = data.keys.toList().cast<String>();
    }

    List favoriteMovies = [];

    for (String id in movieIds) {
      String url = 'https://api.themoviedb.org/3/movie/$id';

      Map<String, dynamic> movieResponse = await getURL(url);

      if (movieResponse.containsKey('id')) {
        favoriteMovies.add(movieResponse);
      }
    }

    setState(() {
      _favoriteMovies = favoriteMovies;
    });
  }

  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.maxScrollExtent == 0) {
      return true;
    }
    _colorAnimationController.animateTo(
        scrollInfo.metrics.pixels / scrollInfo.metrics.maxScrollExtent);
    return false;
  }
  bool stopScale = false;

  void _onScaleUpdate(double scale) {

    if(scale == 1.0 || stopScale){
      return;
    }

    if (previousScale != 0) {
      if (scale > previousScale && crossAxisCountUser > 2) {
        setState(() {
          stopScale = true;
          crossAxisCountUser--;
        });
      } else if (scale < previousScale && crossAxisCountUser < 5) {
        setState(() {
          stopScale = true;
          crossAxisCountUser++;
        });
      }
    }

    previousScale = scale;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: _scrollListener,
        child: AnimatedBuilder(
          animation: _colorAnimationController,
          builder: (context, child) => Stack(
            children: [
              Container(
                color: _colorTween.value,
              ),
              GestureDetector(
                onScaleUpdate: (details) {
                  _onScaleUpdate(details.scale);
                },
                onScaleEnd: (details){
                  stopScale = false;

                  previousScale = 0;
                },
                // onScaleEnd: (details) => previousScale = 0,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCountUser,
                    mainAxisSpacing: 0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _favoriteMovies.length,
                  itemBuilder: (context, index) {
                    return _buildGridItem(
                        context, _favoriteMovies[index], _submit);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildGridItem(
    BuildContext context, var result, void Function(int movieID) submit) {
  dynamic posterPath = result['poster_path'];

  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: Stack(
          fit: StackFit.expand,
          children: [
            RoundNetImage(posterPath, "342"),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                iconSize: 30,
                icon: const Icon(Icons.bookmark),
                onPressed: () {
                  submit(result['id']);
                },
              ),
            )
          ],
        ),
      ),
    ),
  );
}
