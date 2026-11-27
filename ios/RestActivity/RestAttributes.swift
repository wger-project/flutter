import ActivityKit
import Foundation

@available(iOS 16.2, *)
struct WgerRestAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    var start: Date
    var end: Date
    var label: String
  }
}
