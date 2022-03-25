// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let meetingRequestBody = try? newJSONDecoder().decode(MeetingRequestBody.self, from: jsonData)

import Foundation

// MARK: - MeetingRequest
//struct RestoreMeetingRequestBody: Codable {
//    var restoreMeeting: String?
//}

// MARK: - RestoreMeetingRequestBody
class RestoreMeetingRequestBody: Codable {
    var region: String? = "us-east-1"
    var videoUID: String?

    init(region: String?, videoUID: String?) {
        self.region = region
        self.videoUID = videoUID
    }
    
    init(videoUID: String?) {
        self.videoUID = videoUID
    }
}


// MARK: - MeetingEvent
typealias MeetingEvent = [String:Any]

struct MeetingEventResponseBody: Codable {}
