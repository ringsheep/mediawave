//
//  GZArtist.swift
//  mediawave
//
//  Created by George Zinyakov on 2/14/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import CoreData

class GZArtist : NSManagedObject {
    @NSManaged var mbID : String
    @NSManaged var name : String
    @NSManaged var summary : String
    @NSManaged var imageMedium : String
    
    @NSManaged var topTracks : Array<GZTrack>?
    @NSManaged var topAlbums : Array<GZAlbum>?
}
