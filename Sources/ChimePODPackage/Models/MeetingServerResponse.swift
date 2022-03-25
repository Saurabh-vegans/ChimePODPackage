// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let meetingServerResponse = try? newJSONDecoder().decode(MeetingServerResponse.self, from: jsonData)

import Foundation

// MARK: - MeetingServerResponse
class MeetingServerResponse: Codable {
    var meeting: ServerResponseMeetingMeeting?
    var attendee: ServerResponseAttendee?

    init(meeting: ServerResponseMeetingMeeting?, attendee: ServerResponseAttendee?) {
        self.meeting = meeting
        self.attendee = attendee
    }
}

// MARK: - Attendee
class ServerResponseAttendee: Codable {
    var externalUserID, attendeeID, joinToken: String?

    enum CodingKeys: String, CodingKey {
        case externalUserID = "ExternalUserId"
        case attendeeID = "AttendeeId"
        case joinToken = "JoinToken"
    }

    init(externalUserID: String?, attendeeID: String?, joinToken: String?) {
        self.externalUserID = externalUserID
        self.attendeeID = attendeeID
        self.joinToken = joinToken
    }
}

// MARK: - Meeting
class ServerResponseMeetingMeeting: Codable {
    var meetingID, externalMeetingID: String?
    var mediaPlacement: ServerResponseMediaPlacement?
    var mediaRegion: String?

    enum CodingKeys: String, CodingKey {
        case meetingID = "MeetingId"
        case externalMeetingID = "ExternalMeetingId"
        case mediaPlacement = "MediaPlacement"
        case mediaRegion = "MediaRegion"
    }

    init(meetingID: String?, externalMeetingID: String?, mediaPlacement: ServerResponseMediaPlacement?, mediaRegion: String?) {
        self.meetingID = meetingID
        self.externalMeetingID = externalMeetingID
        self.mediaPlacement = mediaPlacement
        self.mediaRegion = mediaRegion
    }
}

// MARK: - MediaPlacement
class ServerResponseMediaPlacement: Codable {
    var audioHostURL, audioFallbackURL, screenDataURL, screenSharingURL: String?
    var screenViewingURL, signalingURL: String?
    var turnControlURL: String?
    var eventIngestionURL: String?

    enum CodingKeys: String, CodingKey {
        case audioHostURL = "AudioHostUrl"
        case audioFallbackURL = "AudioFallbackUrl"
        case screenDataURL = "ScreenDataUrl"
        case screenSharingURL = "ScreenSharingUrl"
        case screenViewingURL = "ScreenViewingUrl"
        case signalingURL = "SignalingUrl"
        case turnControlURL = "TurnControlUrl"
        case eventIngestionURL = "EventIngestionUrl"
    }

    init(audioHostURL: String?, audioFallbackURL: String?, screenDataURL: String?, screenSharingURL: String?, screenViewingURL: String?, signalingURL: String?, turnControlURL: String?, eventIngestionURL: String?) {
        self.audioHostURL = audioHostURL
        self.audioFallbackURL = audioFallbackURL
        self.screenDataURL = screenDataURL
        self.screenSharingURL = screenSharingURL
        self.screenViewingURL = screenViewingURL
        self.signalingURL = signalingURL
        self.turnControlURL = turnControlURL
        self.eventIngestionURL = eventIngestionURL
    }
}
