//
//  GZLastFmSearchManager.swift
//  mediawave
//
//  Created by George Zinyakov on 1/3/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZLastFmSearchManager: NSObject {
}

// MARK: Search tracks by query
extension GZLastFmSearchManager {
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
                jsonItem.id = track["mbid"].stringValue
                let jsonImages = track["image"].arrayValue
                let jsonImageMedium = jsonImages[1]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImageMedium)
                if (jsonItem.id != "") {
                    objects.append(jsonItem)
                }
            }
            
            success(tracks: objects)
            
            }) { () -> Void in
                
        }
    }
}

// MARK: Search albums by query
extension GZLastFmSearchManager {
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
                jsonItem.id = album["mbid"].stringValue
                let jsonImages = album["image"].arrayValue
                let jsonImageMedium = jsonImages[1]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImageMedium)
                if (jsonItem.id != "") {
                    objects.append(jsonItem)
                }
            }
            
            success(albums: objects)
            
            }) { () -> Void in
                
        }
    }
}

// MARK: Search artists by query
extension GZLastFmSearchManager {
    class func getArtistsLF(searchQuery: String, perPage: Int, pageNumber: Int, success: ((artists: Array<GZLFObject>) -> Void))
    {
        var objects:Array<GZLFObject> = Array<GZLFObject>()
        
        GZAPI_WRAPPER.getAllLastfmArtistsByQuery(searchQuery, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let artists:Array<JSON> = jsonResponse["results"]["artistmatches"]["artist"].arrayValue
            
            for artist:JSON in artists
            {
                let jsonItem:GZLFObject = GZLFObject()
                jsonItem.name = artist["name"].stringValue
                jsonItem.id = artist["mbid"].stringValue
                let jsonImages = artist["image"].arrayValue
                let jsonImageMedium = jsonImages[1]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImageMedium)
                if (jsonItem.id != "") {
                    objects.append(jsonItem)
                }
            }
            
            success(artists: objects)
            
            }) { () -> Void in
                
        }
    }
}

// MARK: Search top albums by artist MBID
extension GZLastFmSearchManager {
    class func getArtistTopAlbumsLF(parentID: String, perPage: Int, pageNumber: Int, success: ((albums: Array<GZLFObject>) -> Void))
    {
        var objects:Array<GZLFObject> = Array<GZLFObject>()
        
        GZAPI_WRAPPER.getTopLastfmAlbumsByArtist(parentID, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let albums:Array<JSON> = jsonResponse["topalbums"]["album"].arrayValue
            
            for album:JSON in albums
            {
                let jsonItem:GZLFObject = GZLFObject()
                jsonItem.artist = album["artist"]["name"].stringValue
                jsonItem.parentID = album["artist"]["mbid"].stringValue
                jsonItem.name = album["name"].stringValue
                jsonItem.id = album["mbid"].stringValue
                let jsonImages = album["image"].arrayValue
                let jsonImageMedium = jsonImages[1]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImageMedium)
                if (jsonItem.id != "") {
                    objects.append(jsonItem)
                }
            }
            
            success(albums: objects)
            
            }) { () -> Void in
                
        }
    }
}

// MARK: Search for top tracks by artist MBID
extension GZLastFmSearchManager {
    class func getArtistTopTracksLF(parentID: String, perPage: Int, pageNumber: Int, success: ((tracks: Array<GZLFObject>) -> Void))
    {
        var objects:Array<GZLFObject> = Array<GZLFObject>()
        
        GZAPI_WRAPPER.getTopLastfmTracksByArtist(parentID, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let tracks:Array<JSON> = jsonResponse["toptracks"]["track"].arrayValue
            
            for track:JSON in tracks
            {
                let jsonItem:GZLFObject = GZLFObject()
                jsonItem.artist = track["artist"]["name"].stringValue
                jsonItem.parentID = track["artist"]["mbid"].stringValue
                jsonItem.name = track["name"].stringValue
                jsonItem.id = track["mbid"].stringValue
                let jsonImages = track["image"].arrayValue
                let jsonImageMedium = jsonImages[1]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImageMedium)
                if (jsonItem.id != "") {
                    objects.append(jsonItem)
                }
            }
            
            success(tracks: objects)
            
            }) { () -> Void in
                
        }
    }
}

