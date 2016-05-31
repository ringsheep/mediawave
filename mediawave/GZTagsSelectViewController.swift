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
    @IBOutlet weak var introLabel: UILabel!
    // MARK: save all tags and perform segue
    @IBAction func continueButton(sender: AnyObject) {
        var j = 0
        for (var i=0;i<topTags.count;i++) {
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

    let topTags = kGZConstants.topTags
    var selectedTagsArray:Array<GZLFTag> = Array<GZLFTag>()

}

//-------------------------------------------------------------
// MARK: - Navigation
extension GZTagsSelectViewController {
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
                    tracklistsController.playlists = []
                }
            }
        }
    }
}

//-------------------------------------------------------------
// MARK: - ViewController Life Cycle
extension GZTagsSelectViewController {
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
        continueButtonOutlet.setTitleColor(kGZConstants.mediawaveColor, forState: UIControlState.Normal)
        continueButtonOutlet.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Disabled)
        
        introLabel.text = kGZConstants.introLabel
        continueButtonOutlet.setTitle(kGZConstants.continueLabel, forState: UIControlState.Normal)
        
        // awake selected tags from NSUserDefaults and link them to all tags array
        selectedTagsArray = awakeSelectedTags()
        linkAlreadySelectedTags()
        continueButtonReloadState()
        
        // Register cell classes
        let nibTagCell = UINib (nibName: "GZTagCollectionViewCell", bundle: nil)
        self.collectionView!.registerNib(nibTagCell, forCellWithReuseIdentifier: "GZTagCollectionViewCell")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        print("selectedTagsArray.count \(selectedTagsArray.count)")
        // put tags in collection view
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.collectionView?.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    convenience init(horizontalAlignment: FSQCollectionViewHorizontalAlignment, verticalAlignment: FSQCollectionViewVerticalAlignment, itemSpacing: CGFloat, lineSpacing: CGFloat, insets: UIEdgeInsets) {
        self.init()
    }
}

//-------------------------------------------------------------
// MARK: - UICollectionView DataSource
extension GZTagsSelectViewController {
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
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GZTagCollectionViewCell", forIndexPath: indexPath) as! GZTagCollectionViewCell
        cell.configureSelfWithDataModel(topTags[indexPath.row])
        collectionViewHeight.constant = collectionView.contentSize.height
        return cell
    }
}

//-------------------------------------------------------------
// MARK: - UICollectionView Delegate
extension GZTagsSelectViewController {
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let selectedTagIndex = indexPath.row
        if (topTags[selectedTagIndex].selected)
        {
            topTags[selectedTagIndex].selected = false
            for (index, element) in selectedTagsArray.enumerate() {
                if element.name == topTags[selectedTagIndex].name {
                    selectedTagsArray.removeAtIndex(index)
                }
            }
        }
        else if ( selectedTagsArray.count < 5 ) {
            topTags[selectedTagIndex].selected = true
            selectedTagsArray.append(topTags[selectedTagIndex])
        }
        collectionView.reloadItemsAtIndexPaths([indexPath])
        continueButtonReloadState()
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: FSQCollectionViewAlignedLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!, remainingLineSpace: CGFloat) -> CGSize {
        if (topTags.count != 0 )
        {
            // let's check out the size of the text label inside this cell
            // we need this to make them fit to their content size in sizeForItemAtIndexPath
            let tagNSString:NSString = topTags[indexPath.row].name as NSString
            var tagSize:CGSize?
            if ( DeviceType.IS_IPHONE_6 || DeviceType.IS_IPHONE_6P ) {
                tagSize = tagNSString.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(19.0)])
                tagSize?.height = 30.0
            }
            else if (DeviceType.IS_IPHONE_4_OR_LESS) {
                tagSize = tagNSString.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(16.0)])
            }
            else {
                tagSize = tagNSString.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(18.0)])
            }
            return tagSize!
        }
        else {
            return CGSizeMake(40.0, 15.0)
        }
    }
}

//-------------------------------------------------------------
// MARK: - ContinueButton Reload State
extension GZTagsSelectViewController {
    func continueButtonReloadState() {
        if ( selectedTagsArray.count == 5 ) {
            continueButtonOutlet.enabled = true
            continueButtonOutlet.layer.borderColor = kGZConstants.mediawaveColor.CGColor
        }
        else {
            continueButtonOutlet.enabled = false
            continueButtonOutlet.layer.borderColor = UIColor.clearColor().CGColor
        }
    }
}

//-------------------------------------------------------------
// MARK: - Tags setting up
extension GZTagsSelectViewController {
    func awakeSelectedTags() -> Array<GZLFTag> {
        var awokenTagsArray:Array<GZLFTag> = Array<GZLFTag>()
        for ( var i=0 ; i < 5 ; i++ ) {
            if ( NSUserDefaults.standardUserDefaults().objectForKey("tag\(i)") != nil) {
                let awakeData = NSUserDefaults.standardUserDefaults().objectForKey("tag\(i)") as! NSString
                let selectedTag:GZLFTag = GZLFTag(nameValue: awakeData as String)
                awokenTagsArray.append(selectedTag)
                print("tag \(selectedTag.name) index tag\(i)")
            }
            else {
                // objectForKey is nil
            }
        }
        return awokenTagsArray
    }
    
    func linkAlreadySelectedTags() {
        for ( var i=0 ; i < self.topTags.count ; i++ ) {
            for ( var j=0 ; j < self.selectedTagsArray.count ; j++ ) {
                if (topTags[i].name == selectedTagsArray[j].name) {
                    topTags[i].selected = true
                }
            }
        }
    }
}