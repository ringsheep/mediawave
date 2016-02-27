//
//  GZPlaylistManager.swift
//  mediawave
//
//  Created by George Zinyakov on 2/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZPlaylistManager: NSObject {
    
}

//MARK: Search for youtube playlists by array of selected tags
extension GZPlaylistManager
{
    class func getYTPlaylists( tags: Array<GZLFTag>, perPage: Int, pageNumber: Int )
    {
        GZAPI_WRAPPER.getAllYoutubePlaylistsByQuery(tags, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let playlists:Array<JSON> = jsonResponse["items"].arrayValue
            var i:Int64 = 0
            
            for playlist:JSON in playlists
            {
                let id = i
                let title = playlist["snippet"]["title"].stringValue
                let playlistID = playlist["id"]["playlistId"].stringValue
                let summary = playlist["snippet"]["description"].stringValue
                let jsonImage = playlist["snippet"]["thumbnails"]["high"]["url"].stringValue
                guard !(jsonImage.isEmpty) else {
                    return
                }
                guard !(playlistID.isEmpty) else {
                    return
                }
                
                GZPlaylistFabric.createOrUpdatePlaylist(withid: id, playlistID: playlistID, title: title, imageMedium: jsonImage, summary: summary)
                i++
            }
            
            }) { () -> Void in
                
        }
    }
    
}