//
//  APIService.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import SwiftCBOR

public typealias HTTPHeaders = [String: String]

extension URL {
    var urlRequest: URLRequest {
        URLRequest(url: self)
    }
}

extension URLRequest {
    var GET: URLRequest {
        var s = self
        s.httpMethod = "GET"
        return s
    }
}

public protocol CustomURLSessionProtocol {
    func request(_ urlRequest: URLRequest) -> Promise<String>
}

public struct CustomURLSession: CustomURLSessionProtocol {
    private let sessionDelegate: URLSessionDelegate?
    public static let apiHeaderETag: String = "Etag"
    
    public init(sessionDelegate: URLSessionDelegate?) {
        self.sessionDelegate = sessionDelegate
    }
    
    static func updateETag(urlResponse: URLResponse!) {
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            return
        }
        guard let urlString = httpResponse.url?.absoluteString else {
            return
        }
        guard let etag = httpResponse.allHeaderFields[apiHeaderETag] as? String else {
            return
        }
        UserDefaults.standard.setValue(etag, forKey: urlString)
    }
    
    public func request(_ urlRequest: URLRequest) -> Promise<String> {
        Promise { seal in
            print(urlRequest.url?.absoluteString ?? "")
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = CustomURLSession.defaultHTTPHeaders
            configuration.requestCachePolicy = .useProtocolCachePolicy
            let session = URLSession(configuration: configuration,
                                     delegate: self.sessionDelegate,
                                     delegateQueue: nil)
            session.dataTask(with: urlRequest) { data, response, error in
                CustomURLSession.updateETag(urlResponse: response)
                if let error = error {
                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
                        seal.reject(APIError.requestCancelled)
                        return
                    }
                    if let error = error as? URLError, error.isCancelled {
                        seal.reject(APIError.requestCancelled)
                        return
                    }
                    seal.reject(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    seal.reject(APIError.invalidResponse)
                    return
                }
                if 304 == response.statusCode  {
                    seal.reject(APIError.notModified)
                    return
                }
                
                guard (200 ... 299).contains(response.statusCode)  else {
                    seal.reject(APIError.invalidResponse)
                    return
                }
                
                guard let data = data, let dataString = String(data: data, encoding: .utf8) else {
                    seal.reject(APIError.invalidResponse)
                    return
                }
                seal.fulfill(dataString)
            }.resume()
        }
    }
    
    public static let defaultHTTPHeaders: HTTPHeaders = {
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
        let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
        }.joined(separator: ", ")
        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
                let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
                let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
                let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
                let osNameVersion: String = {
                    let version = ProcessInfo.processInfo.operatingSystemVersion
                    let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
                    let osName: String = "iOS"
                    return "\(osName) \(versionString)"
                }()
                return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"
            }
            return "Alamofire"
        }()
        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent": userAgent
        ]
    }()
    
}

public struct APIService: APIServiceProtocol {
    private let url: String
    private let contentType: String = "application/cbor+base45"
    private let customURLSession: CustomURLSessionProtocol
    private let apiHeaderNoneMatch: String = "If-None-Match"
    
    public init(customURLSession: CustomURLSessionProtocol, url: String) {
        self.customURLSession = customURLSession
        self.url = url
    }
    
    static func eTagForURL(urlString: String) -> String? {
        return UserDefaults.standard.value(forKey: urlString) as? String
    }
    
    public func fetchTrustList() -> Promise<String> {
        guard let requestUrl = URL(string: url) else {
            return Promise(error: APIError.invalidUrl)
        }
        var request = requestUrl.urlRequest.GET
        if let etag = APIService.eTagForURL(urlString: request.url?.absoluteString ?? "") {
            request.addValue(etag, forHTTPHeaderField: apiHeaderNoneMatch)
        }
        return customURLSession.request(request)
    }
    
    public func vaasListOfServices(initialisationData: ValidationServiceInitialisation) -> Promise<String> {
        let requestUrl = initialisationData.serviceIdentity
        UserDefaults.standard.set(initialisationData.token.string, forKey: "TicketingToken")
        return vaasListOfServices(url: requestUrl)
    }
    
    public func vaasListOfServices(url: URL) -> Promise<String> {
        var request = url.urlRequest.GET
        if let etag = APIService.eTagForURL(urlString: request.url?.absoluteString ?? "") {
            request.addValue(etag, forHTTPHeaderField: apiHeaderNoneMatch)
        }
        return customURLSession.request(request)
    }
    
    public func getAccessTokenFor(url : URL,
                                  servicePath : String,
                                  publicKey : String) -> Promise<String> {
        let json: [String: Any] = ["service": servicePath, "pubKey": publicKey]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json,options: .prettyPrinted)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let token = UserDefaults.standard.object(forKey: "TicketingToken") as! String
        
        request.allHTTPHeaderFields  = ["Authorization" : "Bearer " + token,
                                        "X-Version": "1.0.0",
                                        "content-type": "application/json"]

        return self.customURLSession.request(request)
    }
}
