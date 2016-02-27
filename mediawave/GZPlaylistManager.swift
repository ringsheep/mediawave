//
//  GZPlaylistManager.swift
//  mediawave
//
//  Created by George Zinyakov on 2/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit
import CoreData


class GZPlaylistManager: NSObject {
    
}

//MARK: Search for youtube playlists by array of selected tags
extension GZPlaylistManager
{
    class func getYTPlaylists( tags: Array<GZLFTag>, perPage: Int, pageNumber: Int )
    {
        GZAPI_WRAPPER.getAllYoutubePlaylistsByQuery(tags, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let uiContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = uiContext
            
            let playlists:Array<JSON> = jsonResponse["items"].arrayValue
            
            for ( var i:Int64 = 0 ; i < Int64(playlists.count) ; i++ )
            {
                let playlist = playlists[Int(i)]
                let id = i
                let title = playlist["snippet"]["title"].stringValue
                let summary = playlist["snippet"]["description"].stringValue
                let jsonImage = playlist["snippet"]["thumbnails"]["high"]["url"].stringValue
                guard !(jsonImage.isEmpty) else {
                    return
                }
                
                let playlistID = playlist["id"]["playlistId"].stringValue
                guard !(playlistID.isEmpty) else {
                    return
                }

                GZPlaylistFabric.createOrUpdatePlaylist(withPlaylistID: playlistID, id: id, title: title, imageMedium: jsonImage, summary: summary , andLoadInContext: privateContext )
            }
            
            try? privateContext.save()
            
            }) { () -> Void in
                
        }

    }
    
}

//MARK: Load existing playlist with id
extension GZPlaylistManager
{
    class func loadYTPlaylist( playlistID: String )
    {
        
        let uiContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.parentContext = uiContext
        
        GZPlaylistFabric.loadExistingPlaylist(withPlaylistID: playlistID, andLoadInContext: privateContext)
        
        try? privateContext.save()
        
    }
    
}