//
//  GZDescriptionTableViewCell.swift
//  mediawave
//
//  Created by George Zinyakov on 3/25/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZDescriptionTableViewCell: GZTableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var summary: UILabel!
    
    var isConfigured:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateFonts()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSelfWithDataModel(title : String, avatar: String, description: String)
    {
//        self.translatesAutoresizingMaskIntoConstraints = false
        if ( !(title.isEmpty) ) {
            self.title.text = title
        }
        else {
            self.title.text = kGZConstants.untitled
        }
        
        if ( !(avatar.isEmpty) ) {
            self.avatar.sd_setImageWithURL(NSURL(string: avatar))
        }
        
        self.summary.text = description
        isConfigured = true
    }
    
    func updateFonts()
    {
        title.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        summary.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
    }
    
    override func prepareForReuse() {
        avatar.image = nil
        title.text = nil
        summary.text = nil
        isConfigured = false
    }

}
