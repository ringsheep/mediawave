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
    static var playlistManagerQueue:NSOperationQueue = NSOperationQueue()
}

//MARK: Search for youtube playlists by array of selected tags
extension GZPlaylistManager
{
    class func getYTPlaylists( tags: Array<GZLFTag>, perPage: Int, nextPageToken: String, success: ( resultPlaylists : Array<GZPlaylist>, nextPageToken : String ) -> Void  )
    {
        print("GZdownloadPlaylistItemsByID inited")
        let downloadPlaylistsBySelectedTags = GZdownloadPlaylistsBySelectedTags(tags: tags, perPage: perPage, nextPageToken: nextPageToken) { (resultPlaylists, nextPageToken) -> Void in
            success(resultPlaylists: resultPlaylists, nextPageToken: nextPageToken)
        }
        playlistManagerQueue.cancelAllOperations()
        playlistManagerQueue.maxConcurrentOperationCount = 1
        playlistManagerQueue.addOperation(downloadPlaylistsBySelectedTags)
        print("GZdownloadPlaylistItemsByID added to queue")
    }
    
}
