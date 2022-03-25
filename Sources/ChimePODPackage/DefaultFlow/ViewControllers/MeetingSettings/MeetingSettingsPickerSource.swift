//
//  File.swift
//  
//
//  Created by Luigi Da Ros on 04/11/21.
//

import UIKit
import AmazonChimeSDK

protocol MeetingSettingsPickerSourceDelegate: AnyObject {
	func pickerDidSelectRow(row: Int, sender: MeetingSettingsPickerSource)
}

class MeetingSettingsPickerSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
	
	var devices: [MediaDevice]?
	
	weak var delegate: MeetingSettingsPickerSourceDelegate?
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return devices?.count ?? 0
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if let toRet = devices?[row].description
		{
			return toRet
		}
		
		return nil
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		delegate?.pickerDidSelectRow(row: row, sender: self)
	}
}
