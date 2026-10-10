import Flutter
import UIKit
import flutter_local_notifications

private final class StorageExclusionPlugin: NSObject, FlutterPlugin {
  static let pluginName = "StorageExclusionPlugin"
  private static let channelName = "de.wger.flutter/storage"

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    let instance = StorageExclusionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "excludeFromBackup" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard
      let arguments = call.arguments as? [String: Any],
      let path = arguments["path"] as? String,
      !path.isEmpty
    else {
      result(
        FlutterError(
          code: "INVALID_ARGUMENT",
          message: "Expected a non-empty path",
          details: nil
        )
      )
      return
    }

    do {
      var url = URL(fileURLWithPath: path)
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      try url.setResourceValues(values)
      result(nil)
    } catch {
      result(
        FlutterError(
          code: "EXCLUDE_FROM_BACKUP_FAILED",
          message: "Could not exclude \(path) from backups",
          details: error.localizedDescription
        )
      )
    }
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Lets notifications show in the foreground and delivers action responses
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // A notification action is handled by the main isolate, but the plugin
  // completes the response right away and iOS suspends the app again.
  // Keep it running briefly so the action is processed now.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    var task: UIBackgroundTaskIdentifier = .invalid
    task = UIApplication.shared.beginBackgroundTask {
      UIApplication.shared.endBackgroundTask(task)
      task = .invalid
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
      if task != .invalid {
        UIApplication.shared.endBackgroundTask(task)
        task = .invalid
      }
    }
    super.userNotificationCenter(
      center, didReceive: response, withCompletionHandler: completionHandler)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Notification actions run in a separate engine, which needs the plugins too
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard
      let registrar = engineBridge.pluginRegistry.registrar(
        forPlugin: StorageExclusionPlugin.pluginName
      )
    else {
      NSLog("StorageExclusionPlugin registrar unavailable")
      return
    }
    StorageExclusionPlugin.register(with: registrar)
  }
}
