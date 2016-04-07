//
//  GZSearchCacheFabric.swift
//  mediawave
//
//  Created by George Zinyakov on 4/4/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import CoreData

class GZSearchCacheFabric {
    class func createOrUpdateSearchCache( withQuery query: String, andLoadInContext context: NSManagedObjectContext ) -> GZSearchCache {
        
        let fetchRequest = NSFetchRequest(entityName: "GZSearchCache")
        fetchRequest.predicate = NSPredicate(format: "title=%@", query)
        
        let fetchResults = ( try? context.executeFetchRequest(fetchRequest) ) as? [GZSearchCache]
        
        // если что-то найдено - обновить
        if ( fetchResults?.count == 1 )
        {
            print("update")
            let searchCache = (fetchResults![0])
            
            searchCache.date = NSDate()
            return searchCache
        }
        else
        {
            // иначе - создать
            print("create")
            let newSearchCache = NSEntityDescription.insertNewObjectForEntityForName("GZSearchCache", inManagedObjectContext: context) as! GZSearchCache
            
            newSearchCache.title = query
            newSearchCache.date = NSDate()
            return newSearchCache
        }
    }
}