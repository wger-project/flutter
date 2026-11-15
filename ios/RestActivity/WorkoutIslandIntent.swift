import AppIntents
import Foundation

/// Set by the app (RestActivityPlugin), nil in the widget extension. Carries a
/// Live Activity button to Dart.
enum WorkoutIslandActions {
  /// Only touched on the main thread: set at engine start, read by the intent
  static var handler: ((_ action: String, _ payload: String) async -> Void)?
}

/// The buttons of the Live Activity. Part of the app and the widget target:
/// the widget needs it for Button(intent:), iOS runs it in the app process.
@available(iOS 17.0, *)
struct WorkoutIslandIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "wger workout action"
  static var isDiscoverable: Bool = false

  @Parameter(title: "Action")
  var action: String

  @Parameter(title: "Data")
  var payload: String

  init() {}

  init(action: String, payload: String) {
    self.action = action
    self.payload = payload
  }

  @MainActor
  func perform() async throws -> some IntentResult {
    await WorkoutIslandActions.handler?(action, payload)
    return .result()
  }
}
