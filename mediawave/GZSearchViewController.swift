//
//  GZSearchViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/2/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit
import CoreData

class GZSearchViewController: GZTableViewController, UISearchControllerDelegate {
    @IBOutlet weak var historyButton: UIBarButtonItem!
    
    var searchResultsController: GZSearchResultsController?
    var searchController: UISearchController?
    var selectedRow:Int?
    var searchQuery:String = ""
    
    var searchRequestIsMade:Bool = false
    var searchDataIsRecieved:Bool = false
    
    @IBAction func historyButtonPressed(sender: AnyObject) {
        let actionSheet = UIActionSheet(title: kGZConstants.clearSearchDescript, delegate: self, cancelButtonTitle: kGZConstants.cancel, destructiveButtonTitle: kGZConstants.clearSearch)
        actionSheet.actionSheetStyle = .Default
        actionSheet.showInView(self.view)
    }
    
    // MARK: search cache FRC
    lazy var cacheFetchResultsController: NSFetchedResultsController =
    {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let entity = NSEntityDescription.entityForName(kGZConstants.GZSearchCache, inManagedObjectContext: managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        let request = NSFetchRequest()
        request.entity = entity
        request.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        try? controller.performFetch()
        return controller
    }()
    
}

//-------------------------------------------------------------
//MARK: - Navigation
extension GZSearchViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kGZConstants.toArtistFromSearchResults {
            let viewController:GZArtistDetails = segue.destinationViewController as! GZArtistDetails
            viewController.artist = searchResultsController?.selectedArtist
        }
        else if segue.identifier == kGZConstants.toAlbumFromSearchResults {
            let viewController:GZAlbumController = segue.destinationViewController as! GZAlbumController
            viewController.currentAlbum = searchResultsController?.selectedAlbum
        }
    }
}

//-------------------------------------------------------------
// MARK: - ViewController Life Cycle
extension GZSearchViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = kGZConstants.searchTitle
        
        self.searchResultsController = GZSearchResultsController()
        self.searchResultsController?.FeedVCDelegate = self
        // Register cell class for the identifier.
        self.tableView.registerClass(GZTableViewCell.self, forCellReuseIdentifier: kGZConstants.cellGenericId)
        
        let playlistNib = UINib(nibName: kGZConstants.GZAlertTableViewCell, bundle: nil)
        self.tableView.registerNib(playlistNib, forCellReuseIdentifier: kGZConstants.GZAlertTableViewCell)
        
        self.searchController = UISearchController(searchResultsController: self.searchResultsController!)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.delegate = self
        self.searchController?.searchBar.sizeToFit() // bar size
        self.searchController?.searchBar.delegate = self
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController?.searchBar
        self.definesPresentationContext = true
        
        updateSearchHistory()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//-------------------------------------------------------------
// MARK: - TableViewController Delegate
extension GZSearchViewController
{
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let sectionInfo = self.cacheFetchResultsController.sections
        if (sectionInfo![indexPath.section]).numberOfObjects != 0
        {
            return kGZConstants.defaultCellHeight
        }
        else {
            return kGZConstants.playlistCellHeight
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let cachedQuery = self.cacheFetchResultsController.objectAtIndexPath(indexPath) as! GZSearchCache
        self.searchQuery = cachedQuery.title
        self.searchController?.searchBar.text = self.searchQuery
        self.searchController?.active = true
        self.searchResultsController!.searchContent(withQuery: self.searchQuery)
        self.searchResultsController?.endCurrentSearch(withQuery: self.searchQuery)
    }
}

