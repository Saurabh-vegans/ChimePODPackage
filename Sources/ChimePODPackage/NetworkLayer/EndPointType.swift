//
//  EndPointType.swift
//  NetworkLayer
//
//  Created by Diego Caroli on 06/08/2019.
//

import Foundation

public protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
    var sampleData: Data? { get }
}
