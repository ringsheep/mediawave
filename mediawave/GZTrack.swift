//
//  GZTrack.swift
//  mediawave
//
//  Created by George Zinyakov on 2/14/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import CoreData

class GZTrack : NSManagedObject {
    @NSManaged var id : Int64
    @NSManaged var mbID : String
    @NSManaged var sourceID : String
    @NSManaged var youtubeID : String
    @NSManaged var title : String
    @NSManaged var imageMedium : String
    
    @NSManaged var playlist : GZPlaylist?
    @NSManaged var artist : GZArtist?
    @NSManaged var album : GZAlbum?
}
