import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_computing/feed_page.dart';
import 'package:mobile_computing/login_page.dart';
import 'package:mobile_computing/main.dart';
import 'package:mobile_computing/registration_page.dart';
import 'package:mobile_computing/util_cinema.dart';
import 'package:mockito/mockito.dart';

class MockFunction extends Mock {
  void call(int? movieID);
}
class MockFunction2 extends Mock {
  bool call2(ScrollNotification scrollInfo);
}


void main() {
  //Tests
  group('RoundImage Tests', () {
    testWidgets('RoundNetImage renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: RoundNetImage('your_image_path', "780"),
        ),
      ));
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
    });
    testWidgets('The Image is Clipped', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: RoundNetImage('your_image_path', "780"),
        ),
      ));
      await tester.pump();
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('RoundNetImage displays error icon on incorrect path',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: RoundNetImage('invalid_image_path', "780"),
        ),
      ));

      await tester.pump();
      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('RoundNetImage displays error icon on incorrect image size',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: RoundNetImage('tMefBSflR6PGQLv7WvFPpKLZkyk.jpg', "0"),
        ),
      ));

      await tester.pump();
      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });
  });

  group('Testing main', () {
    testWidgets('Navigation between Login and Registration',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      expect(find.byType(LoginPage), findsOneWidget);

      await tester.tap(find.text('Don\'t have an account? Register'));
      await tester.pumpAndSettle();

      expect(find.byType(RegistrationPage), findsOneWidget);

      await tester.tap(find.text('Already have an account? Sign In'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });

  group('Testing Login', () {
    testWidgets('Sign-in with empty fields', (WidgetTester tester) async {
      // Build the LoginPage widget
      await tester.pumpWidget(MaterialApp(
        home: LoginPage(),
        navigatorKey: navigatorKey, // Provide navigatorKey
      ));

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify that an error message is displayed
      expect(
          find.text('You must enter both email and password.'), findsOneWidget);
    });

    //TODO: add more tests, but first figure out how to initialize the app
  });

  group('Testing registration', () {
    testWidgets('Register with empty fields', (WidgetTester tester) async {
      // Build the LoginPage widget
      await tester.pumpWidget(MaterialApp(
        home: RegistrationPage(),
        navigatorKey: navigatorKey, // Provide navigatorKey
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify that an error message is displayed
      expect(
          find.text('You must enter both email and password.'), findsOneWidget);
    });

    //TODO: add more tests, but first figure out how to initialize the app
  });

  group("Test feed page", () {



    testWidgets('Test _buildGridItem with empty data', (WidgetTester tester) async {
      var result = {};
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              var actual = buildGridItem(
                context,
                result,
                    (int? movieID) {},
              );
              return actual;
            },
          ),
        ),
      );
      expect(find.byType(GridTile), findsOne);
      expect(find.text('No overview'), findsOne);
      expect(find.byIcon(Icons.bookmark), findsOne);

    });
    testWidgets('Test _buildGridItem with overview data', (WidgetTester tester) async {
      var result = {'overview': 'This is a movie overview'};
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              var actual = buildGridItem(
                context,
                result,
                    (int? movieID) {},
              );
              return actual;
            },
          ),
        ),
      );
      expect(find.byType(GridTile), findsOne);
      expect(find.text('This is a movie overview'), findsOne);
      expect(find.byIcon(Icons.bookmark), findsOne);

    });

    testWidgets('Test _buildGridItem with overview data', (WidgetTester tester) async {
      final List<dynamic> testMovieIDs = [-13, 0, 100000]; // Add more IDs here
      final mockFunction = MockFunction();
      var result = {'overview': 'This is a movie overview', 'id': 0};

      for (var movieID in testMovieIDs) {
        result['id'] = movieID;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                var actual = buildGridItem(
                  context,
                  result,
                  mockFunction,
                );
                return actual;
              },
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.bookmark));
        await tester.pump();

        if (movieID is int && movieID >= 0) {
          verify(mockFunction.call(movieID)).called(1);
        } else {
          verifyNever(mockFunction.call(any));
        }
      }

    });

  });


}
