//
//  GZAlbumFabric.swift
//  mediawave
//
//  Created by George Zinyakov on 2/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GZAlbumFabric
{
    class func createOrUpdateAlbum ( withAlbum album : GZAlbum ) -> GZAlbum
    {
        // request
        let fetchRequest = NSFetchRequest(entityName: "GZAlbum")
        fetchRequest.predicate = NSPredicate(format: "mbID=%@", album.mbID)
        
        // context
        let uiContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        // launching request in context
        let fetchResults = ( try? uiContext.executeFetchRequest(fetchRequest) ) as? [GZAlbum]
        
        // refresh if smth is found
        if ( fetchResults?.count == 1 )
        {
            print("update")
            let existingAlbum = (fetchResults![0])
            existingAlbum.title = album.title
            existingAlbum.imageMedium = album.imageMedium
            try? uiContext.save()
            return existingAlbum
        }
        else
        {
            // else - create
            print("create")
            let newAlbum = NSEntityDescription.insertNewObjectForEntityForName("GZAlbum", inManagedObjectContext: uiContext) as! GZAlbum
            newAlbum.mbID = album.mbID
            newAlbum.title = album.title
            newAlbum.imageMedium = album.imageMedium
            try? uiContext.save()
            return newAlbum
        }
        
    }
}