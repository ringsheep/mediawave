//
//  GZTrackSimpleTableViewCell.swift
//  mediawave
//
//  Created by George Zinyakov on 1/17/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZTrackSimpleTableViewCell: GZTableViewCell {
    @IBOutlet weak var trackAvatar: UIImageView!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isConfigured:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSelfWithDataModel(title: String, imageMedium: String, noMedia: Bool)
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicator.stopAnimating()
            if ( !(title.isEmpty) ) {
                self.trackName.text = title
            }
            else {
                self.trackName.text = kGZConstants.untitled
            }
            
            if ( !(imageMedium.isEmpty) ) {
                self.trackAvatar.sd_setImageWithURL(NSURL(string: imageMedium))
            }
            
            if (noMedia) {
                self.trackName.alpha = 0.3
                self.trackAvatar.alpha = 0.3
            }
            else {
                self.trackName.alpha = 1
                self.trackAvatar.alpha = 1
            }
        })
        isConfigured = true
    }
    
    override func prepareForReuse() {
        trackAvatar.image = nil
        trackName.text = nil
        activityIndicator.stopAnimating()
    }

}
