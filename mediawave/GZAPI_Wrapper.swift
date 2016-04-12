//
//  GZAPI_Wrapper.swift
//  mediawave
//
//  Created by George Zinyakov on 12/22/15.
//  Copyright © 2015 George Zinyakov. All rights reserved.
//


import Foundation

//задаем константы

// Youtube
let kBaseURLYT = "https://www.googleapis.com/youtube/v3/"
let kApiKeyYT = "AIzaSyDmKKXWUeSTP5cfDaivcznCoxC6tN30weo"

// Soundcloud
let kBaseURLSC = "http://api.soundcloud.com/"
let kApiKeySC = "CLIENTKEY"

// Last.fm
let kBaseURLLF = "http://ws.audioscrobbler.com/2.0/"
let kApiKeyLF = "c53a4c298a6c585e5cc6fb18c2e456b9"

var services:NSDictionary = ["youtube" : kBaseURLYT, "soundcloud": kBaseURLSC, "lastfm": kBaseURLLF]

class GZAPI_WRAPPER: NSObject
{
    // parameters - аргумент - словарь <имя аргумента - значение агрумента> endpoint - начало ссылки - тот скрипт на фликре к которому мы обращемеся. На выходе готовая ссылка в формате https://www.googleapis.com/youtube/v3/<endpoint>?<имя аргумента из словаря=значение аргумента>&<имя аргумента из словаря=значение аргумента>....
    private class func composeHTTPRequestWithParameters (parameters : NSDictionary? , service : String , endpoint : String ) -> NSURLRequest
    {
        var urlString = (services.objectForKey(service) as! String) + endpoint + "?" //Формируем начало ссылки
        
        let keysArray = parameters?.allKeys //Берем все ключи из словаря и засовываем в массив keysArray
        
        for ( var i = 0 ; i < keysArray?.count ; i++) // Цикл
        {
            
            let key = keysArray![i] as! String //Получаем i-ый ключ из массива
            let value = parameters!.objectForKey(key) as! String //Получаем значение из массива по ключу
            
            if ( i < keysArray!.count - 1) // Проверяем, дошли до конца массива или нет
            {
                urlString = urlString + key + "=" + value + "&" //Формируем запрос по частям если не конец
            }
            else
            {
                urlString = urlString + key + "=" + value // Добавляем в запрос последнее значение (без &)
            }
        }
        
//        print("url string : \(urlString)") // Печатаем полученный запрос для проверки
        
        let url = NSURL (string: urlString) // Приводим сформированный запрос к формату NSURL (оборачиваем к класс NSURL)
        
        return NSMutableURLRequest (URL: url!) //Возвращаем объект запросf в интернет (mutable - можем менять)
        
    }
    
    // data - объект класса NSData (байты из интернета).
    // responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.).
    // error - объект ошибки класса NSError (содержит код ошибки).
    
    class func genericCompletionHandler ( data : NSData? , response : NSURLResponse?, ErrorType : NSError? , success : ( jsonResponse : JSON) -> Void , failure : () -> Void)
    {
        if ( data != nil) // Если данные не пустые
        {
            let jsonResponse = JSON ( data: data!, options: NSJSONReadingOptions(), error: nil ) // конвертируем пришедшие данные из формата NSData в формат JSON для дальнейшего парсинга
            //print("internet answer : json response: \(jsonResponse)") // Печатаем  результаты запроса для проверки
            success ( jsonResponse: jsonResponse) // Возвращаем результаты в success block
        }
        else
        {
            failure()
        }
    }
}

