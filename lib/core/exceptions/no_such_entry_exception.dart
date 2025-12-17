class NoSuchEntryException implements Exception {
  const NoSuchEntryException();

  @override
  String toString() {
    return 'No such entry found';
  }
}
