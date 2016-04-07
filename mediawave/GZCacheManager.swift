//
//  GZCacheManager.swift
//  mediawave
//
//  Created by George Zinyakov on 4/4/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import CoreData

class GZCacheManager: GZQueueManager {
    static var createOrUpdateSearchCache:GZdownloadPlaylistItemsByID?
}

// MARK: - Search caching
extension GZCacheManager {
    class func cacheSearchQuery( withQuery query: String, andPropagateToContext parentContext: NSManagedObjectContext ) {
        
        let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.parentContext = parentContext
        
        GZSearchCacheFabric.createOrUpdateSearchCache(withQuery: query, andLoadInContext: privateContext)
        
        try? privateContext.save()
    
    }
}