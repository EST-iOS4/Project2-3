//
//  Video+CoreDataProperties.swift
//  FrogHouse
//
//  Created by 이건준 on 9/12/25.
//
//

import Foundation
import CoreData


extension Video {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video")
    }

    @NSManaged public var descriptionText: String
    @NSManaged public var id: UUID
    @NSManaged public var isLiked: Bool
    @NSManaged public var mp4URL: URL?
    @NSManaged public var thumbnailURL: URL?
    @NSManaged public var title: String
    @NSManaged public var categories: NSSet
    @NSManaged public var statistics: Statistics
    @NSManaged public var createdAt: Date

}

// MARK: Generated accessors for categories
extension Video {

    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: Category)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: Category)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)

}

extension Video : Identifiable {
    var videoCategories: [VideoCategory] {
        guard let categoriesSet = self.categories as? Set<Category> else { return [] }
        return categoriesSet.map { $0.videoCategory }
    }
}
