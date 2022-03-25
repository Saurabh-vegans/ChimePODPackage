//
//  Err.swift
//  ChimePOC
//
//  Created by Luigi Da Ros on 28/09/21.
//

import Foundation
import UIKit

// MARK: - error class
public struct ServerErr: Codable, Error {
	
    public static var unmanagedResponse: ServerErr {
		return ServerErr(withDescription: NSLocalizedString("error_unmanagedResponse", tableName: nil, bundle: .main, value: "Unable to manage the response", comment: "Unable to manage the response"))
	}
	public static var unmanagedError: ServerErr {
		return ServerErr(withDescription: NSLocalizedString("error_unmanagedError", tableName: nil, bundle: .main, value: "We apologize for the inconvenience, but we are experiencing technical difficulties", comment: "We apologize for the inconvenience, but we are experiencing technical difficulties"))
	}
	public static var missingMandatoryData: ServerErr {
		return ServerErr(withDescription: NSLocalizedString("error_missingMandatoryData", tableName: nil, bundle: .main, value: "Unable to process the request", comment: "Unable to process the request"))
	}
	public static var decodeFail: ServerErr {
		return ServerErr(withDescription: NSLocalizedString("error_decodeFail", tableName: nil, bundle: .main, value: "Unable to decode data", comment: "Unable to decode data"))
	}
	public static var dataFetchMissing:ServerErr {
		return ServerErr(withDescription: NSLocalizedString("error_unmanagedError", tableName: nil, bundle: .main, value: "We apologize for the inconvenience, but we are experiencing technical difficulties", comment: "We apologize for the inconvenience, but we are experiencing technical difficulties"))
	}
	public static func generic(_ desc: String? = nil) -> ServerErr {
		return ServerErr(withDescription: desc ?? NSLocalizedString("error_unmanagedError", tableName: nil, bundle: .main, value: "We apologize for the inconvenience, but we are experiencing technical difficulties", comment: "We apologize for the inconvenience, but we are experiencing technical difficulties"))
	}
	public static func info(_ desc: String? = nil) -> ServerErr {
		var e = ServerErr(withDescription: desc ?? NSLocalizedString("error_unmanagedError", tableName: nil, bundle: .main, value: "We apologize for the inconvenience, but we are experiencing technical difficulties", comment: "We apologize for the inconvenience, but we are experiencing technical difficulties"))
		e.errType = .info
		return e
	}
	public static var idmDown:ServerErr {
		return ServerErr(withDescription: NSLocalizedString("error_unmanagedError", tableName: nil, bundle: .main, value: "We apologize for the inconvenience, but we are experiencing technical difficulties", comment: "We apologize for the inconvenience, but we are experiencing technical difficulties"))
	}

	
	var environment: Env?
	var faults: [Error]?
	var timeStamp: String?

	var errType: ErrType = .attention
	
	enum CodingKeys: String, CodingKey {
		case environment = "environment"
		case faults = "faults"
		case timeStamp = "timeStamp"
	}
	
	init(withDescription errorDescription: String, andCustomCode code: Code? = nil) {
		
		environment = Env(label: "Local", node: nil)
		var newErr = Error()
		newErr.faultMessage = errorDescription
		newErr.faultCode = code?.rawValue
		faults = [newErr]
		timeStamp = ""
		
	}
	
	init(withNetworkError error: NetworkError) {
		
		environment = Env(label: "Local", node: nil)
		var newErr = Error()
		
		switch error {
		case .parametersNil:
			newErr.faultMessage = "Parameters were nil."
		case .encodingFailed:
			newErr.faultMessage = "Parameter encoding failed."
		case .missingURL:
			newErr.faultMessage = "URL is nil."
		case .authenticationError:
			newErr.faultMessage = NSLocalizedString("technical_issue_error_message", tableName: nil, bundle: .main, value: "We apologize for the inconvenience, but we are experiencing technical difficulties", comment: "We apologize for the inconvenience, but we are experiencing technical difficulties")
			newErr.faultCode = "UNAUTHORIZED"
		case .badRequest:
			newErr.faultMessage = "Bad request."
		case .outdated:
			newErr.faultMessage = "The URL request is outdated."
		case .failed:
			newErr.faultMessage = "Network request failed."
		case .noData:
			newErr.faultMessage = "Response returned with no data to decode."
		case .unableToDecode (let errorDesc):
			newErr.faultMessage = "We could not decode the response \(errorDesc ?? ".")"
		case .server:
			newErr.faultMessage = NSLocalizedString("technical_issue_error_message", tableName: nil, bundle: .main, value: "We apologize for the inconvenience, but we are experiencing technical difficulties", comment: "We apologize for the inconvenience, but we are experiencing technical difficulties")
		case .client:
			newErr.faultMessage = "Client Error"
		case .forbidden:
			newErr.faultMessage = NSLocalizedString("technical_issue_error_message", tableName: nil, bundle: .main, value: "We apologize for the inconvenience, but we are experiencing technical difficulties", comment: "We apologize for the inconvenience, but we are experiencing technical difficulties")
		case .notFound:
			newErr.faultMessage = "The resource could not be found."
		case .missingMockedFile:
			newErr.faultMessage = "missing mocked json file"
		case .cancelled:
			newErr.faultMessage = NSLocalizedString("technical_issue_error_message", tableName: nil, bundle: .main, value: "We apologize for the inconvenience, but we are experiencing technical difficulties", comment: "We apologize for the inconvenience, but we are experiencing technical difficulties")
		case .timeout:
			newErr.faultMessage = "The request has timed out."
		case .offline:
			newErr.faultMessage = "The Internet connection appears to be offline."
		default:
			newErr.faultMessage = error.localizedDescription
		}

		faults = [newErr]
		timeStamp = ""

		
	}

