import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let nativeChannel = FlutterMethodChannel(name: "nativeChannel",
                                              binaryMessenger: controller.binaryMessenger)
      nativeChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          if (call.method == "com.csupporter.sendlogtask") {
              if let args = call.arguments as? Dictionary<String, Any>,
                 let apiUrl = args["api_url"] as? String,
                 let filePath = args["file_path"] as? String {
                  print("DEBUG: Native " + apiUrl)
                  print("DEBUG: Native " + filePath)
                  self.sendLog(apiUrl: apiUrl, filePath: filePath)
                  result(nil)
              } else {
                  result(FlutterError.init(code: "error", message: "data or format error", details: nil))
              }
          }
    })
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    

    private func sendLog(apiUrl: String, filePath: String) {
        DispatchQueue.background(background: {
            // do something in background
            print("DEBUG: SEND LOG")
        }, completion:{
            // when background job finished, do something in main thread
        })
    }
}

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}
