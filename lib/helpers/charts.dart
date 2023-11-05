double chartGetInterval(DateTime first, DateTime last, {divider: 3}) {
  final dayDiff = last.difference(first);
  return dayDiff.inMilliseconds.toDouble() / 3;
}
