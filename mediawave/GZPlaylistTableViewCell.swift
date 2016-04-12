//
//  GZPlaylistTableViewCell.swift
//  mediawave
//
//  Created by George Zinyakov on 1/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZPlaylistTableViewCell: GZTableViewCell {
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var playlistBackground: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureSelfWithDataModel(title: String, image: NSURL, playlistID : String)
    {
        dispatch_async(dispatch_get_main_queue()) {
            if (title != "") {
                self.playlistName.text = title
            }
            else {
                self.playlistName.text = kGZConstants.untitled
            }
            if (image != "") {
                self.playlistBackground.sd_setImageWithURL(image)
            }
        }
    }
    
    override func prepareForReuse() {
        playlistName.text = nil
    }
}
