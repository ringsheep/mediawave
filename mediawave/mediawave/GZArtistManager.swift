//
//  GZArtistManager.swift
//  mediawave
//
//  Created by George Zinyakov on 2/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZArtistManager {
    
}

// MARK: Search artists by query
extension GZArtistManager {
    class func getArtistsLF(searchQuery: String, perPage: Int, pageNumber: Int)
    {
        
        GZAPI_WRAPPER.getAllLastfmArtistsByQuery(searchQuery, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let artists:Array<JSON> = jsonResponse["results"]["artistmatches"]["artist"].arrayValue
            
            for artist:JSON in artists
            {
                let jsonItem:GZArtist = GZArtist()
                jsonItem.name = artist["name"].stringValue
                jsonItem.mbID = artist["mbid"].stringValue
                let jsonImages = artist["image"].arrayValue
                let jsonImageMedium = jsonImages[1]["#text"].stringValue
                jsonItem.imageMedium = jsonImageMedium
                if (jsonItem.mbID != "") {
                    GZArtistFabric.createOrUpdatePlaylist(withArtist: jsonItem)
                }
            }
            
            }) { () -> Void in
                
        }
    }
}