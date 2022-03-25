//
//  RouterHelper.swift
//  NetworkLayer
//
//  Created by Diego Caroli on 06/08/2019.
//

import Foundation

open class RouterHelper {
    
    private static let decoder = JSONDecoder()
    private static let encoder = JSONEncoder()
    
    open class func handleNetworkResponse(_ response: HTTPURLResponse, errorData: Data?) -> Result<String, NetworkError> {
        switch response.statusCode {
        case 200...299: return .success("success")
        case 400: return .failure(NetworkError.badRequest)
        case 401: return .failure(NetworkError.authenticationError)
        case 403: return .failure(NetworkError.forbidden)
        case 404: return .failure(NetworkError.notFound)
        case 400..<500: return .failure(NetworkError.client(errorData))
        case 500...599: return .failure(NetworkError.server(errorData))
        case 600: return .failure(NetworkError.outdated)
        default: return .failure(NetworkError.failed(errorData))
        }
    }
    
    open class func handleParsingError(_ error: Error) -> String {
        var errorMessage = "Undetermined decoding error"
        
        guard let decodingError = error as? DecodingError else {
            print("Error on parsing is not a DecodingError")
            return errorMessage
        }
        
        switch decodingError {
        case .typeMismatch(_, let context),
             .valueNotFound(_, let context),
             .keyNotFound(_, let context),
             .dataCorrupted(let context):
            
            if let field = context.codingPath.last?.stringValue {
                errorMessage = "For \"\(field)\" field :: " + context.debugDescription
            }
        @unknown default:
            print("Unknown DecodingError case - Switch statement should be updated")
        }
        
        return errorMessage
    }
    
    open class func checkResponse(
        _ data: Data?,
        _ response: URLResponse?,
        _ error: Error?,
        completionHandler: @escaping (Result<Data?, NetworkError>) -> Void) {
        
		let errorCode = (error as NSError?)?.code
		if errorCode == NSURLErrorCancelled {
			completionHandler(.failure(NetworkError.cancelled))
			return
		}else if errorCode == NSURLErrorTimedOut {
			completionHandler(.failure(NetworkError.timeout))
			return
		}else if errorCode == NSURLErrorNetworkConnectionLost
		   || errorCode == NSURLErrorNotConnectedToInternet
		   || errorCode == NSURLErrorCannotConnectToHost {
			completionHandler(.failure(NetworkError.offline))
			return
		}

		
        guard error == nil else {
            completionHandler(.failure(NetworkError.generic(error)))
            return
        }
        
        if let response = response as? HTTPURLResponse {
            completionHandler(handleNetworkResponse(response, errorData: data).map { _ in
                return data
            })
        }
    }
    
    open class func validateNoBody(response:URLResponse?, error:Error?, completionHandler: @escaping (Result<Bool,NetworkError>) -> Void) {
        
        checkResponse(nil, response, error) { (result) in
            switch result{
            case .success:
                completionHandler(.success(true))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    open class func validateData(
        _ data: Data?,
        _ response: URLResponse?,
        _ error: Error?,
        completionHandler: @escaping (Result<Data, NetworkError>) -> Void) {
        
        checkResponse(data, response, error) { (result) in
            switch result {
            case .success:
                guard let responseData = data else {
                    completionHandler(.failure(NetworkError.noData))
                    return
                }
                completionHandler(.success(responseData))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    open class func decode<T: Decodable>(
        _ data: Data?,
        _ response: URLResponse?,
        _ error: Error?,
        completionHandler: @escaping (Result<T, NetworkError>) -> Void) {
        
        validateData(data, response, error) { (result) in
            switch result {
            case .success(let respData):
                do {
                    let apiResponse = try decoder.decode(T.self, from: respData)
                    completionHandler(.success(apiResponse))
                } catch {
                    completionHandler(.failure(NetworkError.unableToDecode(handleParsingError(error))))
                }
            case .failure(let respErr):
                completionHandler(.failure(respErr))
            }
        }
    }
    
    open class func encode<T: Encodable>(
        _ request: T?,
        onSuccess: @escaping (Data) -> (),
        onFailure: @escaping (Result<T, NetworkError>) -> Void) {
        do {
            onSuccess(try encoder.encode(request))
        } catch {
            print(error.localizedDescription)
            onFailure(.failure(.encodingFailed))
        }
    }
    
    open class func stubbedResponse(forFileName: String) -> Data? {
        guard let path = Bundle.main.path(forResource: forFileName, ofType: "json") else {
            return nil
        }
        
        let fileURL = URL(fileURLWithPath: path)
        return try? Data(contentsOf: fileURL, options: .mappedIfSafe)
    }

}
