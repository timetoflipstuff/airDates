//
//  MOShow.swift
//  airDates
//
//  Created by Alex Mikhaylov on 06/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import CoreData

@objc(MOShow)
class MOShow: NSManagedObject {
    
    @NSManaged public var id: Int32
    @NSManaged public var title: String
    @NSManaged public var imgUrl: String
    @NSManaged public var status: String?
    
    @NSManaged public var country: String?
    @NSManaged public var network: String?
    @NSManaged public var desc: String?
    @NSManaged public var nextEpisodeDateSnapshot: Date?
}
