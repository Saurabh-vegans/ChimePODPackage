// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let meetingServerResponse = try? newJSONDecoder().decode(MeetingServerResponse.self, from: jsonData)

import Foundation

// MARK: - MeetingServerResponse
class InternalMeetingServerResponse: Codable {
    var meeting: InternalResponseMeeting?
	var localAttendee: InternalResponseAttendee?

    init(meeting: InternalResponseMeeting?, attendee: InternalResponseAttendee?) {
        self.meeting = meeting
        self.localAttendee = attendee
    }
}

// MARK: - Ent
class InternalResponseAttendee: Codable {
	var attendee: ResponseAttendee?

	enum CodingKeys: String, CodingKey {
		case attendee = "Attendee"
	}

	init(attendee: ResponseAttendee?) {
		self.attendee = attendee
	}
}

// MARK: - Attendee
class ResponseAttendee: Codable {
    var joinToken, externalUserID, attendeeID: String?

    enum CodingKeys: String, CodingKey {
        case joinToken = "JoinToken"
        case externalUserID = "ExternalUserId"
        case attendeeID = "AttendeeId"
    }

    init(joinToken: String?, externalUserID: String?, attendeeID: String?) {
        self.joinToken = joinToken
        self.externalUserID = externalUserID
        self.attendeeID = attendeeID
    }
}

// MARK: - Meeting
class InternalResponseMeeting: Codable {
    var meetingID, externalMeetingID, mediaRegion: String?
    var mediaPlacement: InternalResponseMediaPlacement?

    enum CodingKeys: String, CodingKey {
        case meetingID = "MeetingId"
        case externalMeetingID = "ExternalMeetingId"
        case mediaRegion = "MediaRegion"
        case mediaPlacement = "MediaPlacement"
    }

    init(meetingID: String?, externalMeetingID: String?, mediaRegion: String?, mediaPlacement: InternalResponseMediaPlacement?) {
        self.meetingID = meetingID
        self.externalMeetingID = externalMeetingID
        self.mediaRegion = mediaRegion
        self.mediaPlacement = mediaPlacement
    }
}

// MARK: - MediaPlacement
class InternalResponseMediaPlacement: Codable {
    var audioHostURL, screenSharingURL, screenDataURL, signalingURL: String?
    var audioFallbackURL: String?
    var eventIngestionURL: String?
    var screenViewingURL: String?
    var turnControlURL: String?

    enum CodingKeys: String, CodingKey {
        case audioHostURL = "AudioHostUrl"
        case screenSharingURL = "ScreenSharingUrl"
        case screenDataURL = "ScreenDataUrl"
        case signalingURL = "SignalingUrl"
        case audioFallbackURL = "AudioFallbackUrl"
        case eventIngestionURL = "EventIngestionUrl"
        case screenViewingURL = "ScreenViewingUrl"
        case turnControlURL = "TurnControlUrl"
    }

    init(audioHostURL: String?, screenSharingURL: String?, screenDataURL: String?, signalingURL: String?, audioFallbackURL: String?, eventIngestionURL: String?, screenViewingURL: String?, turnControlURL: String?) {
        self.audioHostURL = audioHostURL
        self.screenSharingURL = screenSharingURL
        self.screenDataURL = screenDataURL
        self.signalingURL = signalingURL
        self.audioFallbackURL = audioFallbackURL
        self.eventIngestionURL = eventIngestionURL
        self.screenViewingURL = screenViewingURL
        self.turnControlURL = turnControlURL
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
