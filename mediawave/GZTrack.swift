//
//  GZTrack.swift
//  mediawave
//
//  Created by George Zinyakov on 2/14/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZTrack : NSObject {
    var mbID : String
    var sourceID : String
    var youtubeID : String
    var title : String
    var imageMedium : String
    var artistName : String
    var playlistID : String
    var artistMbID : String
    var albumMbID : String
    
    init(
        withMbID mbID : String,
        sourceID : String,
        youtubeID : String,
        title : String,
        imageMedium : String,
        artistName : String,
        playlistID : String,
        artistMbID : String,
        albumMbID : String
        ) {
            self.mbID = mbID
            self.sourceID = sourceID
            self.youtubeID = youtubeID
            self.title = title
            self.imageMedium = imageMedium
            self.artistName = artistName
            self.playlistID = playlistID
            self.artistMbID = artistMbID
            self.albumMbID = albumMbID
    }
}

