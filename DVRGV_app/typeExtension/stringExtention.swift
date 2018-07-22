//
//  stringExtention.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 22/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//
// string extention

extension String {
	func base64Encoded() -> String? {
		if let data = self.data(using: .utf8) {
			return data.base64EncodedString()
		} else {
			return nil
		}
	}
}
