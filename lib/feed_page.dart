import 'package:flutter/material.dart';
import 'util_cinema.dart';

class FeedPage extends StatefulWidget {
  final void Function(int movieID) pushFavMovFirebase;

  const FeedPage(this.pushFavMovFirebase, {Key? key}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with TickerProviderStateMixin {
  late Future<List<dynamic>> _fetchMoviesFuture;
  late AnimationController _colorAnimationController;
  late Animation _colorTween;

  @override
  initState() {
    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween =
        ColorTween(begin: Colors.blue.shade900, end: Colors.red.shade900)
            .animate(_colorAnimationController);

    _fetchMoviesFuture = fetchMovies();
    super.initState();
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    super.dispose();
  }

  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.depth == 0) {
      _colorAnimationController.animateTo(
          scrollInfo.metrics.pixels / scrollInfo.metrics.maxScrollExtent);
    }
    return true;
  }

  Future<List> fetchMovies() async {
    String url =
        'https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc';
    Map<String, dynamic> discoverResponse = await getURL(url);

    return discoverResponse['results'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnimatedBuilder(
      animation: _colorAnimationController,
      builder: (context, child) => Container(
        color: _colorTween.value,
        child: FutureBuilder<List<dynamic>>(
          future: _fetchMoviesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<dynamic> results = snapshot.data!;
              return NotificationListener<ScrollNotification>(
                onNotification: _scrollListener,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 100,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return _buildGridItem(
                        context, results[index], widget.pushFavMovFirebase);
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    ));
  }
}

Widget _buildGridItem(
    BuildContext context, var result, void Function(int movieID) submit) {
  String posterPath = result['poster_path'];
  String imageUrl = 'https://image.tmdb.org/t/p/w780/$posterPath';

  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                result['overview'],
                maxLines: 100,
                style: const TextStyle(fontSize: 17),
              ),
            )),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RoundNetImage(imageUrl),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                iconSize: 50,
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
