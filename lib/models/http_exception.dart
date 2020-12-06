class WgerHttpException implements Exception {
  final Map<String, dynamic> errors;

  WgerHttpException(this.errors);

  @override
  String toString() {
    return errors.values.toList().join(', ');
  }
}
