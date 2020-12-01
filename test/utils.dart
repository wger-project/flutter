import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:wger/providers/auth.dart';

// Test Auth provider
final Auth testAuth = Auth()
  ..token = 'FooBar'
  ..serverUrl = 'https://localhost';

// Mocked HTTP client
class MockClient extends Mock implements http.Client {}
