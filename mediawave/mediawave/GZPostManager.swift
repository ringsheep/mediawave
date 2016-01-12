//
//  GZPostManager.swift
//  mediawave
//
//  Created by George Zinyakov on 1/3/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZPostManager: NSObject {

    class func getTracksLF(searchQuery: String, perPage: Int, pageNumber: Int, success: ((tracks: Array<GZLFObject>) -> Void))
    {
        var objects:Array<GZLFObject> = Array<GZLFObject>()
        
        GZAPI_WRAPPER.getAllLastfmTracksByQuery(searchQuery, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let tracks:Array<JSON> = jsonResponse["results"]["trackmatches"]["track"].arrayValue
            
            for track:JSON in tracks
            {
                let jsonItem:GZLFObject = GZLFObject()
                jsonItem.artist = track["artist"].stringValue
                jsonItem.name = track["name"].stringValue
                jsonItem.mbid = track["mbid"].stringValue
                let jsonImages = track["image"].arrayValue
                let jsonImageMedium = jsonImages[1]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImageMedium)
                if (jsonItem.mbid != "") {
                    objects.append(jsonItem)
                }
            }
            
            success(tracks: objects)
            
            }) { () -> Void in
                
        }
    }
    
    class func getAlbumsLF(searchQuery: String, perPage: Int, pageNumber: Int, success: ((albums: Array<GZLFObject>) -> Void))
    {
        var objects:Array<GZLFObject> = Array<GZLFObject>()
        
        GZAPI_WRAPPER.getAllLastfmAlbumsByQuery(searchQuery, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let albums:Array<JSON> = jsonResponse["results"]["albummatches"]["album"].arrayValue
            
            for album:JSON in albums
            {
                let jsonItem:GZLFObject = GZLFObject()
                jsonItem.artist = album["artist"].stringValue
                jsonItem.name = album["name"].stringValue
                jsonItem.mbid = album["mbid"].stringValue
                let jsonImages = album["image"].arrayValue
                let jsonImageMedium = jsonImages[1]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImageMedium)
                if (jsonItem.mbid != "") {
                    objects.append(jsonItem)
                }
            }
            
            success(albums: objects)
            
            }) { () -> Void in
            
        }
    }
    
    class func getArtistsLF(searchQuery: String, perPage: Int, pageNumber: Int, success: ((artists: Array<GZLFObject>) -> Void))
    {
        var objects:Array<GZLFObject> = Array<GZLFObject>()
        
        GZAPI_WRAPPER.getAllLastfmArtistsByQuery(searchQuery, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let artists:Array<JSON> = jsonResponse["results"]["artistmatches"]["artist"].arrayValue
            
            for artist:JSON in artists
            {
                let jsonItem:GZLFObject = GZLFObject()
                jsonItem.name = artist["name"].stringValue
                jsonItem.mbid = artist["mbid"].stringValue
                let jsonImages = artist["image"].arrayValue
                let jsonImageMedium = jsonImages[1]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImageMedium)
                if (jsonItem.mbid != "") {
                    objects.append(jsonItem)
                }
            }
            
            success(artists: objects)
            
            }) { () -> Void in
            
        }
    }
    
    class func getArtistTopAlbumsLF(searchQuery: String, perPage: Int, pageNumber: Int, success: ((albums: Array<GZLFObject>) -> Void))
    {
        var objects:Array<GZLFObject> = Array<GZLFObject>()
        
        GZAPI_WRAPPER.getLastFmData("artist.getTopAlbums", searchKey: "mbid", searchQuery: searchQuery, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let albums:Array<JSON> = jsonResponse["topalbums"]["album"].arrayValue
            
            for album:JSON in albums
            {
                let jsonItem:GZLFObject = GZLFObject()
                jsonItem.artist = album["artist"]["name"].stringValue
                jsonItem.artistMbid = album["artist"]["mbid"].stringValue
                jsonItem.name = album["name"].stringValue
                jsonItem.mbid = album["mbid"].stringValue
                let jsonImages = album["image"].arrayValue
                let jsonImageMedium = jsonImages[1]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImageMedium)
                if (jsonItem.mbid != "") {
                    objects.append(jsonItem)
                }
            }
            
            success(albums: objects)
            
            }) { () -> Void in
                
        }
    }
    
    class func getArtistTopTracksLF(searchQuery: String, perPage: Int, pageNumber: Int, success: ((tracks: Array<GZLFObject>) -> Void))
    {
        var objects:Array<GZLFObject> = Array<GZLFObject>()
        
        GZAPI_WRAPPER.getLastFmData("artist.getTopTracks", searchKey: "mbid", searchQuery: searchQuery, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let tracks:Array<JSON> = jsonResponse["toptracks"]["track"].arrayValue
            
            for track:JSON in tracks
            {
                let jsonItem:GZLFObject = GZLFObject()
                jsonItem.artist = track["artist"]["name"].stringValue
                jsonItem.artistMbid = track["artist"]["mbid"].stringValue
                jsonItem.name = track["name"].stringValue
                jsonItem.mbid = track["mbid"].stringValue
                let jsonImages = track["image"].arrayValue
                let jsonImageMedium = jsonImages[1]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImageMedium)
                if (jsonItem.mbid != "") {
                    objects.append(jsonItem)
                }
            }
            
            success(tracks: objects)
            
            }) { () -> Void in
                
        }
    }
    
    class func getArtistTopTagsLF(searchQuery: String, perPage: Int, pageNumber: Int, success: ((tags: Array<GZLFObject>) -> Void))
    {
        var objects:Array<GZLFObject> = Array<GZLFObject>()
        
        GZAPI_WRAPPER.getLastFmData("artist.getTopTags", searchKey: "mbid", searchQuery: searchQuery, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let tags:Array<JSON> = jsonResponse["toptags"]["tag"].arrayValue
            
            for tag:JSON in tags
            {
                let jsonItem:GZLFObject = GZLFObject()
                jsonItem.name = tag["name"].stringValue
                objects.append(jsonItem)
            }
            
            success(tags: objects)
            
            }) { () -> Void in
                
        }
    }
    
    class func getArtistInfoLF(searchQuery: String, success: ((infoPack: GZLFObject) -> Void))
    {
        var object:GZLFObject = GZLFObject()
        
        GZAPI_WRAPPER.getLastFmData("artist.getInfo", searchKey: "mbid", searchQuery: searchQuery, perPage: 1, pageNumber: 1, success: { (jsonResponse) -> Void in
            
            let infoPack:JSON = jsonResponse["artist"]

                let jsonItem:GZLFObject = GZLFObject()
                jsonItem.name = infoPack["name"].stringValue
                jsonItem.mbid = infoPack["mbid"].stringValue
                jsonItem.summary = infoPack["bio"]["summary"].stringValue
                let jsonImages = infoPack["image"].arrayValue
            if (jsonImages.count != 0) {
                let jsonImageXL = jsonImages[3]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImageXL)
            }
            
            if (jsonItem.mbid != "") {
                object = jsonItem
            }
            
            success(infoPack: object)
            
            }) { () -> Void in
                
        }
    }
}
