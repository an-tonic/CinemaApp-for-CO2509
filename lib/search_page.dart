import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<Map<String, dynamic>> _fetchMoviesFuture;
  double _scrollPosition = 0.0;
  final ScrollController _scrollController = ScrollController();
  Color? startColor;
  Color? endColor;
  String selectedGenre = "Genre";
  String selectedYear = "";
  String searchQuery = "";
  List<String> _genres = [];
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

  void searchMovies(searchParam) async {
    String url =
        'https://api.themoviedb.org/3/search/movie?query=$searchParam&include_adult=false&language=en-US&primary_release_year=$selectedYear&page=1';

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
         print(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch movies');
      }
    }
  }

  void _loadGenres() async {
    print("HERE1");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("HERE2");
    if (prefs.containsKey('genres')) {
      setState(() {
        _genres = prefs.getStringList('genres')!;
      });
    } else {
      // Fetch genres from API
      try {
        final response = await http.get(
          Uri.parse('https://api.themoviedb.org/3/genre/movie/list?language=en'),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          List<dynamic> genres = data['genres'];
          setState(() {
            _genres = genres.map((genre) => genre['name'].toString()).toList();
          });
          // Save genres to SharedPreferences
          prefs.setStringList('genres', _genres);
        } else {
          throw Exception('Failed to fetch genres');
        }
      } catch (error) {
        print('Error fetching genres: $error');
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
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: EdgeInsets.all(20.0),
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
                        searchMovies(newValue);
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10.0),
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
                              setState(() {
                                selectedYear = newValue;
                              });
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
                    height: 40,
                    child: DropdownButton<String>(
                      value: selectedGenre,
                      hint: const Text("Genre"),
                      icon: Icon(Icons.arrow_drop_down),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGenre = newValue!;
                        });
                      },
                      items:
                          _genres.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            //TODO: Place tiles
          ],
        ),
      ),
    );
  }
}
