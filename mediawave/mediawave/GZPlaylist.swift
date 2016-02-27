//
//  GZPlaylist.swift
//  mediawave
//
//  Created by George Zinyakov on 2/14/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import CoreData

class GZPlaylist : NSManagedObject {
    @NSManaged var playlistID : String
    @NSManaged var id : Int64
    @NSManaged var title : String
    @NSManaged var summary : String
    @NSManaged var imageMedium : String
    
    @NSManaged var tracks : Array<GZTrack>?
}