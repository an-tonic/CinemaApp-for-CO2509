import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _fetchMoviesFuture;
  double _scrollPosition = 0.0;
  final ScrollController _scrollController = ScrollController();
  Color? startColor;
  Color? endColor;
  @override
  void initState() {
    super.initState();
    _fetchMoviesFuture = fetchMovies();

    _scrollController.addListener(() {
      setState(() {
        double maxScrollExtent = _scrollController.position.maxScrollExtent;
        _scrollPosition = _scrollController.offset;
        startColor = Color.lerp(Colors.blue.shade900, Colors.red.shade900, _scrollPosition / maxScrollExtent);
        endColor = Color.lerp(Colors.red.shade900, Colors.blue.shade900, _scrollPosition / maxScrollExtent);
      });
    });

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchMovies() async {
    String url =
        'https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc';

    String token =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYWMyNmI5ZTE4ZWI1NGRhZTBlYTBiMGY1YjFhZTY3ZSIsInN1YiI6IjY1ZjdmMTkwZTIxMDIzMDE3ZWVmYjgwMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.5tUBCoCnS8XTDkXhOXgzPkjcb8Etkzb1ZvEfSUD6_Ws';
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Failed to connect to the internet');
    } else {
      http.Response response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch movies');
      }
    }
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
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchMoviesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!;
            List<dynamic> results = data['results'];
            return GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 100,
                childAspectRatio: 0.7,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                var result = results[index];
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

                            //textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 17),
                          ),
                        )
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
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
