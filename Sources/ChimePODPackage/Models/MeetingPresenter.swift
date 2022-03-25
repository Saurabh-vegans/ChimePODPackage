//
//  MeetingPresenter.swift
//  ChimePOC
//
//  Created by Luigi Villa on 18/10/21.
//

import Foundation
import AmazonChimeSDK

public protocol MeetingPresenter: AnyObject {
    var isTest: Bool {get}
    
    /// The view for the local camera capture source
    var videoView: DefaultVideoRenderView? { get }
    var remoteVideoView: DefaultVideoRenderView? { get }
    
    // MARK: - Methods invoked by the MeetingManager
}
