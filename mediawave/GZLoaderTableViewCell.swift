//
//  GZLoaderTableViewCell.swift
//  mediawave
//
//  Created by George Zinyakov on 3/28/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZLoaderTableViewCell: GZTableViewCell {
    @IBOutlet weak var loadMoreLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.loadMoreLabel.text = kGZConstants.loadMore
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        
    }

}
