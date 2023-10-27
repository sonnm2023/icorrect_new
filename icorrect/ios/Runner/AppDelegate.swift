import UIKit
import BackgroundTasks
import Flutter
import Foundation

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
                 let secretkey = args["secretkey"] as? String,
                 let filePath = args["file_path"] as? String {
                  debugPrint("DEBUG: Native - send log: url = \(apiUrl) secretkey = \(secretkey)")
                  debugPrint("DEBUG: Native - send log: file path = \(filePath)")
                  self.sendLog(apiUrl: apiUrl, filePath: filePath, secretkey: secretkey) { _ in
                      debugPrint("DEBUG: Send log success!")
                      self.deleteFile(filePath: filePath)
                  } failure: {
                      debugPrint("DEBUG: Send log error!")
                  }
                  
                  result(nil)
              } else {
                  result(FlutterError.init(code: "error", message: "data or format error", details: nil))
              }
          }
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func sendLog (
        apiUrl: String,
        filePath: String,
        secretkey: String,
        success: @escaping (Bool) -> Void,
        failure: @escaping () -> Void) {
            if let fileURL: URL? = URL(fileURLWithPath: filePath) {
                if (fileURL == nil) { return }
                do {
                    let content = try? String(contentsOf: fileURL!, encoding: .utf8)
                    let param: [String : Any] = ["secretkey": secretkey, "file": content]
                    NetworkManager.shared.callingHttpPostMethodWithFile(params: param, apiname: apiUrl, filePath: filePath, success: { [weak self](data) in
                        guard self != nil else {return}
                        if data == nil {
                            success(true)
                        } else {
                            success(false)
                        }
                    }, failure: { (error) in
                        debugPrint("DEBUG: sendLog api error \(error?.localizedDescription ?? "sendLog api error")")
                        failure()
                    })
                }
            }
        }
    
    private func deleteFile(filePath: String) {
        do {
             let fileManager = FileManager.default
            
            // Check if file exists
            if fileManager.fileExists(atPath: filePath) {
                debugPrint("DEBUG: DELETE log file")
                // Delete file
                try fileManager.removeItem(atPath: filePath)
            } else {
                debugPrint("DEBUG: File does not exist")
            }
         
        }
        catch let error as NSError {
            debugPrint("DEBUG: An error took place: \(error)")
        }
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
