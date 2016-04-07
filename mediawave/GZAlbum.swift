//
//  GZAlbum.swift
//  mediawave
//
//  Created by George Zinyakov on 2/14/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZAlbum : NSObject {
    var mbID : String
    var title : String
    var imageMedium : String
    var artistName : String
    
    init(
        withMbID mbID : String,
        title : String,
        imageMedium : String,
        artistName : String
        ) {
            self.mbID = mbID
            self.title = title
            self.imageMedium = imageMedium
            self.artistName = artistName
    }
}