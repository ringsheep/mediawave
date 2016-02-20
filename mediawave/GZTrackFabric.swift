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
    class func createOrUpdateTrack ( withTrack track : GZTrack ) -> GZTrack
    {
        // request
        let fetchRequest = NSFetchRequest(entityName: "GZTrack")
        fetchRequest.predicate = NSPredicate(format: "youtubeID=%d", track.youtubeID)
        
        // context
        let uiContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        // launching request in context
        let fetchResults = ( try? uiContext.executeFetchRequest(fetchRequest) ) as? [GZTrack]
        
        // refresh if smth is found
        if ( fetchResults?.count == 1 )
        {
            print("update")
            let existingTrack = (fetchResults![0])
            existingTrack.title = track.title
            existingTrack.imageMedium = track.imageMedium
            
            return existingTrack
        }
        else
        {
            // else - create
            print("create")
            let newTrack = NSEntityDescription.insertNewObjectForEntityForName("GZTrack", inManagedObjectContext: uiContext) as! GZTrack
            newTrack.youtubeID = track.youtubeID
            newTrack.title = track.title
            newTrack.imageMedium = track.imageMedium
            
            return newTrack
        }
        
    }
}

