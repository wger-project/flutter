import ActivityKit
import Foundation

/// One Live Activity for the whole workout. Dart builds the texts from the same
/// source as the workout notifications (workout_live_activity.dart).
@available(iOS 16.2, *)
struct WgerRestAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    var title: String
    var body: String
    var subtitle: String?
    /// In a rest (countdown or count-up)
    var resting: Bool
    var workoutStart: Date
    /// Counts down to `timerTo` if set, else up from `timerFrom`
    var timerFrom: Date
    var timerTo: Date?
    var canLog: Bool
    var canSkip: Bool
    var canExtend: Bool
    /// What to show once the countdown is over (the activity is stale then)
    var afterTitle: String?
    var afterBody: String?
    var afterSubtitle: String?
    var afterCanLog: Bool
    var afterCanExtend: Bool
    /// Handed back to Dart with a button, like a notification payload
    var payload: String
    var logLabel: String
    var skipLabel: String
    var extendLabel: String

    /// Parses the platform channel arguments. Flutter sends NSNull for Dart
    /// nulls, which the casts below turn into nil.
    init?(arguments: Any?) {
      guard let args = arguments as? [String: Any] else { return nil }
      func string(_ key: String) -> String? {
        guard let value = args[key], !(value is NSNull) else { return nil }
        return value as? String
      }
      func date(_ key: String) -> Date? {
        guard let value = args[key], !(value is NSNull),
          let seconds = (value as? NSNumber)?.doubleValue
        else { return nil }
        return Date(timeIntervalSince1970: seconds)
      }
      func flag(_ key: String) -> Bool {
        guard let value = args[key], !(value is NSNull) else { return false }
        return (value as? NSNumber)?.boolValue ?? false
      }
      guard let title = string("title"),
        let workoutStart = date("workoutStart"),
        let timerFrom = date("timerFrom"),
        let payload = string("payload")
      else { return nil }
      self.title = title
      self.body = string("body") ?? ""
      let subtitle = string("subtitle")
      self.subtitle = subtitle?.isEmpty == true ? nil : subtitle
      self.resting = flag("resting")
      self.workoutStart = workoutStart
      self.timerFrom = timerFrom
      self.timerTo = date("timerTo")
      self.canLog = flag("canLog")
      self.canSkip = flag("canSkip")
      self.canExtend = flag("canExtend")
      self.afterTitle = string("afterTitle")
      self.afterBody = string("afterBody")
      self.afterSubtitle = string("afterSubtitle")
      self.afterCanLog = flag("afterCanLog")
      self.afterCanExtend = flag("afterCanExtend")
      self.payload = payload
      self.logLabel = string("logLabel") ?? "Log set"
      self.skipLabel = string("skipLabel") ?? "Skip"
      self.extendLabel = string("extendLabel") ?? "+30 s"
    }
  }
}

/// Action ids of the Live Activity buttons, the same as the notification
/// actions in workout_notification_service.dart
enum WorkoutIslandAction {
  static let logSet = "log_set"
  static let skipRest = "skip_rest"
  static let extendRest = "extend_rest"
}
