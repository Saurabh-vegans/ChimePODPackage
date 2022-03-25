//
//  MeetingUIManager.swift
//  
//
//  Created by Luigi Da Ros on 04/11/21.
//

import Foundation
import UIKit

class MeetingUIManager {

	/// Configures all the UI of the package
	static func configurePackageUI() {
		loadPackageFonts()
	}

	static func image(_ name: String) -> UIImage? {
		return UIImage(named: name, in: Bundle.module, compatibleWith: nil)
	}
	
	private static func loadPackageFonts() {
	
		// All the filenames of your custom fonts here
		let fontNames = ["Rubik-MediumItalic.ttf",
						 "Rubik-Bold.ttf",
						 "Rubik-Light.ttf",
						 "Rubik-Medium.ttf",
						 "Rubik-Black.ttf",
						 "Rubik-Italic.ttf",
						 "Rubik-LightItalic.ttf",
						 "Rubik-BlackItalic.ttf",
						 "Rubik-Regular.ttf",
						 "Rubik-BoldItalic.ttf"
		]
	
		fontNames.forEach{registerFont(fileName: $0)}
		
	}

	private static func registerFont(fileName: String) {
	
		guard let pathForResourceString = Bundle.module.path(forResource: fileName, ofType: nil),
			  let fontData = NSData(contentsOfFile: pathForResourceString),
			  let dataProvider = CGDataProvider(data: fontData),
			  let fontRef = CGFont(dataProvider) else {
			print("*** ERROR: ***")
			return
		}
	
		var errorRef: Unmanaged<CFError>? = nil
	
		if !CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) {
			print("*** ERROR: \(errorRef.debugDescription) ***")
		}
	}
	
}