// MARK: YOUTUBE
// MARK: Search youtube media by query
extension GZAPI_WRAPPER {
    class func getAllYoutubeMediaByQuery ( searchQuery : String , perPage : Int , pageNumber : Int , success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        let parameteresDictionary = NSMutableDictionary ()
        let escapedSearchQuery = searchQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! as String
        print("query is \(escapedSearchQuery)")
        parameteresDictionary.setObject("snippet", forKey : "part")
        parameteresDictionary.setObject("10", forKey : "videoCategoryId")
        parameteresDictionary.setObject("video", forKey : "type")
        parameteresDictionary.setObject("\(perPage)", forKey : "maxResults")
        parameteresDictionary.setObject("\(escapedSearchQuery)", forKey: "q")
        parameteresDictionary.setObject(kApiKeyYT, forKey: "key")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "youtube", endpoint: "search")
        //request - получили объект классса NSURLRequest
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        return task
    }
}

// MARK: Search youtube playlists by query
extension GZAPI_WRAPPER {
    class func getAllYoutubePlaylistsByQuery ( tags : Array<GZLFTag> , perPage : Int , nextPage : String , success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        let parameteresDictionary = NSMutableDictionary ()
        var searchQuery:String = ""
        for tag:GZLFTag in tags {
            searchQuery += tag.name + "|"
        }
        let escapedSearchQuery = searchQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! as String
        print("query is \(escapedSearchQuery)")
        parameteresDictionary.setObject("snippet", forKey : "part")
        parameteresDictionary.setObject("playlist", forKey : "type")
        parameteresDictionary.setObject("\(perPage)", forKey : "maxResults")
        parameteresDictionary.setObject("\(escapedSearchQuery)", forKey: "q")
        if !(nextPage.isEmpty) {
            parameteresDictionary.setObject(nextPage, forKey: "pageToken")
        }
        parameteresDictionary.setObject(kApiKeyYT, forKey: "key")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "youtube", endpoint: "search")
        //request - получили объект классса NSURLRequest
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        
        return task
    }
}

// MARK: Get youtube playlist items by playlist id
extension GZAPI_WRAPPER {
    class func getYoutubePlaylistItemsByID ( playlistID : String , perPage : Int , pageToken : String , success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        let parameteresDictionary = NSMutableDictionary ()
        let escapedPlaylistID = playlistID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! as String
        print("playlist ID is \(escapedPlaylistID)")
        parameteresDictionary.setObject("snippet", forKey : "part")
        parameteresDictionary.setObject("\(perPage)", forKey : "maxResults")
        parameteresDictionary.setObject("\(pageToken)", forKey : "pageToken")
        parameteresDictionary.setObject("\(escapedPlaylistID)", forKey: "playlistId")
        parameteresDictionary.setObject(kApiKeyYT, forKey: "key")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "youtube", endpoint: "playlistItems")
        //request - получили объект классса NSURLRequest
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        return task
    }
}

// MARK: SOUNDCLOUD
// MARK: Search soundcloud media by query
extension GZAPI_WRAPPER {
    class func getAllSoundcloudTracksByQuery ( searchQuery : String , perPage : Int , pageNumber : Int , success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        let parameteresDictionary = NSMutableDictionary ()
        let escapedSearchQuery = searchQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! as String
        print("query is \(escapedSearchQuery)")
        parameteresDictionary.setObject("\(perPage)", forKey : "limit")
        parameteresDictionary.setObject("\(escapedSearchQuery)", forKey: "q")
        parameteresDictionary.setObject("1", forKey: "linked_partitioning")
        parameteresDictionary.setObject(kApiKeySC, forKey: "client_id")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "soundcloud", endpoint: "tracks.json")
        //request - получили объект классса NSURLRequest
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        return task
    }
}

// MARK: LASTFM
// MARK: Search for all artists by query
extension GZAPI_WRAPPER {
    class func getAllLastfmArtistsByQuery ( searchQuery : String , perPage : Int , pageNumber : Int , success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        let parameteresDictionary = NSMutableDictionary ()
        let escapedSearchQuery = searchQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! as String
        print("query is \(escapedSearchQuery)")
        parameteresDictionary.setObject("artist.search", forKey : "method")
        parameteresDictionary.setObject(kApiKeyLF, forKey: "api_key")
        parameteresDictionary.setObject("json", forKey: "format")
        parameteresDictionary.setObject("\(perPage)", forKey : "limit")
        parameteresDictionary.setObject("\(pageNumber)", forKey : "page")
        parameteresDictionary.setObject("\(escapedSearchQuery)", forKey: "artist")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "lastfm", endpoint: "")
        //request - получили объект классса NSURLRequest
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        return task
    }
}

