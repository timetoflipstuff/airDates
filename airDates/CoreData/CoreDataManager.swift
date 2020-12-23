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

    static let shared = CoreDataManager()

    private let stack = CoreDataStack.shared

    func saveShow(id: Int32, completion: @escaping(Bool) -> Void) {

        stack.persistentContainer.performBackgroundTask { context in
            let show = MOShow(context: context)
            show.id = id

            do {
                try context.save()
                completion(true)
            } catch {
                print("Error saving Show: \(error)")
                completion(false)
            }
        }
    }
    
    func deleteShow(id: Int32, completion: @escaping(Bool) -> Void) {
        
        stack.persistentContainer.performBackgroundTask { (context) in
            let fetchRequest = NSFetchRequest<MOShow>(entityName: "Show")
            fetchRequest.predicate = NSPredicate(format: "id = %d", id)
            do {
                let fetchedShows = try context.fetch(fetchRequest)

                guard fetchedShows.count > 0 else {
                    print("Show entity with ID \(id) not found")
                    return
                }

                let showToDelete = fetchedShows[0]

                context.delete(showToDelete)

                try context.save()
                completion(true)

            } catch {
                
                print("Failed to delete show: \(error)")
                completion(false)
            }
        }
    }
    
    func getFetchedResultsController() -> NSFetchedResultsController<MOShow> {
        let context = stack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<MOShow>(entityName: "Show")

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

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
