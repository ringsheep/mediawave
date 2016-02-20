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
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSelfWithDataModel(LFObject:GZLFObject)
    {
        if(LFObject.id != nil){
            trackName.text = LFObject.name
            trackAvatar.sd_setImageWithURL(LFObject.avatarMedium)
        }
    }
    
    override func prepareForReuse() {
        trackAvatar.image = nil
        trackName.text = nil
    }

}
