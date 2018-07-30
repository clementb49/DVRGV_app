//
//  Comment+CoreDataProperties.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 30/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//
//

import Foundation
import CoreData


extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }

    @NSManaged public var author_name: String?
    @NSManaged public var content: String?
    @NSManaged public var date_gmt: NSDate?
    @NSManaged public var id: Int32
    @NSManaged public var childs: NSSet?
    @NSManaged public var parent: Comment?
    @NSManaged public var post: Post?

}

// MARK: Generated accessors for childs
extension Comment {

    @objc(addChildsObject:)
    @NSManaged public func addToChilds(_ value: Comment)

    @objc(removeChildsObject:)
    @NSManaged public func removeFromChilds(_ value: Comment)

    @objc(addChilds:)
    @NSManaged public func addToChilds(_ values: NSSet)

    @objc(removeChilds:)
    @NSManaged public func removeFromChilds(_ values: NSSet)

}
