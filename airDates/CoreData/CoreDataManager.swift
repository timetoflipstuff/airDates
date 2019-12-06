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
    
    public func saveShow(id: Int32, title: String, imgUrl: String) {
        stack.persistentContainer.performBackgroundTask { (context) in
            let show = MOShow(context: context)
            show.id = id
            show.title = title
            show.imgUrl = imgUrl
            do {
                try context.save()
            } catch {
                print("Error saving Show: \(error)")
            }
        }
    }
    
    public func deleteShow(id: Int32) {
        stack.persistentContainer.performBackgroundTask { (context) in
            let fetchRequest = NSFetchRequest<MOShow>(entityName: "Show")
            fetchRequest.predicate = NSPredicate(format: "id = %d", id)
            do {
                let fetchedShows = try context.fetch(fetchRequest)
                
                let showToDelete = fetchedShows[0]
                
                context.delete(showToDelete)
                
                do {
                    try context.save()
                } catch {
                    print("Failed to delete show: \(error)")
                }
            } catch {
                print("Failed to delete show: \(error)")
            }
        }
    }
    
    public func getFetchedResultsController() -> NSFetchedResultsController<MOShow> {
        let context = stack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<MOShow>(entityName: "Show")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
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
