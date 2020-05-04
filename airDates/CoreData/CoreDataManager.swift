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

    func updateShow(id: Int32, desc: String, minutesTilNextEpisode: NSNumber?, nextEpisodeString: String?, status: String?, country: String?, network: String?, completion: @escaping(Bool) -> Void) {

        stack.persistentContainer.performBackgroundTask { (context) in
            let fetchRequest = NSFetchRequest<MOShow>(entityName: "Show")
            fetchRequest.predicate = NSPredicate(format: "id = %d", id)
            do {
                let fetchedShows = try context.fetch(fetchRequest)
                
                let showToUpdate = fetchedShows[0]
                
                showToUpdate.setValue(desc, forKey: "desc")
                showToUpdate.setValue(status, forKey: "status")
                
                showToUpdate.setValue(country ?? nil, forKey: "country")
                showToUpdate.setValue(network ?? nil, forKey: "network")

                showToUpdate.setValue(minutesTilNextEpisode ?? 1000000, forKey: "minutesTilNextEpisode")
                showToUpdate.setValue(nextEpisodeString ?? nil, forKey: "nextEpisodeString")
                
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
    
    func saveShow(id: Int32, title: String, imgUrl: String, status: String?, completion: @escaping(Bool) -> Void) {
        
        stack.persistentContainer.performBackgroundTask { (context) in
            let show = MOShow(context: context)
            show.id = id
            show.title = title
            show.imgUrl = imgUrl
            show.status = status
            
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
    
    func getFetchedResultsController() -> NSFetchedResultsController<MOShow> {
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

    // MARK: - Network

    func updateSavedShowData(completion: @escaping (() -> Void) = {}) {

        guard let fetchedShows = getFetchedResultsController().fetchedObjects else { return }

        let dispatchGroup = DispatchGroup()

        for fetchedShow in fetchedShows {

            dispatchGroup.enter()

            NetworkManager.shared.getShowData(id: fetchedShow.id) { showData in

                guard let showData = showData else {
                    dispatchGroup.leave()
                    return
                }

                var minutesTilNextEpisode: NSNumber? = 1000000
                var nextEpisodeString: String? = nil
                let status = showData.tvShow.status
                let desc = showData.tvShow.description
                let country = showData.tvShow.country
                let network = showData.tvShow.network

                if let countdown = showData.tvShow.countdown {
                    nextEpisodeString = ModelHelper.shared.formNextEpisodeString(apiDateString: countdown.air_date)
                    minutesTilNextEpisode = ModelHelper.shared.getMinutesTilNextEpisode(apiDateString: countdown.air_date)
                }

                CoreDataManager.shared.updateShow(id: fetchedShow.id, desc: desc, minutesTilNextEpisode: minutesTilNextEpisode, nextEpisodeString: nextEpisodeString, status: status, country: country, network: network) { _ in
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
}
