import Flutter
import UIKit

public class AbdalsalamLogicFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "runtime_control/ios", binaryMessenger: registrar.messenger())
    let instance = AbdalsalamLogicFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "restartApp":
      restartApplication()
      result(true)
    case "forceKillAndRestart":
      forceKillAndRestart()
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func restartApplication() {
    // iOS doesn't allow programmatic app restart in production apps
    // This is primarily for development/enterprise distribution
    DispatchQueue.main.async {
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first else {
        exit(0)
        return
      }
      
      let alert = UIAlertController(title: "Restart Required", 
                                   message: "Please close and reopen the app to complete the restart.", 
                                   preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
        exit(0)
      })
      
      window.rootViewController?.present(alert, animated: true)
    }
  }
  
  private func forceKillAndRestart() {
    // Force terminate the app
    exit(0)
  }
}