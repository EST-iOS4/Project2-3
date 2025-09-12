//
//  Statistics+CoreDataProperties.swift
//  FrogHouse
//
//  Created by 이건준 on 9/12/25.
//
//

import Foundation
import CoreData


extension Statistics {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Statistics> {
        return NSFetchRequest<Statistics>(entityName: "Statistics")
    }

    @NSManaged public var viewCount: Int64
    @NSManaged public var video: Video?

}

extension Statistics : Identifiable {

}
