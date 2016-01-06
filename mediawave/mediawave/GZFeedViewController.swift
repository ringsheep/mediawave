//
//  GZFeedViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/2/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZFeedViewController: UITableViewController, UISearchControllerDelegate {
    
    var searchResultsController: GZSearchResultsController?
    var searchController: UISearchController?
    var tracksArray:Array<GZTrack> = Array<GZTrack>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchResultsController = GZSearchResultsController()
        // Register cell class for the identifier.
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        
        self.searchController = UISearchController(searchResultsController: self.searchResultsController!)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.delegate = self
        self.searchController?.searchBar.sizeToFit() // bar size
        self.searchController?.searchBar.delegate = self
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController?.searchBar
        
        self.definesPresentationContext = true
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController!.active && searchController!.searchBar.text != ""
        {
        return tracksArray.count
        }
        else
        {
        return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if searchController!.active && searchController!.searchBar.text != "" {
            let track:GZTrack = tracksArray[indexPath.row]
            cell.textLabel?.text = track.name
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchContentForQuery( query: String )
    {
        GZPostManager.getTracksLF(query, perPage: 3, pageNumber: 1) { (tracks) -> Void in
            self.searchResultsController?.tracksArray = tracks
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.searchResultsController?.tableView.reloadData()
            })
        }
    }

}

extension GZFeedViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print("results controller there should be")
    }
}

extension GZFeedViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.active && searchController.searchBar.text != "" {
        searchContentForQuery(searchController.searchBar.text!)
        }
    }
}