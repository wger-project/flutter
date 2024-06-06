// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes
// ignore_for_file: type_annotate_public_apis
// ignore_fir_file: hash_and_equals

/// Code based on https://pub.dev/packages/logging 
class LogLevel implements Comparable<LogLevel> {
  final String name;

  final int value;

  const LogLevel(this.name, this.value);

  static const LogLevel all = LogLevel('All', 0);

  static const LogLevel off = LogLevel('OFF', 2000);

  static const LogLevel finest = LogLevel('FINEST', 300);

  static const LogLevel finer = LogLevel('FINER', 400);

  static const LogLevel fine = LogLevel('FINE', 500);

  static const LogLevel info = LogLevel('INFO', 800);

  static const LogLevel warning = LogLevel('Warning', 900);

  static const LogLevel severe = LogLevel('Severe', 1000);

  static const List<LogLevel> levels = [
    all,
    off,
    finest,
    finer,
    fine,
    info,
    warning,
    severe,
  ];

  @override
  bool operator ==(Object other) => other is LogLevel && value == other.value;

  bool operator <(Object other) => other is LogLevel && value < other.value;

  bool operator <=(Object other) => other is LogLevel && value <= other.value;

  bool operator >(Object other) => other is LogLevel && value > other.value;

  bool operator >=(Object other) => other is LogLevel && value >= other.value;

  @override
  int compareTo(LogLevel other) => value - other.value;

  @override
  int get hashCode => value;
}

abstract class Logging {
  static LogLevel level = LogLevel.info;

  void info(message, [Object? error, StackTrace? stackTrace]) {}

  void finest(message, [Object? error, StackTrace? stackTrace]) {}

  void finer(message, [Object? error, StackTrace? stackTrace]) {}

  void fine(message, [Object? error, StackTrace? stackTrace]) {}

  void warning(message, [Object? error, StackTrace? stackTrace]) {}

  void severe(message, [Object? error, StackTrace? stackTrace]) {}

  void provider(message, [Object? error, StackTrace? stackTrace]) {}
}
