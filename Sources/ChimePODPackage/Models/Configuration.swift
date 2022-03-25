//
//  AppConfiguration.swift
//  ChimePOC
//
//  Created by Luigi Da Ros on 28/09/21.
//

import Foundation

public class VideoCallFrameworkConfiguration {
	
	static var global: VideoCallFrameworkConfiguration = VideoCallFrameworkConfiguration()
	
	let API_END_POINT: String 			//https://qxqsfb7uhh.execute-api.us-west-1.amazonaws.com/Stage
	let API_END_POINT_API_KEY: String 	//BkdF0q81yL8G6pU4Hu73C6FbcRaTNl8CaLGwvvZB
	let EVENT_END_POINT: String 		//https://jy6b8epe3i.execute-api.us-west-1.amazonaws.com/prod/meetingevents
	let EVENT_END_POINT_API_KEY: String //BkdF0q81yL8G6pU4Hu73C6FbcRaTNl8CaLGwvvZB
    let API_END_POINT_VISUAL_PROCTOR: String //https://virtualproctor.dev.bella.health
    let E2E_API_END_KEY: String //https://virtualproctor.dev.bella.health
	
	let ENABLE_LOG: Bool
	
	init() {
		API_END_POINT = ""
		API_END_POINT_API_KEY = ""
		EVENT_END_POINT = ""
		EVENT_END_POINT_API_KEY = ""
		ENABLE_LOG = false
        API_END_POINT_VISUAL_PROCTOR = ""
        E2E_API_END_KEY = ""
	}
	
	public init(apiBaseUrl: String,
				apiKey: String,
				eventBaseUrl: String,
				eventApiKey: String,
                visualProctorE2EUrl: String,
                e2eApiKey: String,
				enableLog: Bool = false) {
		API_END_POINT = apiBaseUrl
		API_END_POINT_API_KEY = apiKey
		EVENT_END_POINT = eventBaseUrl
		EVENT_END_POINT_API_KEY = eventApiKey
		ENABLE_LOG = enableLog
        API_END_POINT_VISUAL_PROCTOR = visualProctorE2EUrl
        E2E_API_END_KEY = e2eApiKey
    }
	
	public static func setConfiguration(_ config: VideoCallFrameworkConfiguration) {
		global = config
		VeganLogger.enabled = global.ENABLE_LOG
	}
	
}
