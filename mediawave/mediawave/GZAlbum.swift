//
//  GZAlbum.swift
//  mediawave
//
//  Created by George Zinyakov on 2/14/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import CoreData

class GZAlbum : NSManagedObject {
    @NSManaged var mbID : String
    @NSManaged var title : String
    @NSManaged var imageMedium : String
    
    @NSManaged var tracks : Array<GZTrack>?
    @NSManaged var artist : GZArtist?
}