// MARK: Search for all albums by query
extension GZAPI_WRAPPER {
    class func getAllLastfmAlbumsByQuery ( searchQuery : String , perPage : Int , pageNumber : Int , success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        print("initial query is \(searchQuery)")
        let parameteresDictionary = NSMutableDictionary ()
        let escapedSearchQuery = searchQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! as String
        print("query is \(escapedSearchQuery)")
        parameteresDictionary.setObject("album.search", forKey : "method")
        parameteresDictionary.setObject(kApiKeyLF, forKey: "api_key")
        parameteresDictionary.setObject("json", forKey: "format")
        parameteresDictionary.setObject("\(perPage)", forKey : "limit")
        parameteresDictionary.setObject("\(pageNumber)", forKey : "page")
        parameteresDictionary.setObject("\(escapedSearchQuery)", forKey: "album")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "lastfm", endpoint: "")
        //request - получили объект классса NSURLRequest
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        return task
    }
}

// MARK: Search for all tracks by query
extension GZAPI_WRAPPER {
    class func getAllLastfmTracksByQuery ( searchQuery : String , perPage : Int , pageNumber : Int , success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        let parameteresDictionary = NSMutableDictionary ()
        let escapedSearchQuery = searchQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! as String
        print("query is \(escapedSearchQuery)")
        parameteresDictionary.setObject("track.search", forKey : "method")
        parameteresDictionary.setObject(kApiKeyLF, forKey: "api_key")
        parameteresDictionary.setObject("json", forKey: "format")
        parameteresDictionary.setObject("\(perPage)", forKey : "limit")
        parameteresDictionary.setObject("\(pageNumber)", forKey : "page")
        parameteresDictionary.setObject("\(escapedSearchQuery)", forKey: "track")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "lastfm", endpoint: "")
        //request - получили объект классса NSURLRequest
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        return task
    }
}

// MARK: Search for top albums by artist MBID
extension GZAPI_WRAPPER {
    class func getTopLastfmAlbumsByArtist ( artistMBID : String , perPage : Int , pageNumber : Int , success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        let parameteresDictionary = NSMutableDictionary ()
        let escapedartistMBID = artistMBID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! as String
        print("mbid is \(escapedartistMBID)")
        parameteresDictionary.setObject("artist.getTopAlbums", forKey : "method")
        parameteresDictionary.setObject(kApiKeyLF, forKey: "api_key")
        parameteresDictionary.setObject("json", forKey: "format")
        parameteresDictionary.setObject("\(perPage)", forKey : "limit")
        parameteresDictionary.setObject("\(pageNumber)", forKey : "page")
        parameteresDictionary.setObject("\(escapedartistMBID)", forKey: "mbid")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "lastfm", endpoint: "")
        print("getTopLastfmAlbumsByArtist \(request)")
        //request - получили объект классса NSURLRequest
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        return task
    }
}

// MARK: Search for top tracks by artist MBID
extension GZAPI_WRAPPER {
    class func getTopLastfmTracksByArtist ( artistMBID : String , perPage : Int , pageNumber : Int , success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        let parameteresDictionary = NSMutableDictionary ()
        let escapedartistMBID = artistMBID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! as String
        print("mbid is \(escapedartistMBID)")
        parameteresDictionary.setObject("artist.getTopTracks", forKey : "method")
        parameteresDictionary.setObject(kApiKeyLF, forKey: "api_key")
        parameteresDictionary.setObject("json", forKey: "format")
        parameteresDictionary.setObject("\(perPage)", forKey : "limit")
        parameteresDictionary.setObject("\(pageNumber)", forKey : "page")
        parameteresDictionary.setObject("\(escapedartistMBID)", forKey: "mbid")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "lastfm", endpoint: "")
        //request - получили объект классса NSURLRequest
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        return task
    }
}

