//
//  kGZConstants.swift
//  mediawave
//
//  Created by George Zinyakov on 3/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
}

class kGZConstants {
}

//MARK: - Top musical tags
extension kGZConstants {
    static var topTags:Array<GZLFTag> = [
        GZLFTag(nameValue: "Rock"),
        GZLFTag(nameValue: "Electronic"),
        GZLFTag(nameValue: "Pop"),
        GZLFTag(nameValue: "Folk"),
        GZLFTag(nameValue: "Funk"),
        GZLFTag(nameValue: "Jazz"),
        GZLFTag(nameValue: "Hip Hop"),
        GZLFTag(nameValue: "Classical"),
        GZLFTag(nameValue: "Reggae"),
        GZLFTag(nameValue: "Latin"),
        GZLFTag(nameValue: "Soundtrack"),
        GZLFTag(nameValue: "Blues"),
        GZLFTag(nameValue: "House"),
        GZLFTag(nameValue: "Pop Rock"),
        GZLFTag(nameValue: "Synth-pop"),
        GZLFTag(nameValue: "Experimental"),
        GZLFTag(nameValue: "Punk"),
        GZLFTag(nameValue: "Disco"),
        GZLFTag(nameValue: "Techno"),
        GZLFTag(nameValue: "Alternative"),
        GZLFTag(nameValue: "Indie"),
        GZLFTag(nameValue: "Hardcore"),
        GZLFTag(nameValue: "Vocal"),
        GZLFTag(nameValue: "Soul"),
        GZLFTag(nameValue: "Ambient"),
        GZLFTag(nameValue: "Trance"),
        GZLFTag(nameValue: "Hard Rock"),
        GZLFTag(nameValue: "Metal"),
        GZLFTag(nameValue: "Rock & Roll"),
        GZLFTag(nameValue: "Ballad"),
        GZLFTag(nameValue: "Psychedelic"),
        GZLFTag(nameValue: "Noise"),
        GZLFTag(nameValue: "Classic"),
        GZLFTag(nameValue: "New Wave"),
        GZLFTag(nameValue: "Industrial"),
        GZLFTag(nameValue: "Blues"),
        GZLFTag(nameValue: "R&B"),
        GZLFTag(nameValue: "Garage"),
        GZLFTag(nameValue: "Europop"),
        GZLFTag(nameValue: "Dub"),
        GZLFTag(nameValue: "Progressive"),
        GZLFTag(nameValue: "Country"),
        GZLFTag(nameValue: "Romantic"),
        GZLFTag(nameValue: "Acoustic"),
        GZLFTag(nameValue: "50s"),
        GZLFTag(nameValue: "60s"),
        GZLFTag(nameValue: "70s"),
        GZLFTag(nameValue: "80s"),
        GZLFTag(nameValue: "90s"),
        GZLFTag(nameValue: "00s")
    ]
}

//MARK: - Numeric constants
extension kGZConstants {
    static var mediawaveColor = UIColor(red: 255/255, green: 96/255, blue: 152/255, alpha: 1)
    
    static var playlistCellHeight:CGFloat {
        if ( DeviceType.IS_IPHONE_6 || DeviceType.IS_IPHONE_6P ) {
            return 260.0
        }
        return 210.0
    }
    static var advancedCellHeight:CGFloat = 70.0
    static var simpleCellHeight:CGFloat = 45.0
    static var defaultCellHeight:CGFloat = 35.0
}

//MARK: - Identifiers
extension kGZConstants {
    static var GZSearchCache = "GZSearchCache"
    
    static var cellGenericId = "Cell"
    static var GZAlertTableViewCell = "GZAlertTableViewCell"
    static var GZtrackSimpleCell = "GZtrackSimpleCell"
    static var GZDescriptionTableViewCell = "GZDescriptionTableViewCell"
    static var GZPlaylistTableViewCell = "GZPlaylistTableViewCell"
    static var GZLoaderTableViewCell = "GZLoaderTableViewCell"
    static var trackAdvancedCell = "trackAdvancedCell"
    
    static var toArtistFromSearchResults = "toArtistFromSearchResults"
    static var toAlbumFromSearchResults = "toAlbumFromSearchResults"
    static var toAlbumFromArtist = "toAlbumFromArtist"
    static var toTagsFromFeed = "toTagsFromFeed"
    static var toPlaylistFromFeed = "toPlaylistFromFeed"
    
    static var youtubeBaseURL = "http://www.youtube.com/watch?v="
}

//MARK: - Localiseable strings
extension kGZConstants {
    static var continueLabel = NSLocalizedString("Continue", comment: "")
    static var error = NSLocalizedString("Unknown error", comment: "")
    static var untitled = NSLocalizedString("Untitled", comment: "")
    static var yes = NSLocalizedString("Yes", comment: "")
    static var no = NSLocalizedString("No", comment: "")
    static var cancel = NSLocalizedString("Cancel", comment: "")
    static var edit = NSLocalizedString("Edit", comment: "")
    static var loadMore = NSLocalizedString("Load more", comment: "")
    
    static var introLabel = NSLocalizedString("GZTagsSelectViewController.introLabel", comment: "")
    static var feedTitle = NSLocalizedString("GZFeedViewController.title", comment: "")
    static var searchTitle = NSLocalizedString("GZSearchViewController.title", comment: "")
    static var playerTitle = NSLocalizedString("GZTrackViewController.title", comment: "")
    static var noSearchCache = NSLocalizedString("GZAlertTableViewCell.NoSearchCache", comment: "")
    static var noSearchResults = NSLocalizedString("GZAlertTableViewCell.NoSearchResults", comment: "")
    static var clearSearch = NSLocalizedString("GZSearchViewController.clearSearch", comment: "")
    static var clearSearchPromt = NSLocalizedString("GZSearchViewController.clearSearchPromt", comment: "")
    static var clearSearchDescript = NSLocalizedString("GZSearchViewController.clearSearchDescript", comment: "")
    static var recentlySearched = NSLocalizedString("GZSearchViewController.recentlySearched", comment: "")
    static var artists = NSLocalizedString("GZSearchResultsController.artists", comment: "")
    static var albums = NSLocalizedString("GZSearchResultsController.albums", comment: "")
    static var tracks = NSLocalizedString("GZSearchResultsController.tracks", comment: "")
    static var topalbums = NSLocalizedString("GZArtistDetails.topalbums", comment: "")
    static var toptracks = NSLocalizedString("GZArtistDetails.toptracks", comment: "")
    static var foundAlert = NSLocalizedString("GZTrackViewController.foundAlert", comment: "")
}
