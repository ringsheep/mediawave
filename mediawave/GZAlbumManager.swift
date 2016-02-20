//
//  GZAlbumManager.swift
//  mediawave
//
//  Created by George Zinyakov on 2/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZAlbumManager {
    
}

// MARK: Search albums by query
extension GZAlbumManager {
    class func getAlbumsLF(searchQuery: String, perPage: Int, pageNumber: Int)
    {
        GZAPI_WRAPPER.getAllLastfmAlbumsByQuery(searchQuery, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let albums:Array<JSON> = jsonResponse["results"]["albummatches"]["album"].arrayValue
            
            for album:JSON in albums
            {
                let jsonItem:GZAlbum = GZAlbum()
//                jsonItem.artist = album["artist"].stringValue
                jsonItem.title = album["name"].stringValue
                jsonItem.mbID = album["mbid"].stringValue
                let jsonImages = album["image"].arrayValue
                let jsonImageMedium = jsonImages[1]["#text"].stringValue
                jsonItem.imageMedium = jsonImageMedium
                if (jsonItem.mbID != "") {
                    GZAlbumFabric.createOrUpdateAlbum(withAlbum: jsonItem)
                }
            }
            
            }) { () -> Void in
                
        }
    }
}