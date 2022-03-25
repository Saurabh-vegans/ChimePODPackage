//
//  GlobalAPI.swift
//  ChimePOC
//
//  Created by Luigi Da Ros on 28/09/21.
//

import Foundation

enum GlobalAPI {
    case join(body: RestoreMeetingRequestBody)
    case events(data:[MeetingEvent])
    case leave(body: AttendeeLeftMeetingBody)
    case visualProctor(base64: String)
}

extension GlobalAPI: EndPointType {
    var baseURL: URL {
        
        switch self {
        case .join, .leave:
            guard let url = URL(string: VideoCallFrameworkConfiguration.global.API_END_POINT) else {
                fatalError("global VideoCallFrameworkConfiguration 'API_END_POINT' are not configured")
            }
            return url
        case .events:
            guard let url = URL(string: VideoCallFrameworkConfiguration.global.EVENT_END_POINT) else {
                fatalError("global VideoCallFrameworkConfiguration 'API_END_POINT' are not configured")
            }
            return url
        case .visualProctor:
            guard let url = URL(string: VideoCallFrameworkConfiguration.global.API_END_POINT_VISUAL_PROCTOR) else {
                fatalError("global VideoCallFrameworkConfiguration 'API_END_POINT_VISUAL_PROCTOR' are not configured")
            }
            return url
        }
    }
    
    var path: String {
        switch self {
        case .join:
            return "/startMeeting"
        case .events:
            return "/"
        case .leave:
            return "/deleteAttendee"
        case .visualProctor:
            return ""
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .join,
                .events,
                .leave:
            return .post
        case .visualProctor:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .join(let body):
            return NetworkManager.shared().encodeRequestData(payload: body, parameters: nil)
        case .events(let requestData):
            do {
                let data = try JSONSerialization.data(withJSONObject: requestData)
                return .requestData(body: data, urlParameters: nil)
            } catch {
                return .request
            }
        case .leave(let body):
            return NetworkManager.shared().encodeRequestData(payload: body, parameters: nil)
        case .visualProctor(let base64):
            return NetworkManager.shared().requestParametersAndHeaders(bodyParameters: nil,
                                                                       urlParameters: ["data" : base64],
                                                                       additionHeaders: nil)
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .visualProctor:
            var headers = NetworkManager.getHeaders(for: self)
            
            // Add the new Authorization header
            let authorization = "chime:7iSApsCFtKEgBc2G".data(using: .ascii)?.base64EncodedString() ?? ""
            headers["Authorization"] = "Basic " + authorization
            
            return headers
        default:
            return NetworkManager.getHeaders(for: self)
        }
        
    }
    
    var sampleData: Data? {
        return nil
    }
}
