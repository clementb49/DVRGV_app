//
//  Podcast+function.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 27/12/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import Foundation

extension Podcast {
	static func downloadImage(url: URL, handler: @escaping(Data) -> Void) {
		let task = URLSession.shared.dataTask(with: url) {data, response, error -> Void in
			if error != nil {
				handler(data!)
			} else {
				print("error \(error!.localizedDescription)")
			}
		}
		task.resume()
	}
}
