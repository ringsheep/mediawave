//
//  GZTrackSimpleTableViewCell.swift
//  mediawave
//
//  Created by George Zinyakov on 1/17/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZTrackSimpleTableViewCell: UITableViewCell {
    @IBOutlet weak var trackAvatar: UIImageView!
    @IBOutlet weak var trackName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // set transparent cell selection style
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.selectedBackgroundView?.backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSelfWithDataModel(track:GZTrack)
    {
        guard (track.title != "") else {
            return
        }
        trackName.text = track.title
        trackAvatar.sd_setImageWithURL(NSURL(string: track.imageMedium))
    }
    
    override func prepareForReuse() {
        trackAvatar.image = nil
        trackName.text = nil
    }

}
