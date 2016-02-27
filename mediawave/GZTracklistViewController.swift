//
//  GZTracklistViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit
import CoreData

class GZTracklistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FetchedResultsControllerHandler {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var sendedID:String?
    var selectedRow:Int?
    
    // MARK: Info Fetch Results Controller
    lazy var infoFetchResultsController : NSFetchedResultsController =
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
    
    // MARK: Info Fetch Results Controller Wrapper
    var infoFetchResultsControllerWrapper:FetchedResultsControllerDelegate?
    
//    // MARK: Tracks Fetch Results Controller
//    lazy var tracksFetchResultsController : NSFetchedResultsController =
//    {
//        // context
//        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
//        
//        // entity for request
//        let entity = NSEntityDescription.entityForName("GZTrack", inManagedObjectContext: managedObjectContext)
//        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
//        
//        // request
//        let req = NSFetchRequest()
//        req.entity = entity
//        req.sortDescriptors = [sortDescriptor]
//        
//        // controller with context and request
//        let controller = NSFetchedResultsController(fetchRequest: req, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
//        
//        // fetching
//        try? controller.performFetch()
//        return controller
//    }()
    
    // MARK: Tracks Fetch Results Controller Wrapper
//    var tracksFetchResultsControllerWrapper:FetchedResultsControllerDelegate?

    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nib for head cell
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let playlistNib = UINib(nibName: "GZPlaylistTableViewCell", bundle: nil)
        self.tableView.registerNib(playlistNib, forCellReuseIdentifier: "GZPlaylistTableViewCell")
        
        // nib for track cell
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let trackNib = UINib(nibName: "GZtrackSimpleCell", bundle: nil)
        self.tableView.registerNib(trackNib, forCellReuseIdentifier: "GZtrackSimpleCell")
        
        self.tableView.separatorColor = UIColor.clearColor()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        print("sended id is \(sendedID)")
        
    }
    
    // MARK: View Did Appear
    override func viewDidAppear(animated: Bool)
    {

        // MARK: loading current tracklist info
        GZPlaylistManager.loadYTPlaylist(sendedID!)
        
//        // MARK: getting tracklist items
//        GZTracksManager.getYTPlaylistItems(sendedID!, perPage: 10, pageNumber: 1)
        
        // intialising the info FRC wrapper
        self.infoFetchResultsControllerWrapper = FetchedResultsControllerDelegate()
        // setting it's FRC as our frc and it's handler as our controller
        self.infoFetchResultsControllerWrapper?.fetchedResultsController = self.infoFetchResultsController
        self.infoFetchResultsControllerWrapper?.handler = self
        
//        // intialising the tracks FRC wrapper
//        self.tracksFetchResultsControllerWrapper = FetchedResultsControllerDelegate()
//        // setting it's FRC as our frc and it's handler as our controller
//        self.tracksFetchResultsControllerWrapper?.fetchedResultsController = self.tracksFetchResultsController
//        self.tracksFetchResultsControllerWrapper?.handler = self
        
        try? self.infoFetchResultsController.performFetch()
//        try? self.tracksFetchResultsController.performFetch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: table view data source functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ( tableView == tableView ) {
            if let sectionInfo = self.infoFetchResultsController.sections
            {
                // playlist tracks section with list of tracks
                return (sectionInfo[section] ).numberOfObjects
            }
            else {
                return 0
            }
        }
        else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if ( indexPath.section == 0) {
            // playlist info section with banner and playlist name
            return 210.0
        }
        else {
            // playlist tracks section with list of tracks
            return 50.0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if ( indexPath.section == 0) {
            // playlist info section with banner and playlist name
            let cell = tableView.dequeueReusableCellWithIdentifier("GZPlaylistTableViewCell", forIndexPath: indexPath) as! GZPlaylistTableViewCell
            configureInfoCell(tableViewCell: cell, indexPath: indexPath)
            return cell
        }
        else {
            // playlist tracks section with list of tracks
            let cell = tableView.dequeueReusableCellWithIdentifier("GZtrackSimpleCell", forIndexPath: indexPath) as! GZTrackSimpleTableViewCell
//            configureTrackCell(tableViewCell: cell, indexPath: indexPath)
            // refresh dynamically calculated table view height
            self.tableViewHeight.constant = self.tableView.contentSize.height
            return cell
        }
    }
    
    // MARK: configure a playlist info cell
    func configureInfoCell( tableViewCell cell : GZPlaylistTableViewCell, indexPath : NSIndexPath ) -> Void
    {
        let model = self.infoFetchResultsController.objectAtIndexPath(indexPath) as! GZPlaylist
        print(model.title)
        cell.configureSelfWithDataModel(model)
    }
    
//    // MARK: configure a track cell
//    func configureTrackCell( tableViewCell cell : GZTrackSimpleTableViewCell, indexPath : NSIndexPath ) -> Void
//    {
//        let model = self.tracksFetchResultsController.objectAtIndexPath(indexPath) as! GZTrack
////        model.playlist = GZPlaylistFabric.loadExistingPlaylist(withPlaylistID: sendedID!)
//        print(model.title)
//        cell.configureSelfWithDataModel(model)
//    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if ( indexPath.section == 0) {
//            // playlist info section with banner and playlist name
//        }
//        else {
//            // playlist tracks section with list of tracks
//            selectedRow = indexPath.row
//            for viewController:UIViewController in self.tabBarController!.viewControllers! {
//                if (viewController.isKindOfClass(GZTrackViewController)) {
//                    let trackController = viewController as! GZTrackViewController
//                    self.tabBarController?.selectedViewController = trackController
//                    let track = self.tracksFetchResultsController.objectAtIndexPath(indexPath) as! GZTrack
//                    let sourceID = track.sourceID
//                    trackController.loadTrack(sourceID, indexPath: indexPath, tracksCount: self.tableView.numberOfRowsInSection(1) )
//                }
//            }
//        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

}

// MARK: FRC events and control
extension GZTracklistViewController
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