	public init(from decoder: Decoder) throws{
		
		//try new error before
		let container = try decoder.container(keyedBy: CodingKeys.self)
		do {
			
			faults = try container.decode([Error].self, forKey: .faults)
			environment = try container.decodeIfPresent(Env.self, forKey: .environment)
			timeStamp = try container.decodeIfPresent(String.self, forKey: .timeStamp)
			
		} catch {
			
			faults = []
			environment = nil
			timeStamp = ""
		}
		
	}
	
	// MARK: - Environment
	struct Env: Codable {
		let label: String?
		let node: String?

		enum CodingKeys: String, CodingKey {
			case label = "label"
			case node = "node"
		}
	}
	
	enum ErrType {
		
		case attention
		case error
		case info
		
		var defaultTitle: String {
			var t = NSLocalizedString("Error", tableName: nil, bundle: .main, value: "Error", comment: "Error")
			switch self {
				case .attention:
					t = NSLocalizedString("Attention", tableName: nil, bundle: .main, value: "Attention", comment: "Attention")
				case .error:
					t = NSLocalizedString("Error", tableName: nil, bundle: .main, value: "Error", comment: "Error")
				case .info:
					t = NSLocalizedString("Info", tableName: nil, bundle: .main, value: "Info", comment: "Info")
			}
			return t
		}
		
	}
	
	// MARK Error
	struct Error: Codable {
		
		var faultMessage: String?
		var service: String?
		var origin: String?
		var fields: [String]?
		var faultLevel: String?
		var faultDescription: String?
		var faultCode: String?

		enum CodingKeys: String, CodingKey {
			case faultMessage = "faultMessage"
			case service = "service"
			case origin = "origin"
			case fields = "fields"
			case faultLevel = "faultLevel"
			case faultDescription = "faultDescription"
			case faultCode = "faultCode"
		}
		
		var errorCode: Code? {
			return Code(rawValue: faultCode ?? "")
		}

		var prettyPrinted: String {
			return """
			code: \(faultCode ?? "")
			description: \(faultDescription ?? "")
			"""
		}
	}
	
//	var status: String? {
//		errors.first?.status
//	}
	
	var errorCode: String? {
		faults?.first?.faultCode
	}
	
	var errorMessage: String {
		
		var errMsg = NSLocalizedString("technical_issue_error_message", tableName: nil, bundle: .main, value: "We apologize for the inconvenience, but we are experiencing technical difficulties", comment: "We apologize for the inconvenience, but we are experiencing technical difficulties")
		
		if let msg = self.faultMessage,
		   isUserFriendly(msg) {
				errMsg = msg
		}
		
		let desc = self.faultDescription ?? ""
				
		if isUserFriendly(desc) {
			errMsg += "\n" + desc
		}
		
		errMsg += debugInfo
		
		return errMsg
		
	}
	
	var errorMessageShort: String? {
		get{
			
			if let msg = self.faultMessage {
				return isUserFriendly(msg) ? msg : NSLocalizedString("technical_issue_error_message", tableName: nil, bundle: .main, value: "We apologize for the inconvenience, but we are experiencing technical difficulties", comment: "We apologize for the inconvenience, but we are experiencing technical difficulties")
			}

			return nil
			
		}
	}
	
	
	var faultMessage: String? {
		faults?.first?.faultMessage
	}
	
	
	var faultDescription: String? {
		faults?.first?.faultDescription
	}
	
	var errorTimestamp: String? {
		self.timeStamp
	}
		
	var debugInfo: String {
		return ""
	}
	
	private func isUserFriendly(_ text: String) -> Bool {
		
		let str = text.lowercased()
		
		let nonAllowedUnfriendlyContent = ["java.",
						  "javax.",
						  "org.postgresql",
						  "org.jdbi",
						  "org.glassfish.",
						  "it.vegans."
		]
		
		if str == "" || str == "n/a" || str == "n/d" || str == " " {
			return false
		}
		
		if nonAllowedUnfriendlyContent.contains(where: { (unfriendlyContent) -> Bool in
			return str.contains(unfriendlyContent)
		}) {
			return false
		}
				
		return true
		
	}

	func has(code: Code) -> Bool {
		return self.faults?.first(where: { (e) -> Bool in
			e.errorCode == code
		}) != nil
	}
	
	public static func create(from data: Data?) -> ServerErr? {
		guard let data = data, !data.isEmpty else { return nil }
		return try? JSONDecoder().decode(ServerErr.self, from: data)
	}
	
	enum Code: String, Codable {
		case NONE = "-N-O-N-E-"
	}

}


extension ServerErr: LocalizedError {
	
	public var errorDescription: String? {
		return self.errorMessage
	}
	
	public var localizedDescription: String {
		return self.errorMessage
	}
}
