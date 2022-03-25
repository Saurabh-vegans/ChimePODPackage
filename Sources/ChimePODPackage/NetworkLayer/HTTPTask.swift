//
//  HTTPTask.swift
//  NetworkLayer
//
//  Created by Diego Caroli on 06/08/2019.
//

import Foundation

public typealias HTTPHeaders = [String: String]

public enum HTTPTask {
    case request
    
    case requestParameters(bodyParameters: Parameters?,
        urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?)
    
    case requestData(body: Data,
        urlParameters: Parameters?)
    
    case requestDataAndHeaders(body: Data,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?)
    
    // other case
}
