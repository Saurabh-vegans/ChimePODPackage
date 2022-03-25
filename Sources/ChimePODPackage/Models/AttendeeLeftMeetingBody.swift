// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let attendeeLeftMeetingBody = try? newJSONDecoder().decode(AttendeeLeftMeetingBody.self, from: jsonData)

import Foundation

// MARK: - AttendeeLeftMeetingBody
struct AttendeeLeftMeetingBody: Codable {
    var meetingID, attendeeID: String?

    enum CodingKeys: String, CodingKey {
        case meetingID = "meetingId"
        case attendeeID = "attendeeId"
    }

    init(meetingID: String?, attendeeID: String?) {
        self.meetingID = meetingID
        self.attendeeID = attendeeID
    }
}
