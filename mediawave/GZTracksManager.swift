//
//  GZTracksManager.swift
//  mediawave
//
//  Created by George Zinyakov on 2/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit
import CoreData

class GZTracksManager {
    
}

//MARK: Get youtube playlist items by playlist ID
extension GZTracksManager
{   
    class func getYTPlaylistItems( id: String, perPage: Int, pageNumber: Int)
    {
        GZAPI_WRAPPER.getYoutubePlaylistItemsByID(id, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let uiContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = uiContext
            
            let tracks:Array<JSON> = jsonResponse["items"].arrayValue
            
            for ( var i:Int64 = 0 ; i < Int64(tracks.count) ; i++ )
            {
                let track = tracks[Int(i)]
                let id = i
                let title = track["snippet"]["title"].stringValue
                let youtubeID = track["id"].stringValue
                let sourceID = track["snippet"]["resourceId"]["videoId"].stringValue
                let imageMedium = track["snippet"]["thumbnails"]["medium"]["url"].stringValue
                guard !(imageMedium.isEmpty) else {
                    return
                }
                
                guard ( title != "Deleted video" && title != "Private video" ) else {
                    return
                }
                GZTrackFabric.createOrUpdateTrack(withID: id, imageMedium: imageMedium, mbID: "", sourceID: sourceID, title: title, youtubeID: youtubeID , andLoadInContext: privateContext)
            }
            
            try? privateContext.save()
            
            }) { () -> Void in
                
        }
    }
}

//MARK: Get youtube playlist item by lastfm artist name and track name
extension GZTracksManager
{
    class func getYTMediaItem( lastfmTrack: GZTrack )
    {
        let query:String = (lastfmTrack.artist?.name)! + " " + (lastfmTrack.title)
        GZAPI_WRAPPER.getAllYoutubeMediaByQuery(query, perPage: 1, pageNumber: 1, success: { (jsonResponse) -> Void in
            
            let uiContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = uiContext
            
            let tracks:Array<JSON> = jsonResponse["items"].arrayValue
            let track = tracks[0]
            
            let sourceID = track["id"]["videoId"].stringValue
            let title = track["snippet"]["title"].stringValue
            // check if the title of first found video on youtube really contains the name of the artist and the name of the tack
            guard ((title.lowercaseString.rangeOfString(lastfmTrack.artist!.name.lowercaseString) != nil) && (title.lowercaseString.rangeOfString(lastfmTrack.title.lowercaseString) != nil)) else {
                return
            }
            GZTrackFabric.createOrUpdateTrack(withID: lastfmTrack.id, imageMedium: lastfmTrack.imageMedium, mbID: lastfmTrack.mbID, sourceID: sourceID, title: lastfmTrack.title, youtubeID: "" , andLoadInContext: privateContext)
            
            try? privateContext.save()

            }) { () -> Void in
                
        }
    }
}