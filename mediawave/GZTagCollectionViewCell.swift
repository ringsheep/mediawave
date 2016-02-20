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
    let mediawaveColor = UIColor(red: 255/255, green: 96/255, blue: 152/255, alpha: 1)
    
    func configureSelfWithDataModel(tag: GZLFTag) {
        itemTag.text = tag.name
        if(tag.selected){
            self.layer.cornerRadius = self.bounds.size.height/2
            self.backgroundColor = self.mediawaveColor
            self.itemTag.textColor = UIColor.whiteColor()
        }
        else {
            self.backgroundColor = UIColor.clearColor()
            self.itemTag.textColor = self.mediawaveColor
        }
    }
    
    override func prepareForReuse() {
        itemTag.text = nil
        self.backgroundColor = UIColor.clearColor()
        self.itemTag.textColor = self.mediawaveColor
    }

}
