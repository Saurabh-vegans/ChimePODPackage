//
//  Environment.swift
//  
//
//  Created by Diego Caroli on 02/03/2020.
//

import Foundation

enum EnvironmentVariables: String {
	case verboseNetworkLogger = "verbose_network_logger"

    private var value: String {
        let val = ProcessInfo.processInfo.environment[rawValue]
        return val ?? ""
    }

    var isEnabled: Bool {
        return value == "true"
    }
}

///global configurations for Router
open class NetworkLayerRouterGlobalConfig {
	
	open var sslPinningValidation: Bool = false
	open var urlSessionConfiguration: URLSessionConfiguration = .default
	open var requestCachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData
	open var timeoutInterval: TimeInterval = 60
	
	public init(){
		
	}
	
}
