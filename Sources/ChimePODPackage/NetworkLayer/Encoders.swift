//
//  Encoders.swift
//  NetworkLayer
//
//  Created by Vincenzo Rippa on 27/08/2019.
//

import Foundation

public typealias Parameters = [String: Any]

public struct Encoders {
    
    public static func encodeAsURL(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        
        guard let url = urlRequest.url else { throw NetworkError.missingURL }
        
        if var urlComponents = URLComponents(url: url,
                                             resolvingAgainstBaseURL: false), !parameters.isEmpty {
            
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key,
                                             value: "\(value)")
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        
    }
    
    public static func encodeAsJSON(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        
        let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        addEncodedBody(body: jsonAsData, request: &urlRequest)
        
    }
    
    public static func addEncodedBody(body: Data,
                         request: inout URLRequest) {
        
        request.httpBody = body
        
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
    }
    
}
