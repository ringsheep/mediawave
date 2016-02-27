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
//    let subviewArray:NSArray = NSBundle.mainBundle().loadNibNamed("GZTabBarPlayer", owner: self, options: nil)
//    let tabBarPlayer:UIView = subviewArray[0]
//    let tabBarPlayer:UIView = GZTabBarPlayer()
    var tabBarPlayer : GZTabBarPlayer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tabBar.selectedItem?.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tabBar.tintColor = mediawaveColor
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
//        self.tabBarPlayer = NSBundle.mainBundle().loadNibNamed("GZTabBarPlayer", owner: self, options: nil)[0] as? GZTabBarPlayer
//        
//        self.tabBarPlayer?.frame = CGRectMake(0.0, -70.0, self.tabBar.frame.width  , 70.0)
//        if (self.tabBarPlayer != nil) {
//            self.tabBar.addSubview(self.tabBarPlayer!)
//            print(self.tabBarPlayer)
//        }
        
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
