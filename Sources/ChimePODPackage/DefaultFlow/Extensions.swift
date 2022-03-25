//
//  File.swift
//  
//
//  Created by Luigi Da Ros on 03/11/21.
//

import Foundation
import UIKit

@IBDesignable internal extension UIView
{
	@IBInspectable var cornerRadius: CGFloat {
		get{
			return layer.cornerRadius
		}
		set{
			layer.cornerRadius = newValue
		}
	}
	
	@IBInspectable var borderColor: UIColor?
		{
		set{
			layer.borderColor = newValue?.cgColor
		}
		get{
			return layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) : nil
		}
	}
	
	@IBInspectable var borderWidth: CGFloat {
		get{
			return layer.borderWidth
		}
		set {
			layer.borderWidth = newValue
		}
	}
	
	@IBInspectable var dropShadowOffset: CGSize {
		get{
			return layer.shadowOffset
		}
		set {
			layer.shadowOffset = newValue
		}
	}
	
	@IBInspectable var maskToBounds: Bool {
		get{
			return layer.masksToBounds
		}
		set{
			layer.masksToBounds = newValue
		}
	}
	
	@IBInspectable var dropShadowColor: UIColor? {
		get{
			return layer.shadowColor != nil ? UIColor(cgColor: layer.shadowColor!) : nil
		}
		set {
			layer.shadowColor = newValue?.cgColor
		}
	}
	
	@IBInspectable var dropShadowRadius: CGFloat {
		get{
			return layer.shadowRadius
		}
		set{
			layer.shadowRadius = newValue
		}
	}
	
	@IBInspectable var dropShadowOpacity: Float {
		get{
			return layer.shadowOpacity
		}
		set {
			layer.shadowOpacity = newValue
		}
	}
	
	open override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
	}
}

// This is a trick to show the view in IB
@IBDesignable class RoundView: UIView
{
	
}

// This is a trick to show the view in IB
@IBDesignable class RoundLabel: UILabel
{
}

// This is a trick to show the view in IB
@IBDesignable class RoundButton: UIButton
{
	@IBInspectable var enabledBackgroundColor: UIColor?
	@IBInspectable var disabledBackgroundColor: UIColor?
	
	override var isEnabled: Bool {
		didSet{
			backgroundColor = isEnabled ? enabledBackgroundColor : disabledBackgroundColor
		}
	}
}


@IBDesignable class RoundTextField: UITextField
{
	@IBInspectable var topTextInset: CGFloat = 0
	@IBInspectable var leftTextInset: CGFloat = 0
	@IBInspectable var bottomTextInset: CGFloat = 0
	@IBInspectable var rightTextInset: CGFloat = 0
	
	override func textRect(forBounds bounds: CGRect) -> CGRect
	{
		let textPadding: UIEdgeInsets = UIEdgeInsets(
			top: topTextInset,
			left: leftTextInset,
			bottom: bottomTextInset,
			right: rightTextInset
		)
		
		let rect = super.textRect(forBounds: bounds)
		return rect.inset(by: textPadding)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect
	{
		let textPadding: UIEdgeInsets = UIEdgeInsets(
			top: topTextInset,
			left: leftTextInset,
			bottom: bottomTextInset,
			right: rightTextInset
		)
		
		let rect = super.editingRect(forBounds: bounds)
		return rect.inset(by: textPadding)
	}
	
	@IBInspectable var placeHolderColor:UIColor?{
		didSet{
			if self.attributedPlaceholder != nil
			{
				let newString:NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedPlaceholder!)
				newString.addAttribute(NSAttributedString.Key.foregroundColor, value: placeHolderColor as Any, range: NSRange.init(location: 0, length: newString.length))
				self.attributedPlaceholder = newString
			}
		}
	}
}


extension UIView {
	var renderedImage: UIImage {

	  // The size of the image we want to create, based on the size of the
	  // current view.
	  let rect = self.bounds

	  // Start an image context, using the rect from above to set the size.
	  UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
	  let context: CGContext = UIGraphicsGetCurrentContext()!

	  // Render the current view into the image context.
	  self.layer.render(in: context)

	  // Extract an image from the context.
	  let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

	  UIGraphicsEndImageContext()
	  return capturedImage
	}
  }

extension UIView {

	/**
	 Rotate a view by specified degrees

	 - parameter angle: angle in degrees
	 */
	func rotate(angle: CGFloat) {
		let radians = angle / 180.0 * CGFloat.pi
		let rotation = self.transform.rotated(by: radians);
		self.transform = rotation
	}

	func shake() {
		let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
		animation.duration = 0.6
		animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -5.0, 5.0, 0.0 ]
		layer.add(animation, forKey: "shake")
	}

}
