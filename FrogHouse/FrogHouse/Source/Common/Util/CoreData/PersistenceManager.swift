//
//  PersistenceManager.swift
//  FrogHouse
//
//  Created by 이건준 on 9/11/25.
//

import CoreData
import Foundation

final class PersistenceManager {
    static let shared: PersistenceManager = PersistenceManager()
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MediaModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    // MARK: - 기본 CRUD
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) throws -> [T] {
        return try self.context.fetch(request)
    }
    
    func updateVideo(videoID: UUID, updateBlock: (Video) -> Void) throws {
        let context = self.context
        let request: NSFetchRequest<Video> = Video.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", videoID as CVarArg)
        request.fetchLimit = 1
        
        if let video = try context.fetch(request).first {
            updateBlock(video)
            try context.save() 
        }
    }
    
    func delete(object: NSManagedObject) throws {
        self.context.delete(object)
        try self.context.save()
    }
    
    func deleteAll<T: NSManagedObject>(request: NSFetchRequest<T>) throws {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: T.fetchRequest())
        try self.context.execute(deleteRequest)
    }
    
    func insertVideo(video: Video) throws {
        let context = PersistenceManager.shared.context
        
        let managedVideo = Video(context: context)
        managedVideo.id = video.id
        managedVideo.title = video.title
        managedVideo.descriptionText = video.descriptionText
        managedVideo.mp4URL = video.mp4URL
        managedVideo.thumbnailURL = video.thumbnailURL
        managedVideo.isLiked = video.isLiked
        
        if let categories = video.categories as? Set<Category> {
            for category in categories {
                let managedCategory = Category(context: context)
                managedCategory.name = category.name
                managedVideo.addToCategories(managedCategory)
                managedCategory.addToVideos(managedVideo)
            }
        }
        
        let managedStatistics = Statistics(context: context)
        managedStatistics.viewCount = video.statistics.viewCount
        managedStatistics.video = managedVideo
        managedVideo.statistics = managedStatistics
        
        try context.save()
    }
    
    
    func insertVideos(videos: [Video]) throws {
        for video in videos {
            try insertVideo(video: video)
        }
    }
}
