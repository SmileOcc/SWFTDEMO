//
//  HCNetworkLoggerPlugin.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import Foundation
import Moya

/// Logs network activity (outgoing requests and incoming responses).
public final class HCNetworkLoggerPlugin: PluginType {
    fileprivate let loggerId = "Moya_Logger"
    fileprivate let dateFormatString = "dd/MM/yyyy HH:mm:ss"
    fileprivate let dateFormatter = DateFormatter()
    fileprivate let separator = ", "
    fileprivate let terminator = "\n"
    fileprivate let cURLTerminator = "\\\n"
    fileprivate let output: (_ separator: String, _ terminator: String, _ success: Bool,  _ items: Any...) -> Void
    fileprivate let requestDataFormatter: ((Data) -> (String))?
    fileprivate let responseDataFormatter: ((Data) -> (Data))?
    
    /// A Boolean value determing whether response body data should be logged.
    public let isVerbose: Bool
    public let cURL: Bool
    
    /// Initializes a YXNetworkLoggerPlugin.
    public init(verbose: Bool = false, cURL: Bool = false, output: ((_ separator: String, _ terminator: String, _ success: Bool, _ items: Any...) -> Void)? = nil, requestDataFormatter: ((Data) -> (String))? = nil, responseDataFormatter: ((Data) -> (Data))? = nil) {
        self.cURL = cURL
        self.isVerbose = verbose
        self.output = output ?? HCNetworkLoggerPlugin.reversedPrint
        self.requestDataFormatter = requestDataFormatter
        self.responseDataFormatter = responseDataFormatter
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        if let request = request as? CustomDebugStringConvertible, cURL {
            output(separator, terminator, true, request.debugDescription)
            return
        }
        outputItems(logNetworkRequest(request.request as URLRequest?))
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if case .success(let response) = result {
            outputItems(logNetworkResponse(response.response, data: response.data, target: target))
        } else {
            outputItems(logNetworkResponse(nil, data: nil, target: target), success: false)
        }
    }
    
    fileprivate func outputItems(_ items: [String], success: Bool = true) {
        if isVerbose {
            items.forEach { output(separator, terminator, success, $0) }
        } else {
            output(separator, terminator, success, items)
        }
    }
}

private extension HCNetworkLoggerPlugin {
    
    var date: String {
        dateFormatter.dateFormat = dateFormatString
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: Date())
    }
    
    func format(_ loggerId: String, date: String, identifier: String, message: String) -> String {
        return "\(loggerId): [\(date)] \(identifier): \(message)"
    }
    
    func logNetworkRequest(_ request: URLRequest?) -> [String] {
        
        var output = [String]()
        
        output += [format(loggerId, date: date, identifier: "Request", message: request?.description ?? "(invalid request)")]
        
        if let headers = request?.allHTTPHeaderFields {
            output += [format(loggerId, date: date, identifier: "Request Headers", message: headers.description)]
        }
        
        if let bodyStream = request?.httpBodyStream {
            output += [format(loggerId, date: date, identifier: "Request Body Stream", message: bodyStream.description)]
        }
        
        if let httpMethod = request?.httpMethod {
            output += [format(loggerId, date: date, identifier: "HTTP Request Method", message: httpMethod)]
        }
        
        if let body = request?.httpBody, let stringOutput = requestDataFormatter?(body) ?? String(data: body, encoding: .utf8), isVerbose {
            output += [format(loggerId, date: date, identifier: "Request Body", message: stringOutput)]
        }
        
        return output
    }
    
    func logNetworkResponse(_ response: HTTPURLResponse?, data: Data?, target: TargetType) -> [String] {
        defer {
            if response != nil
                && !(response?.statusCodeValidator() ?? false)
                && response?.statusCode != 0 {
//                HCRealLogger.shareInstance.realLog(type: "ApiError", name: "接口Error", url: response?.url?.absoluteString, code: "\(response?.statusCode ?? 0)", desc: "", extend_msg: "")
            }
        }
        
        guard let response = response else {
            return [format(loggerId, date: date, identifier: "Response", message: "Received empty network response for \(target).")]
        }
        
        var output = [String]()
        
        output += [format(loggerId, date: date, identifier: "Response", message: response.description)]
        
        if let data = data, let stringData = String(data: responseDataFormatter?(data) ?? data, encoding: String.Encoding.utf8), isVerbose {
            output += [stringData]
        }
        
        return output
    }
}

fileprivate extension HTTPURLResponse {
    func statusCodeValidator() -> Bool {
        return (statusCode >= 200 && statusCode <= 299);
    }
}

fileprivate extension HCNetworkLoggerPlugin {
    static func reversedPrint(_ separator: String, terminator: String, success: Bool, items: Any...) {
        for item in items {
            if success {
                //log(.debug, tag: kNetwork, content: "\(item)\n")
            } else {
                //log(.warning, tag: kNetwork, content: "\(item)\n")
            }
        }
    }
}

