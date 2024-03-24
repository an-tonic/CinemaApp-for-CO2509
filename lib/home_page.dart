import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'no_internet_popup.dart';

class HomePage extends StatefulWidget {
  final DatabaseReference db;

  const HomePage({Key? key, required this.db}) : super(key: key);

  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _fetchMoviesFuture;
  double _scrollPosition = 0.0;
  final ScrollController _scrollController = ScrollController();
  Color? startColor;
  Color? endColor;


  @override
  initState() {
    super.initState();
    _fetchMoviesFuture = fetchMovies();

    _scrollController.addListener(() {
      setState(() {
        double maxScrollExtent = _scrollController.position.maxScrollExtent;
        _scrollPosition = _scrollController.offset;
        startColor = Color.lerp(Colors.blue.shade900, Colors.red.shade900,
            _scrollPosition / maxScrollExtent);
        endColor = Color.lerp(Colors.red.shade900, Colors.blue.shade900,
            _scrollPosition / maxScrollExtent);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _submit(int movieID) {
    widget.db.child('favorite_movie_id').child(movieID.toString()).set('');
  }

  Future<List> fetchMovies() async {
    String url =
        'https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc';
    Map<String, dynamic> discoverResponse = await getURL(url, context);

    return discoverResponse['results'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            startColor ?? Colors.blue.shade900,
            endColor ?? Colors.red.shade900,
          ],
        ),
      ),
      child: FutureBuilder<List<dynamic>>(
        future: _fetchMoviesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<dynamic> results = snapshot.data!;
            return GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 100,
                childAspectRatio: 0.7,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return _buildGridItem(context, results[index], _submit);
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    ));
  }
}

Widget _buildGridItem(BuildContext context, var result, void Function(int movieID) submit) {

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
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  // Image has finished loading, so return the child (the actual image)
                  return child;
                } else {
                  // Image is still loading, so return a CircularProgressIndicator
                  return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator());
                }
              },
            ),
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