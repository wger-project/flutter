import Flutter
import UIKit

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
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
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
