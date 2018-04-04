//
//  LocationCD+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Satveer Singh on 4/2/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//
//

import Foundation
import CoreData


extension LocationCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationCD> {
        return NSFetchRequest<LocationCD>(entityName: "LocationCD")
    }

    @NSManaged public var latiduteCD: Double
    @NSManaged public var longitudeCD: Double
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for photos
extension LocationCD {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: PhotosCD)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: PhotosCD)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
