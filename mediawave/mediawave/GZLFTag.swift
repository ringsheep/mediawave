//
//  GZLFTag.swift
//  mediawave
//
//  Created by George Zinyakov on 1/15/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZLFTag: NSObject, NSCoding {
    var name:String
    var selected:Bool = false
    
    let tagKey = "selectedTag"
    
    init( nameValue: String)
    {
        name = nameValue
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: tagKey)
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(tagKey) as! String
    }
}
