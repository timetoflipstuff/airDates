//
//  CoreDataStack.swift
//  airDates
//
//  Created by Alex Mikhaylov on 06/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "DataModel")
        let group = DispatchGroup()
        group.enter()
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
            group.leave()
        }
        group.wait()
    }
    
}
