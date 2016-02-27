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

    func configureSelfWithDataModel(playlist:GZPlaylist)
    {
        if(playlist.playlistID != ""){
            playlistName.text = playlist.title
            playlistBackground.sd_setImageWithURL(NSURL(string: playlist.imageMedium))
        }
    }
    
    override func prepareForReuse() {
        playlistBackground.image = nil
        playlistName.text = nil
    }
}
