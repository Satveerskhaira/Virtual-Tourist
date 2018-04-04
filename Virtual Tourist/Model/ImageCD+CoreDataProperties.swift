//
//  ImageCD+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Satveer Singh on 4/2/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//
//

import Foundation
import CoreData


extension ImageCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageCD> {
        return NSFetchRequest<ImageCD>(entityName: "ImageCD")
    }

    @NSManaged public var imageCD: NSData?
    @NSManaged public var photo: PhotosCD?

}
