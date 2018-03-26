//
//  PhotosCD+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Satveer Singh on 3/25/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotosCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotosCD> {
        return NSFetchRequest<PhotosCD>(entityName: "PhotosCD")
    }

    @NSManaged public var photoIDCD: String?
    @NSManaged public var photoURLCD: String?
    @NSManaged public var location: LocationCD?

}
