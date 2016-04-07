//
//  GZdownloadLastfmArtistsInfoByMbID.swift
//  mediawave
//
//  Created by George Zinyakov on 3/18/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation

class GZdownloadLastfmArtistsInfoByMbID: NSOperation {
    
    var internetTask:NSURLSessionDataTask?
    var artist: GZArtist?
    var successBlock: (resultArtist : GZArtist) -> Void
    
    init( withArtist artist: GZArtist, success: (resultArtist : GZArtist) -> Void ) {
        self.artist = artist
        self.successBlock = success
        super.init()
    }
    
    override func cancel() {
        print("cancelled operation of downloading artists info")
        internetTask?.cancel()
    }
    
    override func main() {
        let semaphore = dispatch_semaphore_create(0)
        print("GZdownloadLastfmArtistsInfoByMbID launched")
        internetTask = GZAPI_WRAPPER.getLastfmInfoByArtist(artist!.mbID, perPage: 1, pageNumber: 1, success: { (jsonResponse) -> Void in
            
            let infoPack:JSON = jsonResponse["artist"]
            let summary = infoPack["bio"]["summary"].stringValue
            self.artist?.summary = summary
            
            if ( self.cancelled ) {
                return
            }
            print("GZdownloadLastfmArtistsInfoByMbID finished")
            self.successBlock(resultArtist: self.artist!)
            dispatch_semaphore_signal(semaphore)
            
            }) { () -> Void in
                
            dispatch_semaphore_signal(semaphore)
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }

}
