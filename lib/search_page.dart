import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'util_cinema.dart';

class SearchPage extends StatefulWidget {
  final void Function(int movieID) pushFavMovFirebase;

  const SearchPage(this.pushFavMovFirebase, {Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  String selectedGenre = "";
  String selectedYear = "";
  String searchQuery = "";
  late Future<List<dynamic>> _fetchGenresFuture;

  final List<dynamic> _sortOptions = [
    'Default', //TODO: implement return to default
    'Alphabetically',
    'Popularity',
    'Release Date',
    'Rating'
  ];
  List<dynamic> searchResults = [];
  late AnimationController _colorAnimationController;
  late Animation _colorTween;
  int count = 0;

  @override
  void initState() {
    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween =
        ColorTween(begin: Colors.blue.shade900, end: Colors.red.shade900)
            .animate(_colorAnimationController);

    _fetchGenresFuture = _loadGenres();
    super.initState();
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    super.dispose();
  }

  void searchMovies() async {
    String url =
        'https://api.themoviedb.org/3/search/movie?query=$searchQuery&include_adult=false&language=en-US&primary_release_year=$selectedYear&page=1';

    Map<String, dynamic> searchResponse = await getURL(url);

    setState(() {
      searchResults = searchResponse['results'];
    });
  }

  Future<List> _loadGenres() async {
    String url = 'https://api.themoviedb.org/3/genre/movie/list?language=en';
    Map<String, dynamic> genresResponse = await getURL(url);

    return genresResponse['genres'];
  }

  void sortMovies(String sortOption) {
    switch (sortOption) {
      case 'Alphabetically':
        searchResults.sort((a, b) => a['title'].compareTo(b['title']));
        break;
      case 'Popularity':
        searchResults
            .sort((a, b) => b['popularity'].compareTo(a['popularity']));
        break;
      case 'Release Date':
        searchResults
            .sort((a, b) => b['release_date'].compareTo(a['release_date']));
        break;
      case 'Rating':
        searchResults
            .sort((a, b) => b['vote_average'].compareTo(a['vote_average']));
        break;
      case 'Default':
        break;
    }
  }

  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.maxScrollExtent == 0) {
      return true;
    }
    _colorAnimationController.animateTo(
        scrollInfo.metrics.pixels / scrollInfo.metrics.maxScrollExtent);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _colorAnimationController,
        builder: (context, child) => Stack(children: [
          Container(
            color: _colorTween.value,
          ),
          NotificationListener<ScrollNotification>(
            onNotification: _scrollListener,
            child: ListView(
              padding: const EdgeInsets.only(top: 130.0, bottom: 70.0),
              children: [
                ...searchResults.map((result) {
                  if (selectedGenre == "" ||
                      result['genre_ids'].contains(int.parse(selectedGenre))) {
                    return MovieCard(widget: widget, movieData: result);
                  } else {
                    return const SizedBox();
                  }
                }).toList(),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.3, 0.8, 1.0],
              // Adjust the stop values as needed
              colors: [
                Colors.transparent,
                Colors.black38,
                Colors.black38,
                Colors.transparent,
              ],
            )),
            padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchBar(
                      leading: Icon(Icons.search),
                      hintText: 'Search',
                      elevation: MaterialStateProperty.all(0.0),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 20.0)),
                      backgroundColor: MaterialStateProperty.all(
                          Colors.white54.withOpacity(0.5)),
                      constraints: const BoxConstraints(
                        minHeight: 40.0,
                        maxHeight: 40.0,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          searchQuery = newValue;
                          searchMovies();
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin:
                                const EdgeInsets.only(right: 10.0, left: 0.0),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.12,
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
                                    decoration: const InputDecoration(
                                      hintText: 'Year',
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
                            // padding: EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: Colors.white.withOpacity(0.5),
                            ),
                            child: FutureBuilder(
                              future: _fetchGenresFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List<dynamic> onlineGenres = snapshot.data!;
                                  return DropdownMenu<String>(
                                    menuStyle: MenuStyle(
                                      visualDensity: VisualDensity.compact,
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.all(0)),
                                    ),
                                    inputDecorationTheme:
                                        const InputDecorationTheme(
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
                                    dropdownMenuEntries: onlineGenres
                                        .map<DropdownMenuEntry<String>>(
                                            (dynamic genre) {
                                      return DropdownMenuEntry<String>(
                                        value: genre['id'].toString(),
                                        label: genre['name'],
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10.0),
                            // padding: EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: Colors.white.withOpacity(0.5),
                            ),
                            child: DropdownMenu<String>(
                              menuStyle: MenuStyle(
                                visualDensity: VisualDensity.compact,
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(0)),
                              ),
                              inputDecorationTheme: const InputDecorationTheme(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                                constraints: BoxConstraints(
                                  maxHeight: 40,
                                ),
                              ),
                              menuHeight: 400,
                              hintText: "Sort by",
                              onSelected: (String? value) {
                                setState(() {
                                  sortMovies(value!);
                                });
                              },
                              dropdownMenuEntries: _sortOptions
                                  .map<DropdownMenuEntry<String>>(
                                      (dynamic option) {
                                return DropdownMenuEntry<String>(
                                  value: option,
                                  label: option,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.widget, required this.movieData});

  final dynamic movieData;
  final SearchPage widget;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Stack(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  RoundNetImage(movieData['poster_path']),
                  Text(movieData['release_date']),
                ],
              ),
              const SizedBox(width: 10),
              // Title and Overview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movieData['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      movieData['overview'],
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
                widget.pushFavMovFirebase(movieData['id']);
              },
            ),
          ),
        ]),
      ),
    );
  }
}
