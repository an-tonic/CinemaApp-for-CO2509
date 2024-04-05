import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

void showPopup({String message = 'empty'}) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void handleCinemaAppError(String errorCode, Function showPopup) {
  switch (errorCode) {
    case 'channel-error' || 'network-request-failed':
      showPopup(message: 'No internet connection.');
      break;
    case 'invalid-email':
      showPopup(message: 'Bad email format.');
      break;
    case 'weak-password':
      showPopup(message: 'Weak password: 6 chars min.');
      break;
    case 'too-many-requests':
      showPopup(message: 'Too many login attempts. Try later.');
      break;
    case 'invalid-credential':
      showPopup(message: 'Either email or password are incorrect. Try again.');
      break;
    case 'user-not-found':
      showPopup(message: 'User not found: register to continue.');
      break;
    case 'wrong-password':
      showPopup(message: 'Wrong password. Try again.');
      break;
    case 'email-already-in-use':
      showPopup(message: 'Email already in use. Try a different one.');
      break;
    case 'empty-fields':
      showPopup(message: 'You must enter both email and password.');
    default:
      if (kDebugMode) {
        print("Unknown error code: $errorCode");
      }
      break;
  }
}

Future<Map<String, dynamic>> getURL(String url) async {
  String token =
      "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYWMyNmI5ZTE4ZWI1NGRhZTBlYTBiMGY1YjFhZTY3ZSIsInN1YiI6IjY1ZjdmMTkwZTIxMDIzMDE3ZWVmYjgwMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.5tUBCoCnS8XTDkXhOXgzPkjcb8Etkzb1ZvEfSUD6_Ws";
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw const FormatException('network-request-failed');
    }
    http.Response response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw const FormatException('server-error');
    }
  } on FormatException catch (e) {
    handleCinemaAppError(e.message, showPopup);
  }

  throw Exception();
}

class RoundNetImage extends StatelessWidget {
  final dynamic netPath;
  final String imageSize;
  const RoundNetImage(this.netPath, this.imageSize, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        'https://image.tmdb.org/t/p/w${imageSize}/${netPath}',
        fit: BoxFit.fitWidth,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported);
        },
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          return loadingProgress == null
              ? child
              : CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                );
        },
      ),
    );
  }
}
