//
//  GZTrackFabric.swift
//  mediawave
//
//  Created by George Zinyakov on 2/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GZTrackFabric
{
    class func createOrUpdateTrack ( withID id : Int64, imageMedium : String, mbID : String, sourceID: String, title: String, youtubeID : String, andLoadInContext context : NSManagedObjectContext ) -> GZTrack
    {
        // request
        let fetchRequest = NSFetchRequest(entityName: "GZTrack")
        if ( mbID != "" ) {
            fetchRequest.predicate = NSPredicate(format: "mbID=%@", mbID)
        }
        else if ( youtubeID != "" ) {
            fetchRequest.predicate = NSPredicate(format: "youtubeID=%@", youtubeID)
        }
        
        // launching request in context
        let fetchResults = ( try? context.executeFetchRequest(fetchRequest) ) as? [GZTrack]
        
        // refresh if smth is found
        if ( fetchResults?.count == 1 )
        {
            print("update")
            let existingTrack = (fetchResults![0])
            existingTrack.title = title
            existingTrack.imageMedium = imageMedium
            existingTrack.id = id
            existingTrack.mbID = mbID
            existingTrack.sourceID = sourceID
            existingTrack.youtubeID = youtubeID
            return existingTrack
        }
        else
        {
            // else - create
            print("create")
            let newTrack = NSEntityDescription.insertNewObjectForEntityForName("GZTrack", inManagedObjectContext: context) as! GZTrack
            newTrack.youtubeID = youtubeID
            newTrack.title = title
            newTrack.imageMedium = imageMedium
            newTrack.id = id
            newTrack.mbID = mbID
            newTrack.sourceID = sourceID
            return newTrack
        }
        
    }
    
    class func loadExistingTrack ( withSourceID sourceID : String, andLoadInContext context : NSManagedObjectContext ) -> GZTrack?
    {
        // request
        let fetchRequest = NSFetchRequest(entityName: "GZPlaylist")
        fetchRequest.predicate = NSPredicate(format: "sourceID=%@", sourceID)
        
        // launching request in context
        let fetchResults = ( try? context.executeFetchRequest(fetchRequest) ) as? [GZTrack]
        
        // refresh if smth is found
        if ( fetchResults?.count == 1 )
        {
            print("found a track")
            let existingPlaylist = (fetchResults![0])
            return existingPlaylist
        }
        
        return nil
    }
}

