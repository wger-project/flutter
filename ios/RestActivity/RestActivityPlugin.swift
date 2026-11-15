import ActivityKit
import Flutter
import UIKit

/// Shows the workout in one Live Activity and hands its buttons to Dart
@available(iOS 16.2, *)
final class RestActivityPlugin: NSObject, FlutterPlugin {
  /// Upper bound for a button if Dart never answers
  private static let actionTimeout: TimeInterval = 20

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "de.wger.flutter/rest_activity", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(RestActivityPlugin(), channel: channel)
    WorkoutIslandActions.handler = { action, payload in
      await RestActivityPlugin.forward(action, payload, over: channel)
    }
  }

  /// Runs the button in Dart, kept alive by a background task. On a cold
  /// launch Dart may not listen yet, so a missing handler is retried.
  @MainActor
  private static func forward(_ action: String, _ payload: String,
                              over channel: FlutterMethodChannel) async {
    let task = BackgroundTask(name: "wger-island-action")
    defer { task.end() }
    let deadline = Date().addingTimeInterval(actionTimeout)
    while Date() < deadline {
      let reply = await invoke(channel, action, payload, until: deadline)
      if let value = reply as? NSObject, value === FlutterMethodNotImplemented {
        try? await Task.sleep(nanoseconds: 200_000_000)
        continue
      }
      if let error = reply as? FlutterError {
        NSLog("wger island action \(action) failed: \(error.message ?? error.code)")
      }
      return
    }
    NSLog("wger island action \(action) timed out")
  }

  /// The reply of Dart, nil once `deadline` has passed
  @MainActor
  private static func invoke(_ channel: FlutterMethodChannel, _ action: String, _ payload: String,
                             until deadline: Date) async -> Any? {
    await withCheckedContinuation { (continuation: CheckedContinuation<Any?, Never>) in
      let reply = Reply(continuation)
      channel.invokeMethod("action", arguments: ["action": action, "payload": payload]) { value in
        reply.finish(value)
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + max(0, deadline.timeIntervalSinceNow)) {
        reply.finish(nil)
      }
    }
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "sync" || call.method == "end" else {
      result(FlutterMethodNotImplemented)
      return
    }
    Task { @MainActor in
      let existing = Activity<WgerRestAttributes>.activities.filter {
        $0.activityState == .active || $0.activityState == .stale
      }
      guard call.method == "sync",
        let state = WgerRestAttributes.ContentState(arguments: call.arguments)
      else {
        for activity in Activity<WgerRestAttributes>.activities {
          await activity.end(nil, dismissalPolicy: .immediate)
        }
        result(nil)
        return
      }
      // iOS marks it stale once the rest is over, the widget then shows the set
      let content = ActivityContent(state: state, staleDate: state.timerTo)
      if let current = existing.first {
        await current.update(content)
        for duplicate in existing.dropFirst() {
          await duplicate.end(nil, dismissalPolicy: .immediate)
        }
        result(nil)
        return
      }
      guard ActivityAuthorizationInfo().areActivitiesEnabled else {
        result(FlutterError(code: "ACTIVITIES_DISABLED",
          message: "Enable Live Activities for wger in iOS Settings.", details: nil))
        return
      }
      // Only allowed in the foreground, Dart tries again with the next update
      do {
        _ = try Activity.request(attributes: WgerRestAttributes(), content: content,
                                 pushType: nil)
        result(nil)
      } catch {
        result(FlutterError(code: "ACTIVITY_START_FAILED",
                           message: error.localizedDescription, details: nil))
      }
    }
  }
}

/// Resumes a continuation once: with Dart's reply or at the timeout
private final class Reply {
  private var continuation: CheckedContinuation<Any?, Never>?

  init(_ continuation: CheckedContinuation<Any?, Never>) {
    self.continuation = continuation
  }

  func finish(_ value: Any?) {
    continuation?.resume(returning: value)
    continuation = nil
  }
}

/// Keeps the app running in the background until ended or expired
private final class BackgroundTask {
  private var id: UIBackgroundTaskIdentifier = .invalid

  init(name: String) {
    id = UIApplication.shared.beginBackgroundTask(withName: name) { [weak self] in
      self?.end()
    }
  }

  func end() {
    guard id != .invalid else { return }
    UIApplication.shared.endBackgroundTask(id)
    id = .invalid
  }
}
