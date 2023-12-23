double chartGetInterval(DateTime first, DateTime last, {divider = 3}) {
  final dayDiff = last.difference(first);

  return dayDiff.inMilliseconds == 0 ? 1000 : dayDiff.inMilliseconds.abs() / divider;
}
