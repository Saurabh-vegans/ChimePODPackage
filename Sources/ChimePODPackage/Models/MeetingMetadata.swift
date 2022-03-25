// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let meetingMetadata = try? newJSONDecoder().decode(MeetingMetadata.self, from: jsonData)

import Foundation

// MARK: - MeetingMetadata
class MeetingMetadata: Codable {
    var isConsumer, videoUID, imei: String?

    init(isConsumer: String?, videoUID: String?, imei: String?) {
        self.isConsumer = isConsumer
        self.videoUID = videoUID
        self.imei = imei
    }
}
