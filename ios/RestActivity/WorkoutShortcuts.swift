import AppIntents
import Flutter
import UIKit

private struct WorkoutActionError: LocalizedError {
  let message: String
  var errorDescription: String? { message }
}

@available(iOS 16.0, *)
@MainActor
enum WorkoutShortcutBridge {
  private static var channel: FlutterMethodChannel?
  private static var ready = false

  static func register(with registrar: FlutterPluginRegistrar) {
    let bridge = FlutterMethodChannel(name: "de.wger.flutter/workout-shortcuts",
                                      binaryMessenger: registrar.messenger())
    ready = false
    channel = bridge
    bridge.setMethodCallHandler { call, reply in
      guard call.method == "ready" else { reply(FlutterMethodNotImplemented); return }
      ready = true
      reply(nil)
    }
  }

  /// [background] is for actions with openAppWhenRun = false: iOS may start
  /// wger without drawing frames, so it gives up sooner with a clear message.
  static func run(_ method: String, arguments: [String: Any] = [:],
                  background: Bool = false) async throws -> String {
    // Cold launches create the Flutter engine and install the Dart handler asynchronously.
    for _ in 0..<(background ? 60 : 150) {
      if ready { break }
      try await Task.sleep(nanoseconds: 100_000_000)
    }
    guard ready, let channel = channel else {
      throw WorkoutActionError(message: background
        ? "wger is not running in the background. Open wger once and try again."
        : "wger is not ready yet. Open the app and try again.")
    }
    return try await withCheckedThrowingContinuation { continuation in
      channel.invokeMethod(method, arguments: arguments) { result in
        if let value = result as? String {
          continuation.resume(returning: value)
        } else {
          let error = result as? FlutterError
          continuation.resume(throwing: WorkoutActionError(message: error?.message ?? "The action failed."))
        }
      }
    }
  }
}

@available(iOS 16.0, *)
struct StartWorkoutAction: AppIntent {
  static var title: LocalizedStringResource = "Start workout"
  static var openAppWhenRun: Bool = true

  @Parameter(title: "Training day (empty for today)")
  var day: String?

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let value = try await WorkoutShortcutBridge.run("start", arguments: ["day": day ?? ""])
    return .result(value: value)
  }
}

@available(iOS 16.0, *)
struct LogSetAction: AppIntent {
  static var title: LocalizedStringResource = "Log current set"
  static var openAppWhenRun: Bool = false

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let value = try await WorkoutShortcutBridge.run("log", background: true)
    return .result(value: value)
  }
}

@available(iOS 16.0, *)
struct SkipRestAction: AppIntent {
  static var title: LocalizedStringResource = "Skip rest"
  static var openAppWhenRun: Bool = false

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let value = try await WorkoutShortcutBridge.run("skip", background: true)
    return .result(value: value)
  }
}

@available(iOS 16.0, *)
struct ExtendRestAction: AppIntent {
  static var title: LocalizedStringResource = "Extend rest"
  static var openAppWhenRun: Bool = false

  @Parameter(title: "Seconds", default: 30)
  var seconds: Int

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let value = try await WorkoutShortcutBridge.run("extend", arguments: ["seconds": seconds],
                                                 background: true)
    return .result(value: value)
  }
}

@available(iOS 16.0, *)
struct WorkoutStatusAction: AppIntent {
  static var title: LocalizedStringResource = "Get workout status"
  static var openAppWhenRun: Bool = false

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let value = try await WorkoutShortcutBridge.run("status", background: true)
    return .result(value: value)
  }
}

@available(iOS 16.0, *)
struct FinishWorkoutAction: AppIntent {
  static var title: LocalizedStringResource = "Open workout summary"
  static var openAppWhenRun: Bool = true

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let value = try await WorkoutShortcutBridge.run("finish")
    return .result(value: value)
  }
}

