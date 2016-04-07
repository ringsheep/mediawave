//
//  GZSearchCache.swift
//  mediawave
//
//  Created by George Zinyakov on 4/4/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import CoreData

class GZSearchCache: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var date: NSDate
}
