import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
  double previousScale = 1.0;

  @override
  initState() {
    uid = FirebaseAuth.instance.currentUser!.uid;
    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween =
        ColorTween(begin: Colors.blue.shade900, end: Colors.red.shade900)
            .animate(_colorAnimationController);

    fetchFavoriteMovies();

    super.initState();
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    super.dispose();
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

    // Fetch details for each favorite movie ID
    for (String id in movieIds) {
      String url = 'https://api.themoviedb.org/3/movie/$id';
      Map<String, dynamic> movieResponse = await getURL(url, context);

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

  void _onScaleUpdate(double scale) {
    // Execute the scale update logic after the debounce duration
    double averageScale = (scale + previousScale) / 2;
    if (averageScale > previousScale && crossAxisCountUser > 2) {
      // Scale up, decrease crossAxisCount
      crossAxisCountUser--;
    }
    if (averageScale < previousScale && crossAxisCountUser < 5) {
      // Scale down, increase crossAxisCount
      crossAxisCountUser++;
    }
    previousScale = scale;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        _onScaleUpdate(details.scale);
      },
      child: Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: _scrollListener,
          child: AnimatedBuilder(
            animation: _colorAnimationController,
            builder: (context, child) => Stack(
              children: [
                Container(
                  color: _colorTween.value,
                ),
                GridView.builder(
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildGridItem(
    BuildContext context, var result, void Function(int movieID) submit) {
  dynamic posterPath = result['poster_path'];
  String imageUrl = 'https://image.tmdb.org/t/p/w342/$posterPath';

  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: Stack(
          fit: StackFit.expand,
          children: [
            RoundNetImage(imageUrl),
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
