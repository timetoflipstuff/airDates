//
//  CoreDataManager.swift
//  airDates
//
//  Created by Alex Mikhaylov on 06/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import Foundation
import CoreData
import UIKit

final class CoreDataManager {
    
    public static let shared = CoreDataManager()
    
    private let stack = CoreDataStack.shared
    
}

// MARK: - Public methods
extension CoreDataManager {
    
    public func updateShow(id: Int32, desc: String, minutesTilNextEpisode: NSNumber?, nextEpisodeString: String?, status: String?, completion: @escaping(Bool) -> Void) {
        
        stack.persistentContainer.performBackgroundTask { (context) in
            let fetchRequest = NSFetchRequest<MOShow>(entityName: "Show")
            fetchRequest.predicate = NSPredicate(format: "id = %d", id)
            do {
                let fetchedShows = try context.fetch(fetchRequest)
                
                let showToUpdate = fetchedShows[0]
                
                showToUpdate.setValue(desc, forKey: "desc")
                showToUpdate.setValue(status, forKey: "status")
                
                if let minutesTilNextEpisode = minutesTilNextEpisode {
                    showToUpdate.setValue(minutesTilNextEpisode, forKey: "minutesTilNextEpisode")
                }
                if let nextEpisodeString = nextEpisodeString {
                    showToUpdate.setValue(nextEpisodeString, forKey: "nextEpisodeString")
                }
                
                do {
                    try context.save()
                    completion(true)
                } catch {
                    print("Failed to update show: \(error)")
                    completion(false)
                }
            } catch {
                
                print("Failed to update show: \(error)")
                completion(false)
            }
        }
        
    }
    
    public func saveShow(id: Int32, title: String, imgUrl: String, completion: @escaping(Bool) -> Void) {
        
        stack.persistentContainer.performBackgroundTask { (context) in
            let show = MOShow(context: context)
            show.id = id
            show.title = title
            show.imgUrl = imgUrl
            
            do {
                try context.save()
                completion(true)
            } catch {
                print("Error saving Show: \(error)")
                completion(false)
            }
            
        }
        
    }
    
    public func deleteShow(id: Int32, completion: @escaping(Bool) -> Void) {
        
        stack.persistentContainer.performBackgroundTask { (context) in
            let fetchRequest = NSFetchRequest<MOShow>(entityName: "Show")
            fetchRequest.predicate = NSPredicate(format: "id = %d", id)
            do {
                let fetchedShows = try context.fetch(fetchRequest)
                
                let showToDelete = fetchedShows[0]
                
                context.delete(showToDelete)
                
                do {
                    try context.save()
                    completion(true)
                } catch {
                    print("Failed to delete show: \(error)")
                    completion(false)
                }
            } catch {
                
                print("Failed to delete show: \(error)")
                completion(false)
            }
        }
    }
    
    public func getFetchedResultsController() -> NSFetchedResultsController<MOShow> {
        let context = stack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<MOShow>(entityName: "Show")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "minutesTilNextEpisode", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        do {
            try controller.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        return controller
    }
    
}
