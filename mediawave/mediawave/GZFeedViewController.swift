//
//  GZFeedViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 2/5/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit
import CoreData

class GZFeedViewController: UITableViewController, FetchedResultsControllerHandler {
    
    var playlistsArray:Array<GZPlaylist> = Array<GZPlaylist>()
    var selectedTags:Array<GZLFTag> = Array<GZLFTag>()
    var selectedPath:NSIndexPath?
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        let viewController = appDelegate.window!.rootViewController
        if (viewController!.isKindOfClass(GZTagsSelectViewController)) {
            // check if root vc is tag select - then we pop the stack of nav controller
//            self.navigationController?.popToViewController(viewController, animated: true)
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            })
        }
        else {
            // otherwise, we just add tag select to the stack
            self.performSegueWithIdentifier("toTagsFromFeed", sender: self)
        }
    }
    
    // MARK: Fetch Results Controller
    lazy var fetchResultsController : NSFetchedResultsController =
    {
        // context
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        // entity for request
        let entity = NSEntityDescription.entityForName("GZPlaylist", inManagedObjectContext: managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        
        // request
        let req = NSFetchRequest()
        req.entity = entity
        req.sortDescriptors = [sortDescriptor]
        
        // controller with context and request
        let controller = NSFetchedResultsController(fetchRequest: req, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // fetching
        try? controller.performFetch()
        return controller
    }()
    
    // MARK: Fetch Results Controller Wrapper
    var fetchResultsControllerWrapper:FetchedResultsControllerDelegate?

    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playlistNib = UINib(nibName: "GZPlaylistTableViewCell", bundle: nil)
        self.tableView.registerNib(playlistNib, forCellReuseIdentifier: "GZPlaylistTableViewCell")
        self.tableView.separatorColor = UIColor.clearColor()

    }
    
    // MARK: View Did Appear
    override func viewDidAppear(animated: Bool) {
        // if we have some selected tags, we perform a request for playlists
        if (selectedTags.count != 0) {
            GZPlaylistManager.getYTPlaylists(selectedTags, perPage: 9, pageNumber: 0)
            try? self.fetchResultsController.performFetch()
            
            // intialising the FRC wrapper
            fetchResultsControllerWrapper = FetchedResultsControllerDelegate()
            // setting it's FRC as our frc and it's handler as our controller
            fetchResultsControllerWrapper?.fetchedResultsController = fetchResultsController
            fetchResultsControllerWrapper?.handler = self
            
            // save
            let uiContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            try? uiContext.save()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchResultsController.sections
        {
            return (sectionInfo[section] ).numberOfObjects
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 210.0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GZPlaylistTableViewCell", forIndexPath: indexPath) as! GZPlaylistTableViewCell
        configure(tableViewCell: cell, indexPath: indexPath)
        
        // set transparent cell selection style
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.selectedBackgroundView?.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    // MARK: configure a singe cell
    func configure( tableViewCell cell : GZPlaylistTableViewCell, indexPath : NSIndexPath ) -> Void
    {
        let model = self.fetchResultsController.objectAtIndexPath(indexPath) as! GZPlaylist
        print(model.title)
        cell.configureSelfWithDataModel(model)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedPath = indexPath
        self.performSegueWithIdentifier("toPlaylistFromFeed", sender: self)
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toPlaylistFromFeed") {
            let viewController:GZTracklistViewController = segue.destinationViewController as! GZTracklistViewController
            let sendedModel = self.fetchResultsController.objectAtIndexPath(selectedPath!) as! GZPlaylist
            let sendedID = sendedModel.id
            print("\(sendedID)")
            viewController.sendedID = sendedID
        }
        else if ( segue.identifier == "toTagsFromFeed" ) {
            let viewController:UINavigationController = segue.destinationViewController as! UINavigationController
            let tagsController = viewController.topViewController as! GZTagsSelectViewController
            tagsController.selectedTagsArray = Array<GZLFTag>()
        }
    }

}

//MARK: reload table view of self
extension GZFeedViewController
{
    func reloadTableViewAsync()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
}

// MARK: FRC events and control
extension GZFeedViewController
{
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if ( type == .Insert) {
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
        if ( type == .Update ) {
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
        if ( type == .Move ) {
            if let newIndexPath = newIndexPath {
                if let indexPath = indexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
                }
            }
        }
        if ( type == .Delete ) {
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // this two functions are empty just because they are not optional
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String?) -> String? {
        return nil
    }
}