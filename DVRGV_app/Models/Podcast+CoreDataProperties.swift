//
//  Podcast+CoreDataProperties.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 14/08/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//
//

import Foundation
import CoreData


extension Podcast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Podcast> {
        return NSFetchRequest<Podcast>(entityName: "Podcast")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var url: URL?
    @NSManaged public var post: Post?

}
