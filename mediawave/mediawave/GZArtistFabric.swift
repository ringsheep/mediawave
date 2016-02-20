//
//  GZArtistFabric.swift
//  mediawave
//
//  Created by George Zinyakov on 2/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GZArtistFabric
{
    class func createOrUpdatePlaylist ( withArtist artist : GZArtist ) -> GZArtist
    {
        // request
        let fetchRequest = NSFetchRequest(entityName: "GZPlaylist")
        fetchRequest.predicate = NSPredicate(format: "playlistID=%d", artist.mbID)
        
        // context
        let uiContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        // launching request in context
        let fetchResults = ( try? uiContext.executeFetchRequest(fetchRequest) ) as? [GZArtist]
        
        // refresh if smth is found
        if ( fetchResults?.count == 1 )
        {
            print("update")
            let existingArtist = (fetchResults![0])
            existingArtist.name = artist.name
            existingArtist.imageMedium = artist.imageMedium
            existingArtist.summary = artist.summary
            
            return existingArtist
        }
        else
        {
            // else - create
            print("create")
            let newArtist = NSEntityDescription.insertNewObjectForEntityForName("GZArtist", inManagedObjectContext: uiContext) as! GZArtist
            newArtist.mbID = artist.mbID
            newArtist.name = artist.name
            newArtist.imageMedium = artist.imageMedium
            newArtist.summary = artist.summary
            
            return newArtist
        }
        
    }
}