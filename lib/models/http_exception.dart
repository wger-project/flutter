class HttpException implements Exception {
  final Map<String, dynamic> errors;

  HttpException(this.errors);

  @override
  String toString() {
    return '';
  }
}
