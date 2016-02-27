//
//  GZTracksManager.swift
//  mediawave
//
//  Created by George Zinyakov on 2/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZTracksManager {
    
}

//MARK: Get youtube playlist items by playlist ID
extension GZTracksManager
{   
    class func getYTPlaylistItems( id: String, perPage: Int, pageNumber: Int)
    {
        GZAPI_WRAPPER.getYoutubePlaylistItemsByID(id, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let tracks:Array<JSON> = jsonResponse["items"].arrayValue
            
            for track:JSON in tracks
            {
                let jsonItem:GZTrack = GZTrack()
                jsonItem.title = track["snippet"]["title"].stringValue
                jsonItem.youtubeID = track["id"].stringValue
//                jsonItem.parentID = track["snippet"]["playlistId"].stringValue
                jsonItem.sourceID = track["snippet"]["resourceId"]["videoId"].stringValue
                let jsonImage = track["snippet"]["thumbnails"]["medium"]["url"].stringValue
                if (jsonImage != "") {
                    jsonItem.imageMedium = jsonImage
                }
                if (jsonItem.title != "Deleted video" && jsonItem.title != "Private video") {
                    GZTrackFabric.createOrUpdateTrack(withTrack: jsonItem)
                }
                
            }
            
            }) { () -> Void in
                
        }
    }
}

//MARK: Get youtube playlist item by lastfm artist name and track name
extension GZYoutubeSearchManager
{
    
    class func getYTMediaItem( lastfmTrack: GZTrack )
    {
        let query:String = (lastfmTrack.artist?.name)! + " " + (lastfmTrack.title)
        GZAPI_WRAPPER.getAllYoutubeMediaByQuery(query, perPage: 1, pageNumber: 1, success: { (jsonResponse) -> Void in
            
            let tracks:Array<JSON> = jsonResponse["items"].arrayValue
            
            for track:JSON in tracks
            {
                let jsonItem:GZTrack = GZTrack()
                jsonItem.sourceID = track["id"]["videoId"].stringValue
//                jsonItem.parentID = track["snippet"]["channelId"].stringValue
//                jsonItem.artist = track["snippet"]["channelTitle"].stringValue
                jsonItem.title = track["snippet"]["title"].stringValue
                // check if the title of first found video on youtube really contains the name of the artist and the name of the tack
                if ((jsonItem.title.lowercaseString.rangeOfString(lastfmTrack.artist!.name.lowercaseString) != nil) && (jsonItem.title.lowercaseString.rangeOfString(lastfmTrack.title.lowercaseString) != nil)) {
                    lastfmTrack.sourceID = jsonItem.sourceID
                }
                GZTrackFabric.createOrUpdateTrack(withTrack: jsonItem)
            }
            }) { () -> Void in
                
        }
    }
    
}