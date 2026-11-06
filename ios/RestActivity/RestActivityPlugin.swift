import ActivityKit
import Flutter
import UIKit

@available(iOS 16.2, *)
final class RestActivityPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "de.wger.flutter/rest_activity", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(RestActivityPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "sync" || call.method == "end" else {
      result(FlutterMethodNotImplemented)
      return
    }
    Task { @MainActor in
      let existing = Activity<WgerRestAttributes>.activities
      guard call.method == "sync",
        let args = call.arguments as? [String: Any],
        let start = args["start"] as? Double,
        let end = args["end"] as? Double,
        let label = args["label"] as? String,
        end > Date().timeIntervalSince1970
      else {
        for activity in existing {
          await activity.end(nil, dismissalPolicy: .immediate)
        }
        result(nil)
        return
      }
      let state = WgerRestAttributes.ContentState(
        start: Date(timeIntervalSince1970: start),
        end: Date(timeIntervalSince1970: end), label: label)
      let content = ActivityContent(state: state, staleDate: state.end)
      guard ActivityAuthorizationInfo().areActivitiesEnabled else {
        result(FlutterError(code: "ACTIVITIES_DISABLED",
          message: "Enable Live Activities for wger in iOS Settings.", details: nil))
        return
      }
      if let current = existing.first {
        await current.update(content)
        for duplicate in existing.dropFirst() {
          await duplicate.end(nil, dismissalPolicy: .immediate)
        }
        result(nil)
      } else {
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
}
