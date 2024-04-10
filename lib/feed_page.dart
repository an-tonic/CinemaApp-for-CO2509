import 'package:flutter/material.dart';
import 'util_cinema.dart';

class FeedPage extends StatefulWidget {
  final void Function(int? movieID) pushFavMovFirebase;
  final bool Function(ScrollNotification scrollInfo) scrollListener;

  const FeedPage(this.pushFavMovFirebase, this.scrollListener, {Key? key}) : super(key: key);

  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
  late Future<List<dynamic>> _fetchMoviesFuture;


  @override
  initState() {
    _fetchMoviesFuture = fetchMovies();

    super.initState();
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
      backgroundColor: Colors.transparent,
        body: FutureBuilder<List<dynamic>>(
          future: _fetchMoviesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<dynamic> results = snapshot.data!;
              return NotificationListener<ScrollNotification>(
                onNotification: widget.scrollListener,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 100,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return buildGridItem(
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
        ));
  }
}

Widget buildGridItem(
    BuildContext context, var result, void Function(int? movieID) submit) {
  String? posterPath = result['poster_path'];
  String overviewText = result['overview'] ?? 'No overview';
  int? movieIndex = (result['id'] is int && result['id'] >= 0) ? result['id'] : null;


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
                overviewText,
                maxLines: 100,
                style: const TextStyle(fontSize: 17),
              ),
            )),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RoundNetImage(posterPath, "780"),
            BookmarkMovie(() {
              if (movieIndex == null) return;
                submit(movieIndex);
            })
          ],
        ),
      ),
    ),
  );
}