@available(iOS 16.0, *)
struct SaveWorkoutAction: AppIntent {
  static var title: LocalizedStringResource = "Finish and save workout"
  static var openAppWhenRun: Bool = true

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let value = try await WorkoutShortcutBridge.run("saveFinish")
    return .result(value: value)
  }
}

@available(iOS 16.0, *)
struct OpenRoutinesAction: AppIntent {
  static var title: LocalizedStringResource = "Open routines"
  static var openAppWhenRun: Bool = true

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let value = try await WorkoutShortcutBridge.run("plans")
    return .result(value: value)
  }
}

// Further actions for automations in the Shortcuts app. Without Siri phrases:
// AppShortcutsProvider takes at most 10, they appear under "Add Action".

@available(iOS 16.0, *)
struct RestEndAction: AppIntent {
  static var title: LocalizedStringResource = "Get rest end"
  static var openAppWhenRun: Bool = false

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<Date> {
    let value = try await WorkoutShortcutBridge.run("restEnd", background: true)
    guard let milliseconds = Double(value) else {
      throw WorkoutActionError(message: "No rest countdown is running.")
    }
    return .result(value: Date(timeIntervalSince1970: milliseconds / 1000))
  }
}

@available(iOS 16.0, *)
struct RestRemainingAction: AppIntent {
  static var title: LocalizedStringResource = "Get remaining rest (seconds)"
  static var openAppWhenRun: Bool = false

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<Int> {
    let value = try await WorkoutShortcutBridge.run("restRemaining", background: true)
    return .result(value: Int(value) ?? 0)
  }
}

@available(iOS 16.0, *)
struct LogSetWithValuesAction: AppIntent {
  static var title: LocalizedStringResource = "Log set with values"
  static var openAppWhenRun: Bool = false

  @Parameter(title: "Repetitions (empty = planned)")
  var repetitions: Double?

  @Parameter(title: "Weight (empty = planned)")
  var weight: Double?

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    var arguments: [String: Any] = [:]
    if let repetitions = repetitions { arguments["repetitions"] = repetitions }
    if let weight = weight { arguments["weight"] = weight }
    let value = try await WorkoutShortcutBridge.run("logValues", arguments: arguments,
                                                    background: true)
    return .result(value: value)
  }
}

@available(iOS 16.0, *)
struct NextSetAction: AppIntent {
  static var title: LocalizedStringResource = "Get next set"
  static var openAppWhenRun: Bool = false

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let value = try await WorkoutShortcutBridge.run("next", background: true)
    return .result(value: value)
  }
}

@available(iOS 16.0, *)
struct WgerWorkoutShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(intent: StartWorkoutAction(), phrases: ["Start my workout in \(.applicationName)"],
                shortTitle: "Start workout", systemImageName: "figure.strengthtraining.traditional")
    AppShortcut(intent: LogSetAction(), phrases: ["Log my set in \(.applicationName)"],
                shortTitle: "Log current set", systemImageName: "checkmark.circle")
    AppShortcut(intent: SkipRestAction(), phrases: ["Skip my rest in \(.applicationName)"],
                shortTitle: "Skip rest", systemImageName: "forward.end")
    AppShortcut(intent: ExtendRestAction(), phrases: ["Extend my rest in \(.applicationName)"],
                shortTitle: "Extend rest", systemImageName: "timer")
    AppShortcut(intent: WorkoutStatusAction(), phrases: ["Show my workout status in \(.applicationName)"],
                shortTitle: "Workout status", systemImageName: "list.bullet")
    AppShortcut(intent: SaveWorkoutAction(), phrases: ["Finish my workout in \(.applicationName)"],
                shortTitle: "Finish workout", systemImageName: "checkmark.flag")
    AppShortcut(intent: FinishWorkoutAction(), phrases: ["Open my workout summary in \(.applicationName)"],
                shortTitle: "Workout summary", systemImageName: "flag.checkered")
    AppShortcut(intent: OpenRoutinesAction(), phrases: ["Open my routines in \(.applicationName)"],
                shortTitle: "Open routines", systemImageName: "list.clipboard")
  }
}
