//
//  GZdownloadLastfmAlbumsByMbID.swift
//  mediawave
//
//  Created by George Zinyakov on 3/15/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation

class GZdownloadLastfmAlbumsByMbID: Operation {

    var internetTask:URLSessionDataTask?
    var mbID:String?
    
    var perPage: Int?
    var pageNumber: Int?
    var successBlock: (_ resultAlbums : Array<GZAlbum>, _ totalPages : Int) -> Void
    
    init(
        withMbID mbID: String,
        perPage: Int,
        pageNumber: Int,
        success: @escaping (_ resultAlbums : Array<GZAlbum>, _ totalPages : Int) -> Void
        ) {
            self.mbID = mbID
            self.perPage = perPage
            self.pageNumber = pageNumber
            self.successBlock = success
            super.init()
    }
    
    override func cancel() {
        print("cancelled operation of downloading albums by mbID")
        internetTask?.cancel()
    }
    
    override func main() {
        let semaphore = DispatchSemaphore(value: 0)
        
        internetTask = GZAPI_WRAPPER.getTopLastfmAlbumsByArtist(mbID!, perPage: perPage!, pageNumber: pageNumber!, success: { (jsonResponse) -> Void in
            
            var resultAlbums:Array<GZAlbum> = Array<GZAlbum>()
            let albums:Array<JSON> = jsonResponse["topalbums"]["album"].arrayValue
            let totalPages = jsonResponse["topalbums"]["@attr"]["totalPages"].intValue
            
            for ( var i:Int64 = 0 ; i < Int64(albums.count) ; i++ )
            {
                if ( self.cancelled ) {
                    break
                }
                
                let downloadedAlbum = albums[Int(i)]
                let newArtistName = downloadedAlbum["artist"]["name"].stringValue
                let newTitle = downloadedAlbum["name"].stringValue
                let newMbID = downloadedAlbum["mbid"].stringValue
                let jsonImages = downloadedAlbum["image"].arrayValue
                let newImageMedium = jsonImages[1]["#text"].stringValue
                
                guard (newMbID != "") else {
                    continue
                }
                let newAlbum = GZAlbum(withMbID: newMbID, title: newTitle, imageMedium: newImageMedium, artistName: newArtistName)
                resultAlbums.append(newAlbum)
            }
            if ( self.cancelled ) {
                return
            }
            
            self.successBlock(resultAlbums: resultAlbums, totalPages: totalPages)
            dispatch_semaphore_signal(semaphore)
            
            }) { () -> Void in
                
            dispatch_semaphore_signal(semaphore)
            
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
}
