import 'consts.dart';

double chartGetInterval(DateTime first, DateTime last, {divider = 3}) {
  final dayDiff = last.difference(first);

  return dayDiff.inMilliseconds == 0
      ? CHART_MILLISECOND_FACTOR
      : dayDiff.inMilliseconds.abs() / divider;
}