// MARK: Search for top tags by artist MBID
extension GZLastFmSearchManager {
    class func getArtistTopTagsLF(parentID: String, perPage: Int, pageNumber: Int, success: ((tags: Array<GZLFTag>) -> Void))
    {
        var objects:Array<GZLFTag> = Array<GZLFTag>()
        
        GZAPI_WRAPPER.getTopLastfmTagsByArtist(parentID, perPage: perPage, pageNumber: pageNumber, success: { (jsonResponse) -> Void in
            
            let tags:Array<JSON> = jsonResponse["toptags"]["tag"].arrayValue
            
            for tag:JSON in tags
            {
                let jsonItem:GZLFTag = GZLFTag(nameValue: tag["name"].stringValue)
                objects.append(jsonItem)
            }
            
            success(tags: objects)
            
            }) { () -> Void in
                
        }
    }
}

// MARK: Search for artist info by artist MBID
extension GZLastFmSearchManager {
    class func getArtistInfoLF(parentID: String, success: ((infoPack: GZLFObject) -> Void))
    {
        var object:GZLFObject = GZLFObject()
        
        GZAPI_WRAPPER.getLastfmInfoByArtist(parentID, perPage: 1, pageNumber: 1, success: { (jsonResponse) -> Void in
            
            let infoPack:JSON = jsonResponse["artist"]
            
            let jsonItem:GZLFObject = GZLFObject()
            jsonItem.name = infoPack["name"].stringValue
            jsonItem.id = infoPack["mbid"].stringValue
            jsonItem.summary = infoPack["bio"]["summary"].stringValue
            let jsonImages = infoPack["image"].arrayValue
            if (jsonImages.count != 0) {
                let jsonImageXL = jsonImages[3]["#text"].stringValue
                jsonItem.avatarMedium = NSURL(string: jsonImageXL)
            }
            
            if (jsonItem.id != "") {
                object = jsonItem
            }
            
            success(infoPack: object)
            
            }) { () -> Void in
                
        }
    }
}

// MARK: Get top tags of Last.fm chart
extension GZLastFmSearchManager {
    class func getTopTagsLF(success: ((tags: Array<GZLFTag>) -> Void))
    {
        var objects:Array<GZLFTag> = Array<GZLFTag>()
        
        GZAPI_WRAPPER.getLastfmTopTags({ (jsonResponse) -> Void in
            
            let tags:Array<JSON> = jsonResponse["tags"]["tag"].arrayValue
            
            for tag:JSON in tags
            {
                let jsonItem:GZLFTag = GZLFTag(nameValue: tag["name"].stringValue)
                objects.append(jsonItem)
            }
            
            success(tags: objects)
            
            }) { () -> Void in
                
        }
    }
}

// MARK: Get album tracks and tags from Last.fm
extension GZLastFmSearchManager {
    class func getAlbumTracksLF(parentID: String, success: ((tracks: Array<GZLFObject>) -> Void))
    {
        var objects:Array<GZLFObject> = Array<GZLFObject>()
        
        GZAPI_WRAPPER.getLastfmTracksByAlbum(parentID, success: { (jsonResponse) -> Void in
            
            let tracks:Array<JSON> = jsonResponse["album"]["tracks"]["track"].arrayValue
            
            for track:JSON in tracks
            {
                let jsonItem:GZLFObject = GZLFObject()
                jsonItem.name = track["name"].stringValue
                jsonItem.artist = track["artist"]["name"].stringValue
                jsonItem.parentID = track["artist"]["mbid"].stringValue
                jsonItem.id = track["mbid"].stringValue
                if (jsonItem.name != "") {
                    objects.append(jsonItem)
                }
            }
            
            success(tracks: objects)
            
            }) { () -> Void in
                
        }
    }
}

// MARK: Get album tags from Last.fm
extension GZLastFmSearchManager {
    class func getAlbumTagsLF(parentID: String, success: ((tags: Array<GZLFTag>) -> Void))
    {
        var tagObjects:Array<GZLFTag> = Array<GZLFTag>()
        
        GZAPI_WRAPPER.getLastfmTracksByAlbum(parentID, success: { (jsonResponse) -> Void in
            
            let tags:Array<JSON> = jsonResponse["album"]["tags"]["tag"].arrayValue
            
            for tag:JSON in tags
            {
                let jsonItem:GZLFTag = GZLFTag(nameValue: tag["name"].stringValue)
                if (jsonItem.name != "") {
                    tagObjects.append(jsonItem)
                }
            }
            
            success(tags: tagObjects)
            
            }) { () -> Void in
                
        }
    }
}