//
//  GZArtist.swift
//  mediawave
//
//  Created by George Zinyakov on 2/14/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZArtist : NSObject {
    var mbID : String
    var name : String
    var summary : String
    var imageMedium : String
    
    init(
        withMbID mbID : String,
        name : String,
        summary : String,
        imageMedium : String
        ) {
            self.mbID = mbID
            self.name = name
            self.summary = summary
            self.imageMedium = imageMedium
    }
}