//-------------------------------------------------------------
// MARK: - TableViewController DataSource
extension GZSearchViewController
{
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.cacheFetchResultsController.sections
        if (sectionInfo![section]).numberOfObjects != 0
        {
            return (sectionInfo![section]).numberOfObjects
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = self.cacheFetchResultsController.sections
        if (sectionInfo![section]).numberOfObjects != 0
        {
            return kGZConstants.recentlySearched
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // if search is activated - see search results controller. if not activated - search cache
        let sectionInfo = self.cacheFetchResultsController.sections
        if (sectionInfo![indexPath.section]).numberOfObjects != 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(kGZConstants.cellGenericId, forIndexPath: indexPath)
            configureSearchCacheCell(tableViewCell: cell, indexPath: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(kGZConstants.GZAlertTableViewCell, forIndexPath: indexPath) as! GZAlertTableViewCell
        cell.configureSelfWithAlert(GZTableViewAlert.NoSearchCache)
        return cell
    }
    
    func configureSearchCacheCell( tableViewCell cell : UITableViewCell, indexPath : NSIndexPath ) -> Void
    {
        let cachedQuery = self.cacheFetchResultsController.objectAtIndexPath(indexPath) as! GZSearchCache
        cell.textLabel?.text = cachedQuery.title
    }
    
}

//-------------------------------------------------------------
// MARK: - UISearchBar Delegate
extension GZSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // hide keyboard
        searchBar.resignFirstResponder()
        searchResultsController?.endCurrentSearch(withQuery: searchBar.text!)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
        if (searchText == "") {
            updateSearchHistory()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        updateSearchHistory()
    }
}

//-------------------------------------------------------------
// MARK: - UIActionSheetDelegate
extension GZSearchViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            let alertController = UIAlertController(title: kGZConstants.clearSearch, message: kGZConstants.clearSearchPromt, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: kGZConstants.no, style: .Cancel) { (action) in
            }
            alertController.addAction(cancelAction)
            
            // delete search history
            let deleteAction = UIAlertAction(title: kGZConstants.yes, style: .Destructive) { (action) in
                let fetchRequest = NSFetchRequest(entityName: kGZConstants.GZSearchCache)
                // NSBatchDeleteRequest is available only since ios9
                if #available(iOS 9.0, *) {
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try? (UIApplication.sharedApplication().delegate as! AppDelegate).persistentStoreCoordinator.executeRequest(deleteRequest, withContext: self.cacheFetchResultsController.managedObjectContext)
                }
                // old way of deleting objects from managed object context
                else {
                    fetchRequest.includesPropertyValues = false
                    let searches = try? self.cacheFetchResultsController.managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
                    for search in searches! {
                        self.cacheFetchResultsController.managedObjectContext.deleteObject(search)
                    }
                }
                
                self.updateSearchHistory()
            }
            alertController.addAction(deleteAction)
            
            self.presentViewController(alertController, animated: true) {
            }
        default: break
        }
    }
}

//-------------------------------------------------------------
// MARK: - UISearchResultsUpdating Delegate
extension GZSearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // flag to control if search is made once before secondsToWait is elapced
        guard ( searchRequestIsMade == false && searchResultsController!.searchIsEnded == false && searchController.active && searchController.searchBar.text != "" ) else {
            return
        }
        if (searchResultsController!.searchNoResults) {
            searchResultsController?.clearData()
        }
        self.searchQuery = searchController.searchBar.text!
        if (self.searchController!.searchBar.isFirstResponder()) {
            searchRequestIsMade = true
            // search for content each time the search field is updated
            let secondsToWait:Double = 2
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(secondsToWait * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.searchResultsController!.searchContent(withQuery: self.searchQuery)
                self.searchRequestIsMade = false
            }
        }
        else {
            self.searchResultsController!.searchContent(withQuery: self.searchQuery)
            self.searchRequestIsMade = false
        }
        
    }
}

//-------------------------------------------------------------
// MARK: - Update search history
extension GZSearchViewController {
    func updateSearchHistory() {
        if ((self.searchResultsController) != nil) {
            self.searchResultsController?.clearData()
        }
        try? cacheFetchResultsController.performFetch()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let sectionInfo = self.cacheFetchResultsController.sections
            if (sectionInfo![0]).numberOfObjects != 0
            {
                self.navigationItem.rightBarButtonItem?.enabled = true
            }
            else {
                self.navigationItem.rightBarButtonItem?.enabled = false
            }
            self.tableView.reloadData()
        })
    }
}