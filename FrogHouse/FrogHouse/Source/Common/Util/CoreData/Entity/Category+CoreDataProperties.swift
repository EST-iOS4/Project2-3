//
//  Category+CoreDataProperties.swift
//  FrogHouse
//
//  Created by 이건준 on 9/12/25.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String
    @NSManaged public var videos: NSSet?

}

// MARK: Generated accessors for videos
extension Category {

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: Video)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: Video)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)

}

extension Category : Identifiable {
    var videoCategory: VideoCategory {
        return VideoCategory(rawValue: self.name) ?? .unknown
    }
}
