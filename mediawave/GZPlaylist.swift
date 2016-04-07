//
//  GZPlaylist.swift
//  mediawave
//
//  Created by George Zinyakov on 2/14/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZPlaylist : NSObject {
    var playlistID : String
    var title : String
    var summary : String
    var imageMedium : String
    
    init(
        withPlaylistID playlistID : String,
        title : String,
        summary : String,
        imageMedium : String
        ) {
            self.playlistID = playlistID
            self.title = title
            self.summary = summary
            self.imageMedium = imageMedium
    }
}