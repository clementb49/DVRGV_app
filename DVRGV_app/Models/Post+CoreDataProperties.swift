//
//  Post+CoreDataProperties.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 11/08/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//
//

import Foundation
import CoreData


extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }

    @NSManaged public var commentIsOpen: Bool
    @NSManaged public var content: String?
    @NSManaged public var date_gmt:Date?
    @NSManaged public var id: Int32
    @NSManaged public var link: URL?
    @NSManaged public var modified_gmt: Date?
    @NSManaged public var title: String?
    @NSManaged public var podcastURL: URL?
    @NSManaged public var author: User?
    @NSManaged public var categories: Set<Category>?
    @NSManaged public var comments: Set<Comment>?

}

// MARK: Generated accessors for categories
extension Post {

    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: Category)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: Category)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)

}

// MARK: Generated accessors for comments
extension Post {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
