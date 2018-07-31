//
//  APIManager.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 22/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//
import Foundation
// class to create request and launch request
class APIManager {
	let baseURL:String = "https://www.dvrgv.org/"
	private func URLRoute(route:Route) -> String {
		return baseURL + route.rawValue
	}
	private func dataToString(methods:HTTPMethods, data:[String:String]) -> String {
		var dataString:String = ""
		for (key, value) in data {
			if !(dataString.isEmpty) {
				dataString += "&"
			}
			if (methods == HTTPMethods.GET) {
				dataString += key + "="
				dataString += value
			} else {
				dataString += key + "=" + value
			}
		}
		return dataString
	}
	
	func request(methods:HTTPMethods, route:Route, data:[String:String]?) -> URLRequest {
		var URLString:String = URLRoute(route:route)
		var dataString:String = ""
		if let data = data {
			dataString = dataToString(methods: methods, data: data)
		}
		if methods == HTTPMethods.GET {
			URLString += "?" + dataString
		}
		var request:URLRequest = URLRequest(url: URL(string: URLString)!)
		request.httpMethod = methods.rawValue
		if methods != HTTPMethods.GET {
			request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
			request.httpBody = dataString.data(using:.utf8)
		}
		return request
	}
}
