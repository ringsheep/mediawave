//
//  GZdownloadPlaylistsBySelectedTags.swift
//  mediawave
//
//  Created by George Zinyakov on 3/8/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation

class GZdownloadPlaylistsBySelectedTags: NSOperation {
    
    var internetTask:NSURLSessionDataTask?
    var tags: Array<GZLFTag>?
    
    var perPage: Int?
    var nextPageToken: String?
    var successBlock: (resultPlaylists : Array<GZPlaylist>, nextPageToken : String) -> Void
    
    init( tags: Array<GZLFTag>, perPage: Int, nextPageToken: String, success: (resultPlaylists : Array<GZPlaylist>, nextPageToken : String) -> Void ) {
        self.tags = tags
        self.perPage = perPage
        self.nextPageToken = nextPageToken
        self.successBlock = success
        super.init()
    }
    
    override func cancel() {
        print("cancelled operation of downloading playlists by selected tags")
        internetTask?.cancel()
    }
    
    override func main() {
        let semaphore = dispatch_semaphore_create(0)
        
        internetTask = GZAPI_WRAPPER.getAllYoutubePlaylistsByQuery(tags!, perPage: perPage!, nextPage:
            nextPageToken!, success: { (jsonResponse) -> Void in
            
            var resultPlaylists:Array<GZPlaylist> = Array<GZPlaylist>()
            let downloadedPlaylists:Array<JSON> = jsonResponse["items"].arrayValue
            let nextPageToken = jsonResponse["nextPageToken"].stringValue
            
            for ( var i:Int64 = 0 ; i < Int64(downloadedPlaylists.count) ; i++ )
            {
                if ( self.cancelled ) {
                    break
                }
                let downloadedPlaylist = downloadedPlaylists[Int(i)]
                let newTitle = downloadedPlaylist["snippet"]["title"].stringValue
                let newSummary = downloadedPlaylist["snippet"]["description"].stringValue
                let newImage = downloadedPlaylist["snippet"]["thumbnails"]["high"]["url"].stringValue
                guard !(newImage.isEmpty) else {
                    break
                }
                let newPlaylistID = downloadedPlaylist["id"]["playlistId"].stringValue
                guard !(newPlaylistID.isEmpty) else {
                    break
                }
                
                // add to results array
                let newPlaylist = GZPlaylist(withPlaylistID: newPlaylistID, title: newTitle, summary: newSummary, imageMedium: newImage)
                resultPlaylists.append(newPlaylist)
            }
            
            if ( self.cancelled ) {
               return
            }
            
            self.successBlock(resultPlaylists: resultPlaylists, nextPageToken: nextPageToken)
            dispatch_semaphore_signal(semaphore)
            
            }) { () -> Void in
                
            dispatch_semaphore_signal(semaphore)
                
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }

}