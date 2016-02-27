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
    class func createOrUpdatePlaylist ( withid id : Int64, playlistID : String, title : String, imageMedium : String, summary : String ) -> GZPlaylist
    {
        // request
        let fetchRequest = NSFetchRequest(entityName: "GZPlaylist")
        fetchRequest.predicate = NSPredicate(format: "id=%d", id)
        print(fetchRequest.predicate)
        
        // context
        let uiContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        // launching request in context
        let fetchResults = ( try? uiContext.executeFetchRequest(fetchRequest) ) as? [GZPlaylist]
        print(fetchResults?.count)
        
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
            let newPlaylist = NSEntityDescription.insertNewObjectForEntityForName("GZPlaylist", inManagedObjectContext: uiContext) as! GZPlaylist
            newPlaylist.playlistID = playlistID
            newPlaylist.id = id
            newPlaylist.title = title
            newPlaylist.imageMedium = imageMedium
            newPlaylist.summary = summary

            return newPlaylist
        }
        
    }
    
    class func loadExistingPlaylist (withID id : Int64, success : ( existingPlaylist : GZPlaylist) -> Void , failure : () -> Void )
    {
        // request
        let fetchRequest = NSFetchRequest(entityName: "GZPlaylist")
        fetchRequest.predicate = NSPredicate(format: "id=%d", id)
        
        // context
        let uiContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        // launching request in context
        let fetchResults = ( try? uiContext.executeFetchRequest(fetchRequest) ) as? [GZPlaylist]
        
        // refresh if smth is found
        if ( fetchResults?.count == 1 )
        {
            print("found a playlist")
            let existingPlaylist = (fetchResults![0])
            success(existingPlaylist: existingPlaylist)
        }
        else {
            print("no playlists found")
            failure()
        }
    }
}

