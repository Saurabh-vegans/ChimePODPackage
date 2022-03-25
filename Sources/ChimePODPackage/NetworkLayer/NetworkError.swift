//
//  NetworkError.swift
//  NetworkLayer
//
//  Created by Diego Caroli on 06/08/2019.
//

import Foundation

public enum NetworkError: Error, Equatable {
    
    public static func ==(lhs: NetworkError, rhs: NetworkError) -> Bool {
        return String(reflecting: lhs) == String(reflecting: rhs)
    }
    
    case parametersNil
    case encodingFailed
    case missingURL
    case authenticationError
    case badRequest
    case outdated
    case failed(Data?)
    case generic(Error?)
    case noData
    case unableToDecode(String?)
    case server(Data?)
    case missingMockedFile
    case client(Data?)
    case forbidden
    case notFound
    case tooManyRequest
    case conflict
	case cancelled
	case timeout
	case offline
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .parametersNil:
            return "Parameters were nil."
        case .encodingFailed:
            return "Parameter encoding failed."
        case .missingURL:
            return "URL is nil."
        case .authenticationError:
            return "Invalid username or password. "
        case .badRequest:
            return "Bad request."
        case .outdated:
            return "The URL request is outdated."
        case .failed:
            return "Network request failed."
        case .generic(let error):
            return error?.localizedDescription
        case .noData:
            return "Response returned with no data to decode."
        case .unableToDecode (let errorDesc):
            return "We could not decode the response \(errorDesc ?? ".")"
        case .server:
            return "Server Error"
        case .client:
            return "Client Error"
        case .forbidden:
            return "The request was formatted correctly but the server is refusing to supply the requested resource. ."
        case .notFound:
            return "The resource could not be found."
        case .missingMockedFile:
            return "missing mocked json file"
        case .tooManyRequest:
            return "Handle too many request"
        case .conflict:
            return "Resource conflict"
		case .cancelled:
			return "cancelled"
		case .timeout:
			return "The request has timed out."
		case .offline:
			return "The Internet connection appears to be offline."
		}
    }

    public var dataError: Data? {
        switch self {
        case .client(let data),
             .server(let data),
             .failed(let data):
            return data
        default:
            return nil
        }
    }
}
