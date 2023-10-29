//
//  NetworkManager.swift
//  Runner
//
//  Created by Apple on 27/10/2023.
//

import Foundation
import AFNetworking
import UniformTypeIdentifiers

class NetworkManager: NSObject {
    static let shared = NetworkManager()
    static let TIMEOUT = Double(60)
    let manager = AFHTTPSessionManager()
    
    func callingHttpPostMethodWithFile (params:[String:Any]?,
                                apiname : String,
                                filePath: String,
                                success: @escaping (_ result: Any?) -> Void,
                                failure: @escaping (_ err: Error?) -> Void){
        let urlString = apiname
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.timeoutInterval = NetworkManager.TIMEOUT
        manager.requestSerializer.cachePolicy = .reloadIgnoringCacheData
        
        if let fileURL: URL? = URL(fileURLWithPath: filePath) {
            if (fileURL == nil) { return }
            
            do {
                let fileData = try? Data(contentsOf: fileURL!)
                var data = Data()
                data.append(fileData!)
                manager.requestSerializer.setValue(String(data.count), forHTTPHeaderField: "Content-Length")
                
                var paramsOS = params
                paramsOS?.updateValue("ios_flutter", forKey: "os")
                
                manager.post(urlString, parameters: paramsOS, headers: nil) { formData in
                    formData.appendPart(withFileData: data, name: "file", fileName: "flutter_logs.txt", mimeType: "text/plain")
                } progress: { Progress in
                
                } success: { (session, data) in
                    if let response = (data as? [String: Any]) {
                        debugPrint("DEBUG: Send log response ===== \(String(describing: response))")
                        debugPrint("Status: \(String(describing: response["status"])) Message: \(String(describing: response["message"]))")
//                        Common.deleteFile(fileName: "flutter_logs.txt")
                        //TODO: Delete log file here
                        success(response)
                        URLCache.shared.removeCachedResponses(since: Date())
                    }
                } failure: { (session, error) in
                    failure(error)
                    
                    if error.code == 401 {
                        debugPrint("DEBUG: Send log error code: 401 - Needs refresh token")
                    } else if error.code == 302 {
                        debugPrint("test12\(String(describing: error.data))")
                    }
                }
            }
        }
    }
}

extension Error {
    var code: Int { return self.userInfo["com.alamofire.serialization.response.error.response"] != nil ? (self.userInfo["com.alamofire.serialization.response.error.response"] as! HTTPURLResponse).statusCode : 500}
    var domain: String { return (self as NSError).domain }
    var userInfo: [String:Any] { return (self as NSError).userInfo }
    var data:  [String:Any] { return self.userInfo["com.alamofire.serialization.response.error.response.data"] != nil ? (self.userInfo["com.alamofire.serialization.response.error.response.data"] as!  [String:Any]) : [:]}
}

extension NSURL {
    public func mimeType() -> String {
        if #available(iOS 14.0, *) {
            if let pathExt = self.pathExtension,
               let mimeType = UTType(filenameExtension: pathExt)?.preferredMIMEType {
                return mimeType
            }
            else {
                return "application/octet-stream"
            }
        } else {
            // Fallback on earlier versions
            return "application/octet-stream"
        }
    }
}

extension URL {
    public func mimeType() -> String {
        if #available(iOS 14.0, *) {
            if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
                return mimeType
            }
            else {
                return "application/octet-stream"
            }
        } else {
            // Fallback on earlier versions
            return "application/octet-stream"
        }
    }
}

extension NSString {
    public func mimeType() -> String {
        if #available(iOS 14.0, *) {
            if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
                return mimeType
            }
            else {
                return "application/octet-stream"
            }
        } else {
            // Fallback on earlier versions
            return "application/octet-stream"
        }
    }
}

extension String {
    public func mimeType() -> String {
        return (self as NSString).mimeType()
    }
}
