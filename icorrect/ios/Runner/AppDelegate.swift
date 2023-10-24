import UIKit
import BackgroundTasks
import Flutter
import workmanager
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
                  print("DEBUG: Native - send log: url = \(apiUrl) secretkey = \(secretkey)")
                  print("DEBUG: Native - send log: file path = \(filePath)")
//                  self.sendLog(apiUrl: apiUrl, secretkey: secretkey, filePath: filePath)
                  result(nil)
              } else {
                  result(FlutterError.init(code: "error", message: "data or format error", details: nil))
              }
          }
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    

    private func sendLog(apiUrl: String, secretkey: String, filePath: String) {
        DispatchQueue.background(background: {
            // do something in background
            print("DEBUG: SEND LOG")
            let uploadURL = URL(string: apiUrl)!
            var request = URLRequest(url: uploadURL)
            request.httpMethod = "POST"
            request.addValue(secretkey, forHTTPHeaderField: "secretkey")
            request.addValue("flutter_logs.txt", forHTTPHeaderField: "file")

            if let fileURL: URL? = URL(fileURLWithPath: filePath) {
                if (fileURL == nil) { return }
                
                do {
                    let content = try String(contentsOf: fileURL!, encoding: .utf8)
                    print("DEBUG: send log content: \(content)")
                } catch (_) {
                    print("DEBUG: send log check file error")
                }
                
                    
                let task = URLSession.shared.uploadTask(with: request, fromFile: fileURL!) { data, response, error in
                    if let error = error {
                        print("DEBUG: send log Lỗi khi tải lên: \(error)")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            // Tải lên thành công
                            print("DEBUG: send log Tải lên thành công")
                        } else {
                            print("DEBUG: send log Lỗi HTTP: \(httpResponse.statusCode)")
                        }
                    }
                }
                
                task.resume()
            } else {
                print("DEBUG: send log: Không có file log")
                return
            }
        }, completion:{
            // when background job finished, do something in main thread
            print("DEBUG: send log: when background job finished, do something in main thread")
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
