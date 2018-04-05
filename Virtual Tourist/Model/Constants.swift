//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Satveer Singh on 2/18/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//

import UIKit

// MARK: - Constants

struct Constants {
    
    // MARK: Flickr
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let latitude = "lat"
        static let logitude = "lon"
        static let Page = "page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "1aa68240cb299d66d9531ae70613dbee"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys : Decodable {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
        
    }
    
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
    struct errorMessage {
        static let  statusCodeError = "Your request returned a status code other than 2xx!"
        static let apiDataError = "Your request did not returned data"
        static let jsonDecodingError = "Json decoding fail"
        static let fetchResquestError = "Error while trying to perform a fetech request"
        
    }
}


// MARK: Flicker Response decoder
struct FlickerResponse : Decodable {
    var photos : Photos
}

struct Photos : Decodable {
    var photo : [Photo]
}

struct Photo : Decodable {
    var id : String?
    var url : String?

    private enum CodingKeys : String, CodingKey {
        case url = "url_m"
        case id
    }
}

struct Location: Equatable {
    var latidute : Double
    var longitude : Double
    var photo : [Photo]?
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.latidute == rhs.latidute && lhs.longitude == rhs.longitude
    }
}
