//
//  GZPlaylistFabric.swift
//  mediawave
//
//  Created by George Zinyakov on 2/15/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GZPlaylistFabric
{
    class func createOrUpdatePlaylist ( withPlaylistID playlistID : String, id : Int64, title : String, imageMedium : String, summary : String , andLoadInContext context : NSManagedObjectContext ) -> GZPlaylist
    {
        // request
        let fetchRequest = NSFetchRequest(entityName: "GZPlaylist")
        fetchRequest.predicate = NSPredicate(format: "playlistID=%@", playlistID)
        print(fetchRequest.predicate)
        
        // launching request in context
        let fetchResults = ( try? context.executeFetchRequest(fetchRequest) ) as? [GZPlaylist]
        
        // refresh if smth is found
        if ( fetchResults?.count == 1 )
        {
            print("update")
            let existingPlaylist = (fetchResults![0])
            existingPlaylist.title = title
            existingPlaylist.playlistID = playlistID
            existingPlaylist.imageMedium = imageMedium
            existingPlaylist.summary = summary
            return existingPlaylist
        }
        else
        {
            // else - create
            print("create")
            let newPlaylist = NSEntityDescription.insertNewObjectForEntityForName("GZPlaylist", inManagedObjectContext: context) as! GZPlaylist
            newPlaylist.playlistID = playlistID
            newPlaylist.id = id
            newPlaylist.title = title
            newPlaylist.imageMedium = imageMedium
            newPlaylist.summary = summary
            print(newPlaylist.playlistID)
            return newPlaylist
        }
        
        
    }
    
    class func loadExistingPlaylist ( withPlaylistID playlistID : String , andLoadInContext context : NSManagedObjectContext ) -> GZPlaylist?
    {
        // request
        let fetchRequest = NSFetchRequest(entityName: "GZPlaylist")
        fetchRequest.predicate = NSPredicate(format: "playlistID=%@", playlistID)
        
        // launching request in context
        let fetchResults = ( try? context.executeFetchRequest(fetchRequest) ) as? [GZPlaylist]
        
        // refresh if smth is found
        if ( fetchResults?.count == 1 )
        {
            print("found a playlist")
            let existingPlaylist = (fetchResults![0])
            return existingPlaylist
        }
        
        return nil
    }
}

