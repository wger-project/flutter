import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:wger/features/routines/providers/gym_state.dart';

/// Serializes ActivityKit updates; the gym state remains the source of truth.
class RestLiveActivity {
  final _channel = const MethodChannel('de.wger.flutter/rest_activity');
  final _logger = Logger('RestLiveActivity');
  Future<void> _queue = Future.value();
  String? _shown;

  void update(GymModeState state, {required bool visible, required String label}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    final start = state.isInitialized && visible ? state.restStartedAt : null;
    final end = state.isInitialized && visible ? state.restEndsAt : null;
    final active = start != null && end != null && end.isAfter(DateTime.now());
    final key = active ? '${start.millisecondsSinceEpoch}:${end.millisecondsSinceEpoch}' : '';
    if (key == _shown) {
      return;
    }
    _shown = key;
    final arguments = active
        ? <String, Object>{
            'start': start.millisecondsSinceEpoch / 1000,
            'end': end.millisecondsSinceEpoch / 1000,
            'label': label,
          }
        : null;
    _queue = _queue.then((_) async {
      try {
        await _channel.invokeMethod<void>(active ? 'sync' : 'end', arguments);
      } on MissingPluginException {
        _shown = null;
      } on PlatformException catch (error) {
        _shown = null;
        _logger.warning('Live Activity unavailable: ${error.code}');
      }
    });
  }
}
