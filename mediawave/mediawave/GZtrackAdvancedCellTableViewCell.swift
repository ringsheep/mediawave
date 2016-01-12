//
//  GZtrackAdvancedCellTableViewCell.swift
//  mediawave
//
//  Created by George Zinyakov on 1/7/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZtrackAdvancedCellTableViewCell: UITableViewCell {
    @IBOutlet weak var trackAvatar: UIImageView!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var trackArtist: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSelfWithDataModel(LFObject:GZLFObject)
    {
        if(LFObject.mbid != nil){
            trackName.text = LFObject.name
            if ( LFObject.artist != nil ) {
                trackArtist.text = "by " + LFObject.artist!
            }
            else {
                trackArtist.text = ""
            }
            trackAvatar.sd_setImageWithURL(LFObject.avatarMedium)
        }
    }
    
    override func prepareForReuse() {
        trackAvatar.image = nil
        trackArtist.text = nil
        trackName.text = nil
    }

}
