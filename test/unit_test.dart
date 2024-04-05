import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_computing/util_cinema.dart';

class MockShowPopup extends Mock {
  void call({String message});
}

void main() {
  group('handleCinemaAppError tests', () {
    final mockShowPopup = MockShowPopup();

    test('handles channel-error correctly', () {
      handleCinemaAppError('channel-error', mockShowPopup);
      verify(mockShowPopup(message: 'No internet connection.')).called(1);
    });

    test('handles network-request-failed correctly', () {
      handleCinemaAppError('network-request-failed', mockShowPopup);
      verify(mockShowPopup(message: 'No internet connection.')).called(1);
    });

    test('handles invalid-email correctly', () {
      handleCinemaAppError('invalid-email', mockShowPopup);
      verify(mockShowPopup(message: 'Bad email format.')).called(1);
    });

    test('handles weak-password correctly', () {
      handleCinemaAppError('weak-password', mockShowPopup);
      verify(mockShowPopup(message: 'Weak password: 6 chars min.')).called(1);
    });

    test('handles too-many-requests correctly', () {
      handleCinemaAppError('too-many-requests', mockShowPopup);
      verify(mockShowPopup(message: 'Too many login attempts. Try later.')).called(1);
    });

    test('handles invalid-credential correctly', () {
      handleCinemaAppError('invalid-credential', mockShowPopup);
      verify(mockShowPopup(message: 'Either email or password are incorrect. Try again.')).called(1);
    });

    test('handles user-not-found correctly', () {
      handleCinemaAppError('user-not-found', mockShowPopup);
      verify(mockShowPopup(message: 'User not found: register to continue.')).called(1);
    });

    test('handles wrong-password correctly', () {
      handleCinemaAppError('wrong-password', mockShowPopup);
      verify(mockShowPopup(message: 'Wrong password. Try again.')).called(1);
    });

    test('handles email-already-in-use correctly', () {
      handleCinemaAppError('email-already-in-use', mockShowPopup);
      verify(mockShowPopup(message: 'Email already in use. Try a different one.')).called(1);
    });

    test('handles empty-fields correctly', () {
      handleCinemaAppError('empty-fields', mockShowPopup);
      verify(mockShowPopup(message: 'You must enter both email and password.')).called(1);
    });
  });
}
