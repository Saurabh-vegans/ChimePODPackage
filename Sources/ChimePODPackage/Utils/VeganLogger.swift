//
//  Logger.swift
//  Bella Bank
//
//  Created by Luigi Da Ros on 17/07/2020.
//  Copyright © 2020 Vegan Solutions. All rights reserved.
//

import UIKit

public class VeganLogger {
	
	static var enabled: Bool = false
	
	enum LogEvent: String {
	   case e = "‼️" // error
	   case d = "💬" // debug
	   case w = "⚠️" // warning
	}

    public static func log(_ any: Any?,
					filename: String = #file,
					line: Int = #line,
					column: Int = #column,
					funcName: String = #function){
		if !enabled {return}
		let fileNameClean = String(filename.split(separator: "/").last ?? Substring(""))
		let logHead = LogEvent.d.rawValue + " " + Date().iso8601withFractionalSeconds + " \(fileNameClean) \(funcName):\(line)"
		print(logHead, any ?? "nil", separator: "\n", terminator: "\n***************\n")
	}
	
	
    public static func err(_ any: Any?,
					filename: String = #file,
					line: Int = #line,
					column: Int = #column,
					funcName: String = #function){
		if !enabled {return}
		let fileNameClean = String(filename.split(separator: "/").last ?? Substring(""))
		let logHead = LogEvent.e.rawValue + " " + Date().iso8601withFractionalSeconds + " \(fileNameClean) \(funcName):\(line)"
		print(logHead, any ?? "nil", separator: "\n", terminator: "\n***************\n")
	}
	
    public static func warn(_ any: Any?,
					filename: String = #file,
					line: Int = #line,
					column: Int = #column,
					funcName: String = #function){
		if !enabled {return}
		let fileNameClean = String(filename.split(separator: "/").last ?? Substring(""))
		let logHead = LogEvent.w.rawValue + " " + Date().iso8601withFractionalSeconds + " \(fileNameClean) \(funcName):\(line)"
		print(logHead, any ?? "nil", separator: "\n", terminator: "\n***************\n")
	}
}


public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
	
	if !VeganLogger.enabled {return}
	
	var idx = items.startIndex
	let endIdx = items.endIndex

	repeat {
		Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
		idx += 1
	}
	while idx < endIdx
	
}


extension String {
	var iso8601withFractionalSeconds: Date? { return Formatter.iso8601withFractionalSeconds.date(from: self) }
}

extension Date {
	var iso8601withFractionalSeconds: String { return Formatter.iso8601withFractionalSeconds.string(from: self) }
}

extension Formatter {
	static var iso8601withFractionalSeconds: ISO8601DateFormatter {
		if #available(iOS 11.2, *) {
			return ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
		}
		return ISO8601DateFormatter([.withInternetDateTime])
	}
}

extension ISO8601DateFormatter {
	convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(identifier: "Europe/Rome")!) {
		self.init()
		self.formatOptions = formatOptions
		self.timeZone = timeZone
	}
}
