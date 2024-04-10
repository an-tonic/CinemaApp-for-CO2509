import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'util_cinema.dart';

class FavPage extends StatefulWidget {
  final DatabaseReference db;
  final bool Function(ScrollNotification scrollInfo) scrollListener;

  const FavPage(this.db,this.scrollListener,  {Key? key}) : super(key: key);

  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  List<dynamic> _favoriteMovies = [];

  late String uid;
  int crossAxisCountUser = 2;
  double previousScale = 0.0;
  late SharedPreferences _prefs;

  @override
  initState() {
    uid = FirebaseAuth.instance.currentUser!.uid;

    fetchFavoriteMovies();
    _initPrefs();
    super.initState();
  }

  @override
  void dispose() {
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


  bool stopScale = false;

  void _onScaleUpdate(double scale) {
    if (scale == 1.0 || stopScale) {
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
      backgroundColor: Colors.transparent,
      body: NotificationListener<ScrollNotification>(
        onNotification: widget.scrollListener,
        child: Stack(
          children: [
            GestureDetector(
              onScaleUpdate: (details) {
                _onScaleUpdate(details.scale);
              },
              onScaleEnd: (details) {
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
            BookmarkMovie(() {
              submit(result['id']);
            })
          ],
        ),
      ),
    ),
  );
}
