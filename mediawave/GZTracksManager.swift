//
//  GZTracksManager.swift
//  mediawave
//
//  Created by George Zinyakov on 2/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZTracksManager: GZQueueManager {
    static var tracksManagerQueue:NSOperationQueue = NSOperationQueue()
    
    static var downloadPlaylistItemsByID:GZdownloadPlaylistItemsByID?
    static var downloadLastfmTracksByQuery:GZdownloadLastfmTracksByQuery?
    static var downloadLastfmTracksByMbID:GZdownloadLastfmTracksByMbID?
    static var downloadTracksYTMediaByQuery:GZdownloadTracksYTMediaByQuery?
    static var downloadLastfmTracksByAlbumMbID:GZdownloadLastfmTracksByAlbumMbID?
}

//MARK: Get youtube playlist items by playlist ID
extension GZTracksManager
{   
    class func getYTPlaylistItems( id: String, perPage: Int, nextPageToken: String, success: ( resultTracks : Array<GZTrack>, nextPageToken : String ) -> Void )
    {
        print("GZdownloadPlaylistItemsByID init")
        self.downloadPlaylistItemsByID = GZdownloadPlaylistItemsByID(withPlaylistID: id, perPage: perPage, nextPageToken: nextPageToken) { (resultTracks, nextPageToken) -> Void in
            success(resultTracks: resultTracks, nextPageToken: nextPageToken)
        }

        super.searchQueue.maxConcurrentOperationCount = 1
        super.searchQueue.addOperation(downloadPlaylistItemsByID!)
        print("GZdownloadPlaylistItemsByID queued")
    }
}

// MARK: Search for tracks by query
extension GZTracksManager
{
    class func getTracksLF(searchQuery: String, perPage: Int, pageNumber: Int, success: ( resultTracks : Array<GZTrack> ) -> Void)
    {
        print("GZdownloadLastfmTracksByQuery init")
        self.downloadLastfmTracksByQuery = GZdownloadLastfmTracksByQuery(withSearchQuery: searchQuery, perPage: perPage, pageNumber: pageNumber) { (resultTracks) -> Void in
            success(resultTracks: resultTracks)
        }

        super.searchQueue.maxConcurrentOperationCount = 1
        super.searchQueue.addOperation(downloadLastfmTracksByQuery!)
        print("GZdownloadLastfmTracksByQuery queued")
    }
}

// MARK: Search for top tracks by artist MBID
extension GZTracksManager {
    class func getTracksLF(byArtistMbID mbID: String, perPage: Int, pageNumber: Int, success: ( resultTracks : Array<GZTrack> ) -> Void)
    {
        print("GZdownloadLastfmTracksByMbID init")
        self.downloadLastfmTracksByMbID = GZdownloadLastfmTracksByMbID(withMbID: mbID, perPage: perPage, pageNumber: pageNumber) { (resultTracks) -> Void in
            success(resultTracks: resultTracks)
        }
        
        super.searchQueue.maxConcurrentOperationCount = 1
        super.searchQueue.addOperation(downloadLastfmTracksByMbID!)
        print("GZdownloadLastfmTracksByMbID queued")
    }
}

// MARK: Search for top tracks by album MBID
extension GZTracksManager {
    class func getTracksLF(byAlbumMbID mbID: String, success: ( resultTracks : Array<GZTrack> ) -> Void)
    {
        print("GZdownloadLastfmTracksByMbID init")
        self.downloadLastfmTracksByAlbumMbID = GZdownloadLastfmTracksByAlbumMbID(withMbID: mbID) { (resultTracks) -> Void in
            success(resultTracks: resultTracks)
        }
        
        super.searchQueue.maxConcurrentOperationCount = 1
        super.searchQueue.addOperation(downloadLastfmTracksByAlbumMbID!)
        print("GZdownloadLastfmTracksByMbID queued")
    }
}

// MARK: Search for tracks by query
extension GZTracksManager
{
    class func getTracksYTMedia(withTrack track: GZTrack, success: ( resultTrack : GZTrack ) -> Void , failure: ( sourceTrack : GZTrack ) -> Void)
    {
        print("GZdownloadTracksYTMediaByQuery init")
        self.downloadTracksYTMediaByQuery = GZdownloadTracksYTMediaByQuery(withTrack: track, success: { (resultTrack) in
            
            success(resultTrack: resultTrack)
            
            }, failure: { (resultTrack) in
                
                failure(sourceTrack: resultTrack)
        })
        
        if (self.downloadLastfmTracksByQuery != nil && self.downloadLastfmTracksByQuery?.finished == false) {
            self.downloadTracksYTMediaByQuery?.addDependency(self.downloadLastfmTracksByQuery!)
        }
        
        if (self.downloadPlaylistItemsByID != nil && self.downloadPlaylistItemsByID?.finished == false) {
            self.downloadTracksYTMediaByQuery?.addDependency(self.downloadPlaylistItemsByID!)
        }
        
        super.searchQueue.maxConcurrentOperationCount = 1
        super.searchQueue.addOperation(downloadTracksYTMediaByQuery!)
        print("GZdownloadTracksYTMediaByQuery queued")
    }
}