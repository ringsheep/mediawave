////
////  GZYoutubeSearchManager.swift
////  mediawave
////
////  Created by George Zinyakov on 1/15/16.
////  Copyright © 2016 George Zinyakov. All rights reserved.
////
//
//import UIKit
//
//class GZYoutubeSearchManager: NSObject {
//
//}
//
////MARK: Search for youtube playlists by array of selected tags
//extension GZYoutubeSearchManager
//{
//    
//    class func getYTPlaylists( tags: Array<GZLFTag>, perPage: Int, nextPageToken: String, success: ((playlists: Array<GZLFObject>, nextPage: String) -> Void) )
//    {
//        var objects:Array<GZLFObject> = Array<GZLFObject>()
//        
//        GZAPI_WRAPPER.getAllYoutubePlaylistsByQuery(tags, perPage: perPage, nextPage: nextPageToken, success: { (jsonResponse) -> Void in
//            
//            let playlists:Array<JSON> = jsonResponse["items"].arrayValue
//            let nextPageToken = jsonResponse["nextPageToken"].stringValue
//            
//            for playlist:JSON in playlists
//            {
//                let jsonItem:GZLFObject = GZLFObject()
//                jsonItem.name = playlist["snippet"]["title"].stringValue
//                jsonItem.id = playlist["id"]["playlistId"].stringValue
//                jsonItem.summary = playlist["snippet"]["description"].stringValue
//                let jsonImages = playlist["snippet"]["thumbnails"]["high"]["url"].stringValue
//                if (jsonImages != "") {
//                    jsonItem.avatarMedium = NSURL(string: jsonImages)
//                }
//                if (jsonItem.id != "") {
//                    objects.append(jsonItem)
//                }
//
//            }
//            
//            success(playlists: objects, nextPage: nextPageToken)
//            
//            }) { () -> Void in
//            
//        }
//    }
//    
//}
//
////MARK: Get youtube playlist items by playlist ID
//extension GZYoutubeSearchManager
//{
//    
//    class func getYTPlaylistItems( id: String, perPage: Int, pageNumber: Int, success: ((tracks: Array<GZLFObject>) -> Void) )
//    {
//        var objects:Array<GZLFObject> = Array<GZLFObject>()
//        
//        GZAPI_WRAPPER.getYoutubePlaylistItemsByID(id, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
//            
//            let tracks:Array<JSON> = jsonResponse["items"].arrayValue
//            
//            for track:JSON in tracks
//            {
//                let jsonItem:GZLFObject = GZLFObject()
//                jsonItem.name = track["snippet"]["title"].stringValue
//                jsonItem.id = track["id"].stringValue
//                jsonItem.parentID = track["snippet"]["playlistId"].stringValue
//                jsonItem.sourceID = track["snippet"]["resourceId"]["videoId"].stringValue
//                jsonItem.summary = track["snippet"]["description"].stringValue
//                let jsonImages = track["snippet"]["thumbnails"]["medium"]["url"].stringValue
//                if (jsonImages != "") {
//                    jsonItem.avatarMedium = NSURL(string: jsonImages)
//                }
//                if (jsonItem.name! != "Deleted video" && jsonItem.name! != "Private video") {
//                    objects.append(jsonItem)
//                    print(jsonItem.name!)
//                }
//                
//            }
//            
//            success(tracks: objects)
//            
//            }) { () -> Void in
//                
//        }
//    }
//    
//}
//
////MARK: Get youtube playlist item by lastfm artist name and track name
//extension GZYoutubeSearchManager
//{
//    
//    class func getYTMediaItem( lastfmObjects: Array<GZLFObject>, success: ((tracks: Array<GZLFObject>) -> Void) )
//    {
//        
//        for lastfmObject:GZLFObject in lastfmObjects
//        {
//            let query:String = (lastfmObject.artist)! + " " + (lastfmObject.name)!
//            GZAPI_WRAPPER.getAllYoutubeMediaByQuery(query, perPage: 1, pageNumber: 1, success: { (jsonResponse) -> Void in
//                
//                let tracks:Array<JSON> = jsonResponse["items"].arrayValue
//                
//                for track:JSON in tracks
//                {
//                    let jsonItem:GZLFObject = GZLFObject()
//                    jsonItem.sourceID = track["id"]["videoId"].stringValue
//                    jsonItem.parentID = track["snippet"]["channelId"].stringValue
//                    jsonItem.artist = track["snippet"]["channelTitle"].stringValue
//                    jsonItem.name = track["snippet"]["title"].stringValue
//                    // check if the title of first found video on youtube really contains the name of the artist and the name of the tack
//                    if ((jsonItem.name?.lowercaseString.rangeOfString(lastfmObject.artist!.lowercaseString) != nil) && (jsonItem.name?.lowercaseString.rangeOfString(lastfmObject.name!.lowercaseString) != nil)) {
//                        lastfmObject.sourceID = jsonItem.sourceID
//                    }
//                    
//                }
//                }) { () -> Void in
//                    
//            }
//        }
//        
//        success(tracks: lastfmObjects)
//        
//    }
//    
//}