//
//  KOLocation+CoreDataProperties.swift
//  LocationHashtag
//
//  Created by High Jumper on 7/4/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension KOLocation {

    @NSManaged var icon: String?
    @NSManaged var id: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var name: String?
    @NSManaged var type: String?
    @NSManaged var hashtags: NSSet?

}
