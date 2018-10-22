//
//  stringExtention.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 22/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//
// string extention
import Foundation
extension String {
	func base64Encoded() -> String? {
		if let data = self.data(using: .utf8) {
			return data.base64EncodedString()
		} else {
			return nil
		}
	}
}
extension String {
	init(htmlEncodedString: String) {
		self.init()
		guard let data = htmlEncodedString.data(using: .utf8) else {
			self = htmlEncodedString
			return
		}
		let options: [NSAttributedString.DocumentReadingOptionKey:Any] = [
		.documentType: NSAttributedString.DocumentType.html,
		.characterEncoding:String.Encoding.utf8.rawValue
		]
		do {
			let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
			self = attributedString.string
		} catch {
			print("error")
			self = htmlEncodedString
		}
	}
}
