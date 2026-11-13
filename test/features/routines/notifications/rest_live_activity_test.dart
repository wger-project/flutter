import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/routines/models/page_progress.dart';
import 'package:wger/features/routines/notifications/rest_live_activity.dart';
import 'package:wger/features/routines/providers/gym_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('de.wger.flutter/rest_activity');
  final start = DateTime.utc(2099, 1, 1);

  GymModeState rest(DateTime end) => GymModeState(
    isInitialized: true,
    useCountdownBetweenSets: true,
    countdownDuration: end.difference(start),
    pages: [
      PageEntry(
        type: PageType.set,
        pageIndex: 0,
        key: 'set',
        slotPages: [
          SlotPageEntry(type: SlotPageType.timer, pageIndex: 0, setIndex: 0, key: 'rest'),
        ],
      ),
    ],
    progress: {'rest': PageProgress(timerStartedAt: start)},
  );

  test('uses planned instants, updates an extended rest, clears on skip and exit', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => calls.add(call),
    );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    final activity = RestLiveActivity();
    final state = rest(start.add(const Duration(seconds: 60)));
    activity.update(state, visible: true, label: 'Pause');
    activity.update(state, visible: true, label: 'Pause');
    activity.update(rest(start.add(const Duration(seconds: 90))), visible: true, label: 'Pause');
    activity.update(GymModeState(), visible: true, label: 'Pause');
    await Future<void>.delayed(Duration.zero);
    expect(calls.map((call) => call.method), ['sync', 'sync', 'end']);
    final initial = calls[0].arguments as Map;
    final extended = calls[1].arguments as Map;
    expect(initial['start'], start.millisecondsSinceEpoch / 1000);
    expect(initial['end'], start.add(const Duration(seconds: 60)).millisecondsSinceEpoch / 1000);
    expect(extended['end'], start.add(const Duration(seconds: 90)).millisecondsSinceEpoch / 1000);
    activity.update(state, visible: true, label: 'Pause');
    activity.update(state, visible: false, label: 'Pause');
    await Future<void>.delayed(Duration.zero);
    expect(calls.last.method, 'end');
    expect(calls.length, 5);
  });
}
