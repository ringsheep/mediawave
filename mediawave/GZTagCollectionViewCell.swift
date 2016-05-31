//
//  GZTagCollectionViewCell.swift
//  mediawave
//
//  Created by George Zinyakov on 1/10/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZTagCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var itemTag: UILabel!
    var cellSelected:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }
    
    func configureSelfWithDataModel(tag: GZLFTag) {
        itemTag.text = tag.name
        if(tag.selected){
            enable()
        }
        else {
            disable()
        }
    }
    
    func enable() {
        self.layer.cornerRadius = self.bounds.size.height/2
        self.backgroundColor = kGZConstants.mediawaveColor
        self.itemTag.textColor = UIColor.whiteColor()
    }
    
    func disable() {
        self.backgroundColor = UIColor.clearColor()
        self.itemTag.textColor = kGZConstants.mediawaveColor
    }
    
    override func prepareForReuse() {
        itemTag.text = nil
        if (DeviceType.IS_IPHONE_6 || DeviceType.IS_IPHONE_6P) {
            itemTag.font = itemTag.font.fontWithSize(15.0)
        }
        else if (DeviceType.IS_IPHONE_4_OR_LESS) {
            itemTag.font = itemTag.font.fontWithSize(12.0)
        }
        else {
            itemTag.font = itemTag.font.fontWithSize(14.0)
        }
        self.backgroundColor = UIColor.clearColor()
        self.itemTag.textColor = kGZConstants.mediawaveColor
    }

}
