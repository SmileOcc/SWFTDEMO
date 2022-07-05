//
//  HCMoyaConfig.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit
import Moya
import Alamofire

public let requestTimeoutClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        request.timeoutInterval = 15
        done(.success(request))
    } catch MoyaError.requestMapping(let url) {
        done(.failure(MoyaError.requestMapping(url)))
    } catch MoyaError.parameterEncoding(let error) {
        done(.failure(MoyaError.parameterEncoding(error)))
    } catch {
        done(.failure(MoyaError.underlying(error, nil)))
    }
}

public class HCMoyaConfig {
    @objc public static let certFileName = "certificate.cer"
    
    private final class func publicKey(for certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?

        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)

        if let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }

        return publicKey
    }
    
    private final class func certificateFile() -> URL? {
        guard
            let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return nil
        }
        
        let file = document.appendingPathComponent(HCMoyaConfig.certFileName)
        return file
    }
    
    fileprivate final class func appHttpsEvaluatorsKey() -> String {
        return HCUrlRouterConstant.appHttpsEvaluatorsKey()
    }
    
    public final class func serverTrustManager() -> ServerTrustManager? {
        #if PRD || PRD_HK
        var evaluators: [String: ServerTrustEvaluating] = [
            // 默认情况下，包含在 app bundle 的来自证书的公钥会被自动使用。
            YXMoyaConfig.appHttpsEvaluatorsKey() : PublicKeysTrustEvaluator()
        ]
        
        if
            let url = certificateFile(),
            let certificateData = try? Data(contentsOf: url) as CFData,
            let certificate = SecCertificateCreateWithData(nil, certificateData),
            let secKey = publicKey(for: certificate)
        {
            evaluators = [
                HCMoyaConfig.appHttpsEvaluatorsKey() : PublicKeysTrustEvaluator(
                    keys : [secKey]
                )
            ]
        }
        return HCServerTrustManager(evaluators: evaluators)
        #else
        return nil
        #endif
    }
    
    public final class func interceptor() -> RequestInterceptor? {
        return Retrier { (request, session, error, completion) in
            if let urlString: String = request.request?.url?.absoluteString {
                if urlString.hasSuffix(HCRetryConfigAPI.guests.path) {
                    if request.retryCount < 5 {
                        completion(.retryWithDelay(TimeInterval(1.0)))
                    } else {
                        completion(.doNotRetry)
                    }
                } else {
                    completion(.doNotRetry)
                }
            }
        }
    }
    
    public final class func session() -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default

        return Session(
            configuration: configuration,
            startRequestsImmediately: false,
            interceptor : HCMoyaConfig.interceptor(),
            serverTrustManager : HCMoyaConfig.serverTrustManager()
        )
    }
}

public class HCServerTrustManager: ServerTrustManager {
    private let lock = NSRecursiveLock()
    
    public override func serverTrustEvaluator(forHost host: String) throws -> ServerTrustEvaluating? {
        lock.lock(); defer { lock.unlock() }
        
        if let evaluator = evaluators[host] {
            return evaluator
        }
        
        var domainComponents = host.split(separator: ".")
        if domainComponents.count == 3 {
            domainComponents[0] = "*"
            let wildcardHost = domainComponents.joined(separator: ".")
            return evaluators[wildcardHost]
        }
        return nil
    }
}

