//
//  CustomSortDescriptor.swift
//  airDates
//
//  Created by Alex Mikhaylov on 08.07.2020.
//  Copyright © 2020 Alexander Mikhaylov. All rights reserved.
//

import CoreData

/// Created with the purpose of sorting nil values last.
final class CustomSortDescriptor: NSSortDescriptor {

    override func copy(with zone: NSZone? = nil) -> Any {
        return CustomSortDescriptor(key: self.key, ascending: self.ascending, selector: self.selector)
    }

    override var reversedSortDescriptor: Any {
        return CustomSortDescriptor(key: self.key, ascending: !self.ascending, selector: self.selector)
    }

    override func compare(_ object1: Any, to object2: Any) -> ComparisonResult {


        if (object1 as AnyObject).value(forKey: self.key!) == nil && (object2 as AnyObject).value(forKey: self.key!) == nil {
            return .orderedSame
        }

        if (object1 as AnyObject).value(forKey: self.key!) == nil {
            return .orderedDescending
        }
        if (object2 as AnyObject).value(forKey: self.key!) == nil {
            return .orderedAscending
        }

        return super.compare(object1, to: object2)
    }
}
