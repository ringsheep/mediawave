//
//  GZTableViewManager.swift
//  mediawave
//
//  Created by George Zinyakov on 3/28/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation

class GZTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor.clearColor()
    }
}

class GZTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // set transparent cell selection style
        prepareForReuse()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.selectedBackgroundView?.backgroundColor = UIColor.clearColor()
    }
}