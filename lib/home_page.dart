import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatelessWidget {
  Future<Map<String, dynamic>> fetchMovies() async {

    String db_url =
        'https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc';


    String token = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYWMyNmI5ZTE4ZWI1NGRhZTBlYTBiMGY1YjFhZTY3ZSIsInN1YiI6IjY1ZjdmMTkwZTIxMDIzMDE3ZWVmYjgwMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.5tUBCoCnS8XTDkXhOXgzPkjcb8Etkzb1ZvEfSUD6_Ws';


    http.Response response = await http.get(Uri.parse(db_url), headers: {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
    });



    if (response.statusCode == 200) {
      return jsonDecode(response.body);

    } else {
      // If the request failed, throw an exception
      throw Exception('Failed to load movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the future to complete, show a loading indicator
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If an error occurred, display an error message
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // If the future completed successfully, display the data
            Map<String, dynamic> data = snapshot.data!;
            List<dynamic> results = data['results'];
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                var result = results[index];
                return ListTile(
                  title: Text(result['title']),
                  subtitle: Text(
                      'Release Date: ${result['release_date']}, Popularity: ${result['popularity']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
