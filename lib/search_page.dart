import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'no_internet_popup.dart';

class SearchPage extends StatefulWidget {
  final DatabaseReference db;

  const SearchPage({Key? key, required this.db}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  double _scrollPosition = 0.0;
  final ScrollController _scrollController = ScrollController();
  Color? startColor;
  Color? endColor;
  String selectedGenre = "";
  String selectedYear = "";
  String searchQuery = "";
  List<dynamic> _genres = [];
  List<dynamic> searchResults = [];

  @override
  void initState() {
    super.initState();

    _loadGenres();
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

  void searchMovies() async {
    String url =
        'https://api.themoviedb.org/3/search/movie?query=$searchQuery&include_adult=false&language=en-US&primary_release_year=$selectedYear&page=1';

    Map<String, dynamic> searchResponse = await getURL(url, context);

    setState(() {
      searchResults = searchResponse['results'];
    });
  }

  void _loadGenres() async {
    String url = 'https://api.themoviedb.org/3/genre/movie/list?language=en';
    Map<String, dynamic> genresResponse = await getURL(url, context);

    setState(() {
      _genres = genresResponse['genres'];
    });
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
        child: ListView(
          controller: _scrollController,
          children: [
            // Search Bar
            Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.white.withOpacity(0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      onChanged: (String newValue) {
                        setState(() {
                          searchQuery = newValue;
                          searchMovies();
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10.0, left: 10.0),
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white.withOpacity(0.5),
                    ),
                    height: 40,
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 5.0),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.12,
                          child: TextField(
                            onChanged: (String newValue) {
                              if (newValue.length == 4) {
                                setState(() {
                                  selectedYear = newValue;
                                });
                                searchMovies();
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: InputDecoration(
                              hintText: 'Year',
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5)),
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 11.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10.0),
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white.withOpacity(0.5),
                    ),
                    child: DropdownMenu<String>(
                      menuStyle: MenuStyle(
                        visualDensity: VisualDensity.compact,
                        padding: MaterialStateProperty.resolveWith(
                            (states) => EdgeInsets.all(0)),
                      ),
                      inputDecorationTheme: const InputDecorationTheme(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                        constraints: BoxConstraints(
                          maxHeight: 40,
                        ),
                      ),
                      menuHeight: 400,
                      hintText: "Genre",
                      onSelected: (String? value) {
                        setState(() {
                          selectedGenre = value!;
                        });
                      },
                      dropdownMenuEntries: _genres
                          .map<DropdownMenuEntry<String>>((dynamic genre) {
                        return DropdownMenuEntry<String>(
                          value: genre['id'].toString(),
                          label: genre['name'],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            ...searchResults.map((result) {
              if (selectedGenre == "" ||
                  result['genre_ids'].contains(int.parse(selectedGenre))) {
                return Card(
                  color: Colors.red.withOpacity(0.3),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Stack( children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Image
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  'https://image.tmdb.org/t/p/w92/${result['poster_path']}',
                                  fit: BoxFit.cover,
                                  width: 70,
                                  height: 100,
                                ),
                              ),
                              Text(result['release_date']),
                            ],
                          ),
                          const SizedBox(width: 10),
                          // Title and Overview
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  result['overview'],
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: IconButton(
                          iconSize: 30,
                          icon: const Icon(Icons.bookmark),
                          onPressed: () {
                            _submit(result['id']);
                          },
                        ),
                      ),
                    ]),
                  ),
                );
              } else {
                return const SizedBox(
                  width: 0,
                  height: 0,
                );
              }
            }).toList(),
            SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }
}
