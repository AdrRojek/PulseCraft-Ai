import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// Strong lifetime for the engine — must outlive the SceneDelegate window.
  let flutterEngine = FlutterEngine(name: "pulsecraft_engine")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Critical order: run Dart first, then register plugins (Flutter add-to-app pattern).
    let ok = flutterEngine.run()
    assert(ok, "FlutterEngine.run() failed")
    GeneratedPluginRegistrant.register(with: flutterEngine)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
