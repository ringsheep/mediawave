//
//  GZtrackAdvancedCellTableViewCell.swift
//  mediawave
//
//  Created by George Zinyakov on 1/7/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZtrackAdvancedCellTableViewCell: GZTableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSelfWithDataModel( avatar: String, title: String, artist: String, noMedia : Bool )
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
            if ( !(title.isEmpty) ) {
                self.title.text = title
            }
            else {
                self.title.text = kGZConstants.untitled
            }
            
            if ( !(artist.isEmpty) ) {
                self.artist.text = "by " + artist
            }
            else {
                self.artist.text = ""
            }
            
            if ( !(avatar.isEmpty) ) {
                self.avatar.sd_setImageWithURL(NSURL(string: avatar))
            }
            
            if (noMedia) {
                self.title.alpha = 0.3
                self.artist.alpha = 0.3
                self.avatar.alpha = 0.3
            }
            else {
                self.title.alpha = 1
                self.artist.alpha = 1
                self.avatar.alpha = 1
            }
        }
    }
    
    override func prepareForReuse() {
        avatar.image = nil
        artist.text = nil
        title.text = nil
        activityIndicator.stopAnimating()
    }

}
