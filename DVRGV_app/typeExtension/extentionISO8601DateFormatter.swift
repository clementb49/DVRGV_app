//
//  extentionISO8601DateFormatter.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 07/02/2019.
//  Copyright © 2019 Clément BOUSSIRON. All rights reserved.
//

import Foundation

extension ISO8601DateFormatter {
	convenience init(_ formatOptions:Options, timeZone:TimeZone = TimeZone(secondsFromGMT: 0)!) {
		self.init()
		self.formatOptions = formatOptions
		self.timeZone = timeZone
	}
}

extension Formatter {
	static let iso8601 = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}

extension Date {
	var iso8601:String {
		return Formatter.iso8601.string(from: self)
	}
}

