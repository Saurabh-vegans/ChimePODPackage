//
//  Router.swift
//  NetworkLayer
//
//  Created by Diego Caroli on 06/08/2019.
//

import Foundation

open class Router<EndPoint: EndPointType>: NSObject, NetworkRouter, URLSessionTaskDelegate {
    private var task: URLSessionTask?
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    private lazy var pinningValidator = SSLPinningValidator()
	private var configuration: NetworkLayerRouterGlobalConfig = NetworkLayerRouterGlobalConfig()

	@available(*, deprecated, message: "You should use init(withConfig:) instead of this")
    public init(sslPinning: Bool = false) {
		self.configuration.sslPinningValidation = sslPinning
    }
	
	public init(withConfig conf: NetworkLayerRouterGlobalConfig) {
		super.init()
		self.configuration = conf
		self.session = URLSession(configuration: conf.urlSessionConfiguration, delegate: self, delegateQueue: nil)
		
	}

    open func mocked(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        if let data = route.sampleData, !data.isEmpty {
            let response = HTTPURLResponse(
                url: route.baseURL.appendingPathComponent(route.path),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil)
            completion(data,response,nil)
        } else {
            completion(nil, nil, NetworkError.missingMockedFile)
        }
    }

    open func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        do {
            let request = try self.buildRequest(from: route)
            task = session.dataTask(with: request) { data, response, error in
                if EnvironmentVariables.verboseNetworkLogger.isEnabled {
                    NetworkLogger.log(request: request, response: response, dataResponse: data)
                }
                completion(data, response, error)
            }
        } catch {
            completion(nil, nil, error)
        }
        self.task?.resume()
    }

    open func cancel() {
        self.task?.cancel()
    }

    private func buildRequest(from route: EndPoint) throws -> URLRequest {

        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
								 cachePolicy: configuration.requestCachePolicy,
								 timeoutInterval: configuration.timeoutInterval)

        request.httpMethod = route.httpMethod.rawValue

        if let headers = route.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters,
                                    let urlParameters):

                try configureParameters(bodyParameters: bodyParameters,
                                        urlParameters: urlParameters,
                                        request: &request)

            case .requestParametersAndHeaders(let bodyParameters,
                                              let urlParameters,
                                              let additionalHeaders):

                addAdditionalHeaders(additionalHeaders, request: &request)
                try configureParameters(bodyParameters: bodyParameters,
                                        urlParameters: urlParameters,
                                        request: &request)
            case .requestData(let body,
                              let urlParameters):
                if let urlParameters = urlParameters {
                    try Encoders.encodeAsURL(urlRequest: &request, with: urlParameters)
                }
                Encoders.addEncodedBody(body: body, request: &request)

            case .requestDataAndHeaders(let body,
                                        let urlParameters,
                                        let additionHeaders):

                addAdditionalHeaders(additionHeaders, request: &request)
                if let urlParameters = urlParameters {
                    try Encoders.encodeAsURL(urlRequest: &request, with: urlParameters)
                }
                Encoders.addEncodedBody(body: body, request: &request)

            }
            return request
        } catch {
            throw error
        }
    }

    private func configureParameters(bodyParameters: Parameters?,
                                     urlParameters: Parameters?,
                                     request: inout URLRequest) throws {
        if let bodyParameters = bodyParameters, let urlParameters = urlParameters {
            try Encoders.encodeAsJSON(urlRequest: &request, with: bodyParameters)
            try Encoders.encodeAsURL(urlRequest: &request, with: urlParameters)
        } else if let urlParameters = urlParameters {
            try Encoders.encodeAsURL(urlRequest: &request, with: urlParameters)
        } else if let bodyParameters = bodyParameters {
            try Encoders.encodeAsJSON(urlRequest: &request, with: bodyParameters)
        }
    }

    private func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

    // MARK: - URLSession Task Delegate
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		if !configuration.sslPinningValidation {
            let serverTrust = challenge.protectionSpace.serverTrust
            let credential: URLCredential = URLCredential(trust: serverTrust!)
            completionHandler(.useCredential, credential)
        } else {
            let challengeValidationResult = pinningValidator.validateChallenge(challenge, forSession: session)
            if challengeValidationResult.isValid {
                completionHandler(.useCredential, challengeValidationResult.credential)
                return
            }

            // Pinning failed
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

}
