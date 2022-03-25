// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let attandeeLeftMeetingResponse = try? newJSONDecoder().decode(AttandeeLeftMeetingResponse.self, from: jsonData)

import Foundation

// MARK: - AttendeeLeftMeetingResponse
struct AttendeeLeftMeetingResponse: Codable {
    var result: String?

    init(result: String?) {
        self.result = result
    }
}
