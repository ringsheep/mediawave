//
//  GZPostManager.swift
//  mediawave
//
//  Created by George Zinyakov on 1/3/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZPostManager: NSObject {

    class func getTracksLF(searchQuery: String, perPage: Int, pageNumber: Int, success: ((tracks: Array<GZTrack>) -> Void))
    {
        var objects:Array<GZTrack> = Array<GZTrack>()
        
        GZAPI_WRAPPER.getAllLastfmTracksByQuery(searchQuery, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let tracks:Array<JSON> = jsonResponse["results"]["trackmatches"]["track"].arrayValue
            
            for track:JSON in tracks
            {
                let jsonItem:GZTrack = GZTrack()
                jsonItem.artist = track["artist"].stringValue
                jsonItem.name = track["name"].stringValue
                jsonItem.mbid = track["mbid"].stringValue
                let jsonImage = track["image"]["1"]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImage)
                objects.append(jsonItem)
            }
            
            success(tracks: objects)
            
            }) { () -> Void in
                
        }
    }
}
