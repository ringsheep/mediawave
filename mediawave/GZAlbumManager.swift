//
//  GZAlbumManager.swift
//  mediawave
//
//  Created by George Zinyakov on 2/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZAlbumManager: GZQueueManager {
    static var albumManagerQueue:OperationQueue = OperationQueue()
    
    static var downloadLastfmAlbumsByQuery:GZdownloadLastfmAlbumsByQuery?
    static var downloadLastfmAlbumsByMbID:GZdownloadLastfmAlbumsByMbID?
}

// MARK: Search albums by query
extension GZAlbumManager {
    class func getAlbumsLF(searchQuery: String, perPage: Int, pageNumber: Int, success: ( _ resultAlbums : Array<GZAlbum> ) -> Void)
    {
        print("GZdownloadLastfmAlbumsByQuery init")
        self.downloadLastfmAlbumsByQuery = GZdownloadLastfmAlbumsByQuery(withSearchQuery: searchQuery, perPage: perPage, pageNumber: pageNumber) { (resultAlbums) -> Void in
            success(resultAlbums)
        }
        super.searchQueue.maxConcurrentOperationCount = 1
        super.searchQueue.addOperation(downloadLastfmAlbumsByQuery!)
        print("GZdownloadLastfmAlbumsByQuery queued")
    }
}

// MARK: Search top albums by artist MBID
extension GZAlbumManager {
    class func getAlbumsLF(byArtistMbID mbID: String, perPage: Int, pageNumber: Int, success: @escaping ( _ resultAlbums : Array<GZAlbum>, _ totalPages: Int ) -> Void)
    {
        print("GZdownloadLastfmAlbumsByMbID init")
        self.downloadLastfmAlbumsByMbID = GZdownloadLastfmAlbumsByMbID(withMbID: mbID, perPage: perPage, pageNumber: pageNumber) { (resultAlbums, totalPages) -> Void in
            success(resultAlbums, totalPages)
        }
        super.searchQueue.maxConcurrentOperationCount = 1
        super.searchQueue.addOperation(downloadLastfmAlbumsByMbID!)
        print("GZdownloadLastfmAlbumsByMbID queued")
    }
}
