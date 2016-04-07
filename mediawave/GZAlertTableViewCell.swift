//
//  GZAlertTableViewCell.swift
//  mediawave
//
//  Created by George Zinyakov on 3/28/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZAlertTableViewCell: GZTableViewCell {
    @IBOutlet weak var alertLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSelfWithAlert( alert: GZTableViewAlert ) {
        switch alert {
            case .NoSearchCache: alertLabel.text = kGZConstants.noSearchCache
            case .NoSearchResults: alertLabel.text = kGZConstants.noSearchResults
        }
    
    }
    
    override func prepareForReuse() {
        alertLabel.text = kGZConstants.error
    }

}

enum GZTableViewAlert {
    case NoSearchCache, NoSearchResults
}