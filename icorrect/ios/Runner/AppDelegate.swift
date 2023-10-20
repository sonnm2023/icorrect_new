import UIKit
import BackgroundTasks
import Flutter
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    WorkmanagerPlugin.registerTask(withIdentifier: "com.csupporter.sendlogtask")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
