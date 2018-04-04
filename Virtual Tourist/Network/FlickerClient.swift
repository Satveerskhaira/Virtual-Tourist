//
//  FlickerClient.swift
//  Virtual Tourist
//
//  Created by Satveer Singh on 1/27/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//

import Foundation
import UIKit
class FlickerClient: NSObject {
    
    //MARK: Properties:
    var photos = [Photo]()
    var location: Location?
    
    var lat : Double?
    var log : Double?
    let session = URLSession.shared
    // MARK : Method for parameter
    func createParamtersForURL(_ latitude : Double, _ logitude : Double) -> [String: AnyObject] {
        lat = latitude
        log = logitude
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.latitude : latitude,
            Constants.FlickrParameterKeys.logitude : logitude,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            ] as [String : AnyObject]
        return methodParameters as [String : AnyObject]
    }
    // MARK : Search Function with latitude and Longitude
    
    func searchImageWithLatAndLOn(_ methodParameters : [String:AnyObject], searchHandler: @escaping (_ locationDataPhoto : [Photo]?, _ success : Bool, _ errorString : String?) -> Void) {
        // Create URL
        
        let url = createURL(methodParameters)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            /* GUARD: Did we get a successful 2XX response? */
            guard error == nil else {
                searchHandler(nil, false, error?.localizedDescription)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                searchHandler(nil, false, "Your request returned a status code other than 2xx!")
                return
            }
            /* GUARD: Did we get data  */
            guard let data = data else {
                searchHandler(nil, false, "Your request did not returned data")
                return
            }
            
            
            do {
                let decoder = JSONDecoder()
                decoder.dataDecodingStrategy = .deferredToData
                let photoData = try decoder.decode(FlickerResponse.self, from: data)
                self.photos = photoData.photos.photo
                searchHandler(self.photos, true, nil)
                return
            } catch {
                searchHandler(nil, false, "Json decoding fail")
                return
            }
            
        }
        // Resume Task
        task.resume()
    }
    
    // MARK : Helper method to create URL from parameter
    
    func createURL(_ parameters : [String:AnyObject]) -> URL{
        
        var components = URLComponents()
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.scheme = Constants.Flickr.APIScheme
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        return components.url!
    }
    
    // Load Image from network
    
    func loadImage(_ url : URL, handler : @escaping (_ image : UIImage) -> Void) {
        let task = session.dataTask(with: url) { (data, response, error) in
            if error == nil {
                let downloadImage = UIImage(data: data!)
                handler(downloadImage!)
            } else {
                handler(#imageLiteral(resourceName: "Original"))
            }
        }
        task.resume()
    }
    
    // Make singleton
    
    class func sharedInstance() -> FlickerClient {
        struct Singleton {
            static var sharedInstance = FlickerClient()
        }
        return Singleton.sharedInstance
    }
    
    
}
