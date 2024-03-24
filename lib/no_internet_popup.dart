import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void showNoInternetPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('No Internet'),
        content: const Text('Please check your internet connection and try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<Map<String, dynamic>> getURL(String url, BuildContext context) async {

  String token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYWMyNmI5ZTE4ZWI1NGRhZTBlYTBiMGY1YjFhZTY3ZSIsInN1YiI6IjY1ZjdmMTkwZTIxMDIzMDE3ZWVmYjgwMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.5tUBCoCnS8XTDkXhOXgzPkjcb8Etkzb1ZvEfSUD6_Ws";

  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    showNoInternetPopup(context);

    throw Exception('Failed to connect to the internet');
  } else {

    http.Response response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {

      return jsonDecode(response.body);

    } else {
      throw Exception('Failed to fetch');
    }
  }
}
