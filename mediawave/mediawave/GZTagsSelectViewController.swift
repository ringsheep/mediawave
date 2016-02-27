//
//  GZTagsSelectViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/12/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class GZTagsSelectViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var continueButtonOutlet: UIButton!
    // MARK: save all tags and perform segue
    @IBAction func continueButton(sender: AnyObject) {
        var j = 0
        for (var i=0;i<topTags.count;i++) {
            // index for key (0...4)
            if (topTags[i].selected) {
                selectedTagsArray.append(topTags[i])
                NSUserDefaults.standardUserDefaults().setObject(topTags[i].name, forKey: "tag\(j)")
                print("topTags[i].name \(topTags[i].name) tag index tag\(j)")
                NSUserDefaults.standardUserDefaults().synchronize()
                j++
            }
        }
        self.performSegueWithIdentifier("toMainFromTagSelect", sender: self)
    }

    var topTags:Array<GZLFTag> = Array<GZLFTag>()
    var selectedTagsArray:Array<GZLFTag> = Array<GZLFTag>()
    var selectedTags:Int = 0
    let mediawaveColor = UIColor(red: 255/255, green: 96/255, blue: 152/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting objects states
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        continueButtonOutlet.enabled = false
        // setting graphics elements
        continueButtonOutlet.layer.cornerRadius = continueButtonOutlet.bounds.size.height/2
        continueButtonOutlet.layer.borderWidth = 1.0
        continueButtonOutlet.layer.borderColor = UIColor.clearColor().CGColor
        continueButtonOutlet.setTitleColor(self.mediawaveColor, forState: UIControlState.Normal)
        continueButtonOutlet.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Disabled)
        
        // get tags and put them in collection view
        GZLastFmSearchManager.getTopTagsLF { (tags) -> Void in
            self.topTags = tags
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView.contentSize.width = 239.0
                self.collectionView?.reloadData()
            })
        }
        // Register cell classes
        let nibTagCell = UINib (nibName: "GZTagCollectionViewCell", bundle: nil)
        self.collectionView!.registerNib(nibTagCell, forCellWithReuseIdentifier: "GZTagCollectionViewCell")
        
        for ( var i=0 ; i < 5 ; i++ ) {
            if ( NSUserDefaults.standardUserDefaults().objectForKey("tag\(i)") != nil) {
                let awakeData = NSUserDefaults.standardUserDefaults().objectForKey("tag\(i)") as! NSString
                let selectedTag:GZLFTag = GZLFTag(nameValue: awakeData as String)
                selectedTagsArray.append(selectedTag)
                selectedTags++
                print("tag \(selectedTag.name) index tag\(i)")
            }
            else {
                // objectForKey is nil
            }
        }
        // selectedTagsArray exists on memory
        if (selectedTagsArray.count != 0) {
            for ( var i=0 ; i < topTags.count ; i++ ) {
                for ( let j=0 ; i < selectedTagsArray.count ; i++ ) {
                    if (topTags[i].name == selectedTagsArray[j].name) {
                        topTags[i].selected = true
                        selectedTags += 1
                    }
                }
            }
            self.collectionView?.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        print("selectedTags \(selectedTags)")
        print("selectedTagsArray.count \(selectedTagsArray.count)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    convenience init(horizontalAlignment: FSQCollectionViewHorizontalAlignment, verticalAlignment: FSQCollectionViewVerticalAlignment, itemSpacing: CGFloat, lineSpacing: CGFloat, insets: UIEdgeInsets) {
        self.init()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return topTags.count
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: FSQCollectionViewAlignedLayout!, attributesForSectionAtIndex indexPath: NSIndexPath) -> FSQCollectionViewAlignedLayoutSectionAttributes! {
        
        return FSQCollectionViewAlignedLayoutSectionAttributes.withHorizontalAlignment(FSQCollectionViewHorizontalAlignment.Center, verticalAlignment: FSQCollectionViewVerticalAlignment.Top)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: FSQCollectionViewAlignedLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!, remainingLineSpace: CGFloat) -> CGSize {
        if (topTags.count != 0 )
        {
            // let's check out the size of the text label inside this cell
            // we need this to make them fit to their content size in sizeForItemAtIndexPath
            let tagNSString:NSString = topTags[indexPath.row].name as NSString
            let tagSize:CGSize = tagNSString.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(18.0)])
            return tagSize
        }
        else {
            return CGSizeMake(40.0, 15.0)
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GZTagCollectionViewCell", forIndexPath: indexPath) as! GZTagCollectionViewCell
        cell.configureSelfWithDataModel(topTags[indexPath.row])
        // Configure the cell
        //print("\(collectionView.contentSize.height)")
        collectionViewHeight.constant = collectionView.contentSize.height
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        //collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        // if we have not selected enough tags and click on a new one
        if ( selectedTags < 5) {
            // disable continue button
            continueButtonOutlet.enabled = false
            continueButtonOutlet.layer.borderColor = UIColor.clearColor().CGColor
            // if current tag selected, then deselect
            if (topTags[indexPath.row].selected)
            {
                topTags[indexPath.row].selected = false
                // minus one selected tag
                selectedTags -= 1
            }
            else
            {
                // if not selected, then select and increment
                topTags[indexPath.row].selected = true
                selectedTags += 1
                // if we reached the count of 5 tags, then enable the continue button
                if ( selectedTags == 5 ) {
                    continueButtonOutlet.enabled = true
                    continueButtonOutlet.layer.borderColor = self.mediawaveColor.CGColor
                }
            }
            // and reload to see the difference
            collectionView.reloadItemsAtIndexPaths([indexPath])
        }
            else {
                // if we have 5 tags already, then enable the button
                continueButtonOutlet.enabled = true
                continueButtonOutlet.layer.borderColor = self.mediawaveColor.CGColor
                if (topTags[indexPath.row].selected)
                {
                    // if the chosen tag was selected again, then disable it and minus 1
                    topTags[indexPath.row].selected = false
                    selectedTags -= 1
                    if ( selectedTags < 5 ) {
                        // then disable the button
                        continueButtonOutlet.enabled = false
                        continueButtonOutlet.layer.borderColor = UIColor.clearColor().CGColor
                    }
                }
                // and reload to see the difference
                collectionView.reloadItemsAtIndexPaths([indexPath])
            }
    }

    // MARK: UICollectionViewDelegate
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // segue to the main nav controller from tags select
        if segue.identifier == "toMainFromTagSelect" {
            // main navigation controller
            let mainNavController:UINavigationController = segue.destinationViewController as! UINavigationController
            // feed view controller
            let feedController = storyboard!.instantiateViewControllerWithIdentifier("feedController") as! GZTabBarController
            // apply feed vc to main nav controller
            mainNavController.setViewControllers([feedController], animated: true)
            // find feed vc and send data to it
            for viewController:UIViewController in feedController.viewControllers!  {
                if (viewController.restorationIdentifier == "feedNavController") {
                    let feedNavController = viewController as! UINavigationController
                    let tracklistsController = feedNavController.topViewController as! GZFeedViewController
                    tracklistsController.selectedTags = selectedTagsArray
                }
            }
        }
    }

}