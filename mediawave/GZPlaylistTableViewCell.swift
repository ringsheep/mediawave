//
//  GZPlaylistTableViewCell.swift
//  mediawave
//
//  Created by George Zinyakov on 1/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZPlaylistTableViewCell: UITableViewCell {
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var playlistBackground: UIImageView!
    
//    var gradient:CAGradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureSelfWithDataModel(playlist:GZPlaylist)
    {
        if(playlist.playlistID != ""){
            playlistName.text = playlist.title
            playlistBackground.sd_setImageWithURL(NSURL(string: playlist.imageMedium))
//            gradient.frame = self.bounds
//            gradient.colors = [UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, UIColor(red: 0, green: 0, blue: 0, alpha: 1).CGColor]
//            playlistBackground.layer.addSublayer(gradient)
        }
    }
    
    override func prepareForReuse() {
        playlistBackground.image = nil
        playlistName.text = nil
//        for gradient in playlistBackground.layer.sublayers! {
//            gradient.removeFromSuperlayer()
//        }
    }
}
