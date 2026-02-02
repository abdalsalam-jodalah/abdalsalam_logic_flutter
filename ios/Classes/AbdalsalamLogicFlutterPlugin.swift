import Flutter
import UIKit

public class AbdalsalamLogicFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "runtime_control/ios", binaryMessenger: registrar.messenger())
    let instance = AbdalsalamLogicFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {    case \"getPlatformVersion\":
      result(\"iOS \" + UIDevice.current.systemVersion)    case "restartApp":
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
    DispatchQueue.main.async {
      // For iOS, we need to use a different approach since iOS doesn't allow true programmatic restart
      // Show a restart prompt that feels more like a hot restart
      
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first else {
        // Fallback - exit the app
        exit(0)
        return
      }
      
      // Create a restart overlay that mimics Flutter's hot restart
      let overlayView = self.createRestartOverlay()
      window.addSubview(overlayView)
      
      // Animate the restart effect
      UIView.animate(withDuration: 0.3, animations: {
        overlayView.alpha = 1.0
      }) { _ in
        // After animation, exit the app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          exit(0)
        }
      }
    }
  }
  
  private func forceKillAndRestart() {
    DispatchQueue.main.async {
      // Create a more dramatic restart effect for force restart
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first else {
        exit(0)
        return
      }
      
      let overlayView = self.createForceRestartOverlay()
      window.addSubview(overlayView)
      
      UIView.animate(withDuration: 0.2, animations: {
        overlayView.alpha = 1.0
      }) { _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          exit(0)
        }
      }
    }
  }
  
  private func createRestartOverlay() -> UIView {
    let screenBounds = UIScreen.main.bounds
    let overlay = UIView(frame: screenBounds)
    overlay.backgroundColor = UIColor.systemBlue
    overlay.alpha = 0.0
    
    let label = UILabel()
    label.text = "🚀 Restarting App..."
    label.textColor = .white
    label.font = UIFont.boldSystemFont(ofSize: 24)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    
    overlay.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
    ])
    
    return overlay
  }
  
  private func createForceRestartOverlay() -> UIView {
    let screenBounds = UIScreen.main.bounds
    let overlay = UIView(frame: screenBounds)
    overlay.backgroundColor = UIColor.systemRed
    overlay.alpha = 0.0
    
    let label = UILabel()
    label.text = "💀 Force Restarting..."
    label.textColor = .white
    label.font = UIFont.boldSystemFont(ofSize: 24)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    
    overlay.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
    ])
    
    return overlay
  }
}