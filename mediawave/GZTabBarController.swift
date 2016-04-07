//
//  GZTabBarController.swift
//  mediawave
//
//  Created by George Zinyakov on 2/7/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZTabBarController: UITabBarController {

    @IBOutlet weak var tabbarButton: UIButton!
    let mediawaveColor = UIColor(red: 255/255, green: 96/255, blue: 152/255, alpha: 1)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tabBar.selectedItem?.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tabBar.tintColor = mediawaveColor

        self.viewControllers![0].tabBarItem.title = kGZConstants.feedTitle
        self.viewControllers![1].tabBarItem.title = kGZConstants.searchTitle
        self.viewControllers![2].tabBarItem.title = kGZConstants.playerTitle
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
