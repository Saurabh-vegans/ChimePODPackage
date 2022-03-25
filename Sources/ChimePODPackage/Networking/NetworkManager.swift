//
//  NetworkManager.swift
//  ChimePOC
//
//  Created by Luigi Da Ros on 28/09/21.
//

import Foundation
import AmazonChimeSDK

class NetworkManager {
	
	private static var sharedInstance: NetworkManager?

	static func shared() -> NetworkManager {
		if sharedInstance == nil {
			sharedInstance = NetworkManager()
		}
		return sharedInstance!
	}

	private lazy var globalRouter = Router<GlobalAPI>(withConfig: NetworkManager.routerConfiguration)

	static var routerConfiguration: NetworkLayerRouterGlobalConfig
    {
		let conf = NetworkLayerRouterGlobalConfig()
		conf.timeoutInterval = 60.0
		conf.sslPinningValidation = false
		
		let urlConfig = URLSessionConfiguration.default
		urlConfig.urlCache = URLCache()
		urlConfig.urlCache?.diskCapacity = 0
		conf.urlSessionConfiguration = urlConfig
        
		return conf
	}
	
	private static func getComonHeaders() -> HTTPHeaders {
		var headers = HTTPHeaders()
        headers["Content-Type"] = "application/json"
		headers["Accept"] = "application/json"
		headers["x-language"] = "en"
		headers["X-API-KEY"] = VideoCallFrameworkConfiguration.global.API_END_POINT_API_KEY
		
        return headers
	}
	
	static func getHeaders(for endpoint: GlobalAPI?) -> HTTPHeaders {
		var commonHeaders = getComonHeaders()
		switch endpoint {
			case .events:
				commonHeaders["X-API-KEY"] = VideoCallFrameworkConfiguration.global.EVENT_END_POINT_API_KEY
			default:
				break
		}
		return commonHeaders
	}
}


extension NetworkManager {
	func globalJoinMeeting(body: RestoreMeetingRequestBody, completionHandler: @escaping (Result<MeetingServerResponse?, ServerErr>) -> Void) {
		globalRouter.request(.join(body: body)) { (data, response, error) in
			RouterHelper.decode(data, response, error) { (result: Result<MeetingServerResponse, NetworkError>) in
				switch result {
				case .success(let data):
					completionHandler(Result.success(data))
				case .failure(let error):
					completionHandler(.failure(ServerErr(withNetworkError: error)))
				}
			}
		}
	}
    
    func requestE2EVideoTest(base64: String, completionHandler: @escaping (ServerErr?) -> Void) {
        globalRouter.request(.visualProctor(base64: base64)) { (data, response, error) in
            RouterHelper.decode(data, response, error) { (result: Result<String?, NetworkError>) in
                switch result {
                case .success:
                    completionHandler(nil)
                case .failure(let error):
                    completionHandler(ServerErr(withNetworkError: error))
                }
            }
        }
    }
	
	func postMeetingEvents(events: [MeetingEvent], completionHandler: @escaping (Result<MeetingEventResponseBody, ServerErr>) -> Void) {
		globalRouter.request(.events(data: events)) { (data, response, error) in
			RouterHelper.decode(data, response, error) { (result: Result<MeetingEventResponseBody, NetworkError>) in
				switch result {
				case .success(let data):
					completionHandler(Result.success(data))
				case .failure(let error):
					completionHandler(.failure(ServerErr(withNetworkError: error)))
				}
			}
		}
	}
    
    func globalLeftMeeting(body: AttendeeLeftMeetingBody, completionHandler: @escaping (Result<AttendeeLeftMeetingResponse?, ServerErr>) -> Void) {
        globalRouter.request(.leave(body: body)) { (data, response, error) in
            RouterHelper.decode(data, response, error) { (result: Result<AttendeeLeftMeetingResponse?, NetworkError>) in
                switch result {
                case .success(let data):
                    completionHandler(Result.success(data))
                case .failure(let error):
                    completionHandler(.failure(ServerErr(withNetworkError: error)))
                }
            }
        }
    }
}

extension NetworkManager
{
    func encodeRequestData<T : Encodable>(payload: T, parameters: Parameters?)->HTTPTask
    {
        let encoder = JSONEncoder()
        do
        {
            let data = try encoder.encode(payload)
            return .requestData(body: data, urlParameters: parameters)
        }
        catch
        {
            return .request
        }
    }
    
    func requestParametersAndHeaders(bodyParameters: Parameters?, urlParameters: Parameters?, additionHeaders: HTTPHeaders?)->HTTPTask {
        return .requestParametersAndHeaders(bodyParameters: bodyParameters, urlParameters: urlParameters, additionHeaders: additionHeaders)
    }
}
