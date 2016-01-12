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
    
    func configureSelfWithDataModel(tagName: String) {
        itemTag.text = tagName
    }
    
    override func prepareForReuse() {
        itemTag.text = nil
    }
    
}