// MARK: Search for top tags by artist MBID
extension GZAPI_WRAPPER {
    class func getTopLastfmTagsByArtist ( artistMBID : String , perPage : Int , pageNumber : Int , success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        let parameteresDictionary = NSMutableDictionary ()
        let escapedartistMBID = artistMBID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! as String
        print("mbid is \(escapedartistMBID)")
        parameteresDictionary.setObject("artist.getTopTags", forKey : "method")
        parameteresDictionary.setObject(kApiKeyLF, forKey: "api_key")
        parameteresDictionary.setObject("json", forKey: "format")
        parameteresDictionary.setObject("\(perPage)", forKey : "limit")
        parameteresDictionary.setObject("\(pageNumber)", forKey : "page")
        parameteresDictionary.setObject("\(escapedartistMBID)", forKey: "mbid")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "lastfm", endpoint: "")
        //request - получили объект классса NSURLRequest
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        return task
    }
}

// MARK: Search for info by artist MBID
extension GZAPI_WRAPPER {
    class func getLastfmInfoByArtist ( artistMBID : String , perPage : Int , pageNumber : Int , success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        let parameteresDictionary = NSMutableDictionary ()
        let escapedartistMBID = artistMBID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! as String
        print("mbid is \(escapedartistMBID)")
        parameteresDictionary.setObject("artist.getInfo", forKey : "method")
        parameteresDictionary.setObject(kApiKeyLF, forKey: "api_key")
        parameteresDictionary.setObject("json", forKey: "format")
        parameteresDictionary.setObject("\(perPage)", forKey : "limit")
        parameteresDictionary.setObject("\(pageNumber)", forKey : "page")
        parameteresDictionary.setObject("\(escapedartistMBID)", forKey: "mbid")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "lastfm", endpoint: "")
        //request - получили объект классса NSURLRequest
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        return task
    }
}

// MARK: Get top tags of Last.fm
extension GZAPI_WRAPPER {
    class func getLastfmTopTags ( success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        let parameteresDictionary = NSMutableDictionary ()
        parameteresDictionary.setObject("chart.getTopTags", forKey : "method")
        parameteresDictionary.setObject(kApiKeyLF, forKey: "api_key")
        parameteresDictionary.setObject("json", forKey: "format")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "lastfm", endpoint: "")
        //request - получили объект классса NSURLRequest
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        return task
    }
}

// MARK: Get tracks by album MBID
extension GZAPI_WRAPPER {
    class func getTopLastfmTracksByAlbum ( albumMBID : String , success : ( jsonResponse : JSON) -> Void , failure : () -> Void) -> NSURLSessionDataTask
    {
        let parameteresDictionary = NSMutableDictionary ()
        let escapedalbumMBID = albumMBID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! as String
        print("mbid is \(escapedalbumMBID)")
        parameteresDictionary.setObject("album.getInfo", forKey : "method")
        parameteresDictionary.setObject(kApiKeyLF, forKey: "api_key")
        parameteresDictionary.setObject("json", forKey: "format")
        parameteresDictionary.setObject("\(escapedalbumMBID)", forKey: "mbid")
        
        let request = composeHTTPRequestWithParameters(parameteresDictionary, service: "lastfm", endpoint: "")
        //request - получили объект классса NSURLRequest
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data , responce , error) -> Void in
            
            // в этот БЛОК приходи ответ из интернета. data - объект класса NSData - байты из интернета. responce - объект класса NSURLResponce (содержит статус ошибки, статус сообщения и пр.). error - объект ошибки класса NSError (содержит код ошибки).
            genericCompletionHandler(data , response: responce , ErrorType: error , success : success , failure : failure)
            
        } //task  - объект типа NSURLSessionDataTask
        
        task.resume() // начало запроса в интернет ( отправка запроса в интернет )
        return task
    }
}
