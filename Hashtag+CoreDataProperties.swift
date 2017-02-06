//
//  Hashtag+CoreDataProperties.swift
//  LocationHashtag
//
//  Created by High Jumper on 6/30/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Hashtag {

    @NSManaged var name: String?
    @NSManaged var population: NSNumber?
    @NSManaged var location: KOLocation?

}
